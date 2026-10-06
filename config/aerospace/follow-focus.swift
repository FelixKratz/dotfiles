// Switch to an app's AeroSpace workspace when it is activated but AeroSpace
// stays put.
//
// AeroSpace follows focus to another workspace only when the focused window
// is one it tracks. Dialogs it does not track (Open/Save sheets, update and
// auth prompts) can become the key window instead, and the app then holds
// focus while all its windows sit hidden on another workspace. This watches
// app activations and, when that happens, switches to the workspace holding
// the app's windows.

import AppKit

let aerospace = ["/opt/homebrew/bin/aerospace", "/usr/local/bin/aerospace"]
  .first { FileManager.default.isExecutableFile(atPath: $0) } ?? "aerospace"

// Long enough for AeroSpace to finish its own workspace switch, so this only
// acts once AeroSpace has had its chance.
let settleDelay = 0.4

func run(_ args: [String]) -> [String] {
  let process = Process()
  let pipe = Pipe()
  process.executableURL = URL(fileURLWithPath: aerospace)
  process.arguments = args
  process.standardOutput = pipe
  process.standardError = FileHandle.nullDevice
  do { try process.run() } catch { return [] }
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  process.waitUntilExit()
  guard process.terminationStatus == 0 else { return [] }
  return String(decoding: data, as: UTF8.self)
    .split(separator: "\n").map(String.init)
}

// Clicking the desktop activates Finder, which would otherwise pull you to
// whichever workspace holds a Finder window.
let ignoredBundleIDs: Set = ["com.apple.finder"]

func followIfStranded(_ app: NSRunningApplication) {
  guard NSWorkspace.shared.frontmostApplication?.processIdentifier
    == app.processIdentifier,
    !ignoredBundleIDs.contains(app.bundleIdentifier ?? "")
  else { return }

  let appWorkspaces = Set(run([
    "list-windows", "--monitor", "all", "--pid", String(app.processIdentifier),
    "--format", "%{workspace}",
  ]))
  let visible = Set(run(["list-workspaces", "--monitor", "all", "--visible"]))

  // Leave alone apps with no tracked windows (menu bar apps, launchers), apps
  // already showing on some monitor, and apps spread over several hidden
  // workspaces, where there is no single right answer.
  guard appWorkspaces.count == 1, !visible.isEmpty,
    appWorkspaces.isDisjoint(with: visible),
    let target = appWorkspaces.first
  else { return }

  FileHandle.standardError.write(
    "\(Date()) \(app.localizedName ?? "?") -> workspace \(target)\n"
      .data(using: .utf8)!)
  _ = run(["workspace", target])
}

NSWorkspace.shared.notificationCenter.addObserver(
  forName: NSWorkspace.didActivateApplicationNotification,
  object: nil, queue: .main
) { note in
  guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey]
    as? NSRunningApplication else { return }
  DispatchQueue.main.asyncAfter(deadline: .now() + settleDelay) {
    followIfStranded(app)
  }
}

RunLoop.main.run()
