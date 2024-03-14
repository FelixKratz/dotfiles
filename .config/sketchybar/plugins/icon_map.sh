#!/bin/bash

function icon_map() {
	case "$1" in
	"Live")
		icon_result=":ableton:"
		;;
	"Affinity Designer")
		icon_result=":affinity_designer:"
		;;
	"Affinity Designer 2")
		icon_result=":affinity_designer_2:"
		;;
	"Affinity Photo")
		icon_result=":affinity_photo:"
		;;
	"Affinity Photo 2")
		icon_result=":affinity_photo_2:"
		;;
	"Affinity Publisher")
		icon_result=":affinity_publisher:"
		;;
	"Affinity Publisher 2")
		icon_result=":affinity_publisher_2:"
		;;
	"Airmail")
		icon_result=":airmail:"
		;;
	"Alacritty")
		icon_result=":alacritty:"
		;;
	"Alfred")
		icon_result=":alfred:"
		;;
	"Android Messages")
		icon_result=":android_messages:"
		;;
	"Android Studio")
		icon_result=":android_studio:"
		;;
	"Anytype")
		icon_result=":anytype:"
		;;
	"App Store")
		icon_result=":app_store:"
		;;
	"Arc")
		icon_result=":arc:"
		;;
	"Atom")
		icon_result=":atom:"
		;;
	"Audacity")
		icon_result=":audacity:"
		;;
	"MoneyMoney")
		icon_result=":bank:"
		;;
	"Bear")
		icon_result=":bear:"
		;;
	"Bitwarden")
		icon_result=":bit_warden:"
		;;
	"Blender")
		icon_result=":blender:"
		;;
	"BluOS Controller")
		icon_result=":bluos_controller:"
		;;
	"Calibre")
		icon_result=":book:"
		;;
	"Brave Browser")
		icon_result=":brave_browser:"
		;;
	"Calendar" | "日历" | "Fantastical" | "Cron" | "Amie" | "Calendrier")
		icon_result=":calendar:"
		;;
	"Caprine")
		icon_result=":caprine:"
		;;
	"Citrix Workspace" | "Citrix Viewer")
		icon_result=":citrix:"
		;;
	"ClickUp")
		icon_result=":click_up:"
		;;
	"Code" | "Code - Insiders")
		icon_result=":code:"
		;;
	"Color Picker" | "数码测色计")
		icon_result=":color_picker:"
		;;
	"Cypress")
		icon_result=":cypress:"
		;;
	"DaVinci Resolve")
		icon_result=":davinciresolve:"
		;;
	"Default")
		icon_result=":default:"
		;;
	"CleanMyMac X")
		icon_result=":desktop:"
		;;
	"DEVONthink 3")
		icon_result=":devonthink3:"
		;;
	"DingTalk" | "钉钉" | "阿里钉")
		icon_result=":dingtalk:"
		;;
	"Discord" | "Discord Canary" | "Discord PTB")
		icon_result=":discord:"
		;;
	"Docker" | "Docker Desktop")
		icon_result=":docker:"
		;;
	"GrandTotal" | "Receipts")
		icon_result=":dollar:"
		;;
	"Double Commander")
		icon_result=":doublecmd:"
		;;
	"Drafts")
		icon_result=":drafts:"
		;;
	"Dropbox")
		icon_result=":dropbox:"
		;;
	"Element")
		icon_result=":element:"
		;;
	"Emacs")
		icon_result=":emacs:"
		;;
	"Evernote Legacy")
		icon_result=":evernote_legacy:"
		;;
	"FaceTime" | "FaceTime 通话")
		icon_result=":face_time:"
		;;
	"Figma")
		icon_result=":figma:"
		;;
	"Final Cut Pro")
		icon_result=":final_cut_pro:"
		;;
	"Finder" | "访达")
		icon_result=":finder:"
		;;
	"Firefox")
		icon_result=":firefox:"
		;;
	"Firefox Developer Edition" | "Firefox Nightly")
		icon_result=":firefox_developer_edition:"
		;;
	"Folx")
		icon_result=":folx:"
		;;
	"System Preferences" | "System Settings" | "系统设置" | "Réglages Système")
		icon_result=":gear:"
		;;
	"GitHub Desktop")
		icon_result=":git_hub:"
		;;
	"Godot")
		icon_result=":godot:"
		;;
	"GoLand")
		icon_result=":goland:"
		;;
	"Chromium" | "Google Chrome" | "Google Chrome Canary")
		icon_result=":google_chrome:"
		;;
	"Grammarly Editor")
		icon_result=":grammarly:"
		;;
	"Hyper")
		icon_result=":hyper:"
		;;
	"IntelliJ IDEA")
		icon_result=":idea:"
		;;
	"Insomnia")
		icon_result=":insomnia:"
		;;
	"Iris")
		icon_result=":iris:"
		;;
	"iTerm" | "iTerm2")
		icon_result=":iterm:"
		;;
	"Jellyfin Media Player")
		icon_result=":jellyfin:"
		;;
	"Joplin")
		icon_result=":joplin:"
		;;
	"카카오톡")
		icon_result=":kakaotalk:"
		;;
	"Kakoune")
		icon_result=":kakoune:"
		;;
	"KeePassXC")
		icon_result=":kee_pass_x_c:"
		;;
	"Keyboard Maestro")
		icon_result=":keyboard_maestro:"
		;;
	"Keynote" | "Keynote 讲演")
		icon_result=":keynote:"
		;;
	"kitty")
		icon_result=":kitty:"
		;;
	"League of Legends")
		icon_result=":league_of_legends:"
		;;
	"LibreWolf")
		icon_result=":libre_wolf:"
		;;
	"Adobe Lightroom")
		icon_result=":lightroom:"
		;;
	"Lightroom Classic")
		icon_result=":lightroomclassic:"
		;;
	"Linear")
		icon_result=":linear:"
		;;
	"Logic Pro")
		icon_result=":logicpro:"
		;;
	"Logseq")
		icon_result=":logseq:"
		;;
	"Canary Mail" | "HEY" | "Mail" | "Mailspring" | "MailMate" | "邮件")
		icon_result=":mail:"
		;;
	"MAMP" | "MAMP PRO")
		icon_result=":mamp:"
		;;
	"Maps" | "Google Maps")
		icon_result=":maps:"
		;;
	"Matlab")
		icon_result=":matlab:"
		;;
	"Mattermost")
		icon_result=":mattermost:"
		;;
	"Messages" | "信息" | "Nachrichten")
		icon_result=":messages:"
		;;
	"Messenger")
		icon_result=":messenger:"
		;;
	"Microsoft Edge")
		icon_result=":microsoft_edge:"
		;;
	"Microsoft Excel")
		icon_result=":microsoft_excel:"
		;;
	"Microsoft Outlook")
		icon_result=":microsoft_outlook:"
		;;
	"Microsoft PowerPoint")
		icon_result=":microsoft_power_point:"
		;;
	"Microsoft Teams" | "Microsoft Teams (work or school)")
		icon_result=":microsoft_teams:"
		;;
	"Microsoft Word")
		icon_result=":microsoft_word:"
		;;
	"Min")
		icon_result=":min_browser:"
		;;
	"Miro")
		icon_result=":miro:"
		;;
	"MongoDB Compass"*)
		icon_result=":mongodb:"
		;;
	"mpv")
		icon_result=":mpv:"
		;;
	"Music" | "音乐" | "Musique")
		icon_result=":music:"
		;;
	"Neovide" | "neovide")
		icon_result=":neovide:"
		;;
	"网易云音乐")
		icon_result=":netease_music:"
		;;
	"Noodl" | "Noodl Editor")
		icon_result=":noodl:"
		;;
	"NordVPN")
		icon_result=":nord_vpn:"
		;;
	"Notability")
		icon_result=":notability:"
		;;
	"Notes" | "备忘录")
		icon_result=":notes:"
		;;
	"Notion")
		icon_result=":notion:"
		;;
	"Nova")
		icon_result=":nova:"
		;;
	"Numbers" | "Numbers 表格")
		icon_result=":numbers:"
		;;
	"Obsidian")
		icon_result=":obsidian:"
		;;
	"OBS")
		icon_result=":obsstudio:"
		;;
	"OmniFocus")
		icon_result=":omni_focus:"
		;;
	"1Password")
		icon_result=":one_password:"
		;;
	"ChatGPT")
		icon_result=":openai:"
		;;
	"Orion" | "Orion RC")
		icon_result=":orion:"
		;;
	"Pages" | "Pages 文稿")
		icon_result=":pages:"
		;;
	"Parallels Desktop")
		icon_result=":parallels:"
		;;
	"Preview" | "预览" | "Skim" | "zathura" | "Aperçu")
		icon_result=":pdf:"
		;;
	"Adobe Photoshop"*)
		icon_result=":photoshop:"
		;;
	"Pi-hole Remote")
		icon_result=":pihole:"
		;;
	"Pine")
		icon_result=":pine:"
		;;
	"Podcasts" | "播客")
		icon_result=":podcasts:"
		;;
	"PomoDone App")
		icon_result=":pomodone:"
		;;
	"PyCharm")
		icon_result=":pycharm:"
		;;
	"QQ")
		icon_result=":qq:"
		;;
	"QQ音乐" | "QQMusic")
		icon_result=":qqmusic:"
		;;
	"qutebrowser")
		icon_result=":qute_browser:"
		;;
	"Raindrop.io")
		icon_result=":raindrop_io:"
		;;
	"Reeder")
		icon_result=":reeder5:"
		;;
	"Reminders" | "提醒事项" | "Rappels")
		icon_result=":reminders:"
		;;
	"Replit")
		icon_result=":replit:"
		;;
	"Rider" | "JetBrains Rider")
		icon_result=":rider:"
		;;
	"Safari" | "Safari浏览器" | "Safari Technology Preview")
		icon_result=":safari:"
		;;
	"Sequel Ace")
		icon_result=":sequel_ace:"
		;;
	"Sequel Pro")
		icon_result=":sequel_pro:"
		;;
	"Setapp")
		icon_result=":setapp:"
		;;
	"Signal")
		icon_result=":signal:"
		;;
	"Sketch")
		icon_result=":sketch:"
		;;
	"Skype")
		icon_result=":skype:"
		;;
	"Slack")
		icon_result=":slack:"
		;;
	"Spark Desktop")
		icon_result=":spark:"
		;;
	"Spotify")
		icon_result=":spotify:"
		;;
	"Spotlight")
		icon_result=":spotlight:"
		;;
	"Sublime Text")
		icon_result=":sublime_text:"
		;;
	"Tana")
		icon_result=":tana:"
		;;
	"TeamSpeak 3")
		icon_result=":team_speak:"
		;;
	"Telegram")
		icon_result=":telegram:"
		;;
	"Terminal" | "终端")
		icon_result=":terminal:"
		;;
	"Typora")
		icon_result=":text:"
		;;
	"Microsoft To Do" | "Things")
		icon_result=":things:"
		;;
	"Thunderbird")
		icon_result=":thunderbird:"
		;;
	"TickTick")
		icon_result=":tick_tick:"
		;;
	"TIDAL")
		icon_result=":tidal:"
		;;
	"Todoist")
		icon_result=":todoist:"
		;;
	"Tor Browser")
		icon_result=":tor_browser:"
		;;
	"Tower")
		icon_result=":tower:"
		;;
	"Transmit")
		icon_result=":transmit:"
		;;
	"Trello")
		icon_result=":trello:"
		;;
	"Tweetbot" | "Twitter")
		icon_result=":twitter:"
		;;
	"Neovide" | "MacVim" | "Vim" | "VimR")
		icon_result=":vim:"
		;;
	"Vivaldi")
		icon_result=":vivaldi:"
		;;
	"VLC")
		icon_result=":vlc:"
		;;
	"VMware Fusion")
		icon_result=":vmware_fusion:"
		;;
	"VSCodium")
		icon_result=":vscodium:"
		;;
	"Warp")
		icon_result=":warp:"
		;;
	"WebStorm")
		icon_result=":web_storm:"
		;;
	"微信" | "WeChat")
		icon_result=":wechat:"
		;;
	"WezTerm")
		icon_result=":wezterm:"
		;;
	"WhatsApp" | "‎WhatsApp")
		icon_result=":whats_app:"
		;;
	"Xcode")
		icon_result=":xcode:"
		;;
	"Yuque" | "语雀")
		icon_result=":yuque:"
		;;
	"Zed")
		icon_result=":zed:"
		;;
	"Zeplin")
		icon_result=":zeplin:"
		;;
	"zoom.us")
		icon_result=":zoom:"
		;;
	"Zotero")
		icon_result=":zotero:"
		;;
	"Zulip")
		icon_result=":zulip:"
		;;
	*)
		icon_result=":default:"
		;;
	esac
}

icon_map "$1"
echo "$icon_result"
