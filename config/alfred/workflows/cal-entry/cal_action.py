#!/usr/bin/env python3
"""
Alfred Action for calendar quick entry.
Takes JSON payload and creates event via Graph API (Outlook) or AppleScript (Apple Calendar).
"""

import json
import subprocess
import sys
import os
from datetime import datetime, timedelta

# Debug logging
LOG_FILE = os.path.expanduser("~/.log/alfred-cal.log")

def log(msg):
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    with open(LOG_FILE, "a") as f:
        f.write(f"{datetime.now().isoformat()} {msg}\n")


def parse_recurrence_rule(rrule: str, start_dt: datetime) -> dict:
    """Convert RRULE string to Graph API recurrence format."""
    # Parse components from rrule like "FREQ=WEEKLY;BYDAY=MO"
    parts = dict(p.split('=') for p in rrule.split(';'))
    freq = parts.get('FREQ', 'WEEKLY')
    byday = parts.get('BYDAY')

    # Map frequency to Graph API pattern type
    pattern_type_map = {
        'DAILY': 'daily',
        'WEEKLY': 'weekly',
        'MONTHLY': 'absoluteMonthly',
        'YEARLY': 'absoluteYearly',
    }

    pattern = {
        'type': pattern_type_map.get(freq, 'weekly'),
        'interval': 1,
    }

    # Add days of week for weekly recurrence
    if freq == 'WEEKLY' and byday:
        day_map = {
            'MO': 'monday', 'TU': 'tuesday', 'WE': 'wednesday',
            'TH': 'thursday', 'FR': 'friday', 'SA': 'saturday', 'SU': 'sunday'
        }
        days = [day_map.get(d, 'monday') for d in byday.split(',')]
        pattern['daysOfWeek'] = days
        pattern['firstDayOfWeek'] = 'monday'

    # Set a reasonable end date (1 year from start)
    end_date = start_dt + timedelta(days=365)

    return {
        'pattern': pattern,
        'range': {
            'type': 'endDate',
            'startDate': start_dt.strftime('%Y-%m-%d'),
            'endDate': end_date.strftime('%Y-%m-%d'),
        }
    }


def create_event_graph_api(event: dict) -> dict:
    """Create event via Microsoft Graph API using m365auth."""
    import urllib.request
    import urllib.error

    # Get access token via refresh-token CLI (pipx-installed m365auth)
    # Use full path since Alfred doesn't have ~/.local/bin in PATH
    refresh_token_paths = [
        os.path.expanduser('~/.local/bin/refresh-token'),
        '/usr/local/bin/refresh-token',
        'refresh-token',  # fallback to PATH
    ]

    refresh_token_cmd = None
    for path in refresh_token_paths:
        if os.path.exists(path) or path == 'refresh-token':
            refresh_token_cmd = path
            break

    try:
        result = subprocess.run(
            [refresh_token_cmd, '--profile', 'calendar'],
            capture_output=True,
            text=True,
            check=True
        )
        token = result.stdout.strip()
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Failed to get access token: {e.stderr}")
    except FileNotFoundError:
        raise RuntimeError("refresh-token command not found. Install m365auth: pipx install m365auth")

    if not token:
        raise RuntimeError("Empty access token returned")

    title = event.get('title', 'Event')
    flags = event.get('flags', [])

    # Determine showAs status
    if 'wfh' in flags:
        show_as = 'workingElsewhere'
    elif 'ooo' in flags or 'outofoffice' in flags:
        show_as = 'oof'
    elif 'tentative' in flags or event.get('tentative'):
        show_as = 'tentative'
    elif 'free' in flags:
        show_as = 'free'
    else:
        show_as = 'busy'

    # Build event data
    if event.get('all_day'):
        dt = datetime.fromisoformat(event.get('date'))
        event_data = {
            'subject': title,
            'isAllDay': True,
            'start': {
                'dateTime': dt.strftime('%Y-%m-%dT00:00:00'),
                'timeZone': 'Europe/London'
            },
            'end': {
                'dateTime': (dt + timedelta(days=1)).strftime('%Y-%m-%dT00:00:00'),
                'timeZone': 'Europe/London'
            },
            'showAs': show_as
        }
        start_dt = dt
    else:
        date_iso = event.get('date')
        start_time = event.get('start_time', '09:00')
        end_time = event.get('end_time', '09:30')

        dt = datetime.fromisoformat(date_iso)
        start_h, start_m = map(int, start_time.split(':'))
        end_h, end_m = map(int, end_time.split(':'))

        start_dt = dt.replace(hour=start_h, minute=start_m)
        end_dt = dt.replace(hour=end_h, minute=end_m)

        # Handle overnight events
        if end_dt <= start_dt:
            end_dt = end_dt + timedelta(days=1)

        event_data = {
            'subject': title,
            'start': {
                'dateTime': start_dt.strftime('%Y-%m-%dT%H:%M:%S'),
                'timeZone': 'Europe/London'
            },
            'end': {
                'dateTime': end_dt.strftime('%Y-%m-%dT%H:%M:%S'),
                'timeZone': 'Europe/London'
            },
            'showAs': show_as
        }

    # Add location if specified
    if event.get('location'):
        event_data['location'] = {'displayName': event['location']}

    # Build body content from notes and URL
    url = event.get('url')
    notes = event.get('notes')

    # Set online meeting URL (Outlook displays this automatically)
    if url:
        event_data['onlineMeetingUrl'] = url
    elif 'zoom' in flags and ZOOM_URL:
        event_data['onlineMeetingUrl'] = ZOOM_URL

    # Only add notes to body (URL is shown via onlineMeetingUrl)
    if notes:
        event_data['body'] = {
            'contentType': 'text',
            'content': notes
        }

    # Add recurrence if specified
    if event.get('recurrence'):
        event_data['recurrence'] = parse_recurrence_rule(event['recurrence'], start_dt)

    # Add reminders/alerts
    alerts = event.get('alerts')
    if alerts:
        event_data['isReminderOn'] = True
        # Graph API only supports one reminder, use the earliest
        event_data['reminderMinutesBeforeStart'] = min(alerts)

    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }

    log(f"Graph API event_data: {event_data}")

    # Use urllib (stdlib) instead of requests
    data = json.dumps(event_data).encode('utf-8')
    req = urllib.request.Request(
        'https://graph.microsoft.com/v1.0/me/calendar/events',
        data=data,
        headers=headers,
        method='POST'
    )

    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            response_data = response.read().decode('utf-8')
            log(f"Graph API response: {response.status} {response_data[:500]}")
            return json.loads(response_data)
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        log(f"Graph API error: {e.code} {error_body}")
        raise RuntimeError(f"Graph API error {e.code}: {error_body}")


def tz_offset_hours(tz: str) -> int:
    """Get UTC offset in hours for a timezone."""
    TIMEZONES = {
        "GMT": 0, "UTC": 0, "LON": 0,
        "WET": 0, "WEST": 1,
        "CET": 1, "CEST": 2,
        "EET": 2, "EEST": 3,
        "ET": -5, "EST": -5, "EDT": -4,
        "CT": -6, "CST": -6, "CDT": -5,
        "MT": -7, "MST": -7, "MDT": -6,
        "PT": -8, "PST": -8, "PDT": -7,
        "NYC": -5, "CHI": -6, "DEN": -7, "LA": -8,
        "IST": 5.5, "JST": 9, "AEST": 10, "AEDT": 11,
    }
    return TIMEZONES.get(tz.upper(), 0)


def convert_to_local(date_str: str, time_str: str, from_tz: str) -> datetime:
    """Convert a date/time from a given timezone to local time."""
    # Parse the date and time
    dt = datetime.fromisoformat(date_str)
    hours, minutes = map(int, time_str.split(':'))
    dt = dt.replace(hour=hours, minute=minutes)

    # Get local UTC offset (rough approximation - assumes UK/GMT for simplicity)
    # For proper handling, would need pytz or zoneinfo
    local_offset = 0  # Adjust if needed

    if from_tz:
        source_offset = tz_offset_hours(from_tz)
        # Convert: subtract source offset, add local offset
        from datetime import timedelta
        dt = dt - timedelta(hours=source_offset) + timedelta(hours=local_offset)

    return dt


def build_applescript(event: dict) -> str:
    """Build AppleScript to create the calendar event."""
    calendar = event.get('calendar', 'Calendar')
    title = event.get('title', 'Event')

    # Escape quotes and backslashes in title
    title = title.replace('\\', '\\\\').replace('"', '\\"')

    if event.get('all_day'):
        # All-day event - needs both start and end date
        dt = datetime.fromisoformat(event.get('date'))
        return f'''
set startDate to current date
set day of startDate to {dt.day}
set month of startDate to {dt.month}
set year of startDate to {dt.year}
set hours of startDate to 0
set minutes of startDate to 0
set seconds of startDate to 0

set endDate to current date
set day of endDate to {dt.day}
set month of endDate to {dt.month}
set year of endDate to {dt.year}
set hours of endDate to 23
set minutes of endDate to 59
set seconds of endDate to 59

tell application "Calendar"
    tell calendar "{calendar}"
        make new event with properties {{summary:"{title}", start date:startDate, end date:endDate, allday event:true{get_event_extras(event)}}}
    end tell
end tell
'''
    else:
        # Timed event
        date_iso = event.get('date')
        start_time = event.get('start_time', '09:00')
        end_time = event.get('end_time', '09:30')
        start_tz = event.get('start_tz')
        end_tz = event.get('end_tz')

        # Convert times if timezone specified
        if start_tz:
            start_dt = convert_to_local(date_iso, start_time, start_tz)
        else:
            dt = datetime.fromisoformat(date_iso)
            hours, minutes = map(int, start_time.split(':'))
            start_dt = dt.replace(hour=hours, minute=minutes)

        if end_tz:
            end_dt = convert_to_local(date_iso, end_time, end_tz)
        elif start_tz:
            end_dt = convert_to_local(date_iso, end_time, start_tz)
        else:
            dt = datetime.fromisoformat(date_iso)
            hours, minutes = map(int, end_time.split(':'))
            end_dt = dt.replace(hour=hours, minute=minutes)

        # Handle end time being on next day (e.g., 23:00-01:00)
        if end_dt <= start_dt:
            from datetime import timedelta
            end_dt = end_dt + timedelta(days=1)

        return f'''
set startDate to current date
set day of startDate to {start_dt.day}
set month of startDate to {start_dt.month}
set year of startDate to {start_dt.year}
set hours of startDate to {start_dt.hour}
set minutes of startDate to {start_dt.minute}
set seconds of startDate to 0

set endDate to current date
set day of endDate to {end_dt.day}
set month of endDate to {end_dt.month}
set year of endDate to {end_dt.year}
set hours of endDate to {end_dt.hour}
set minutes of endDate to {end_dt.minute}
set seconds of endDate to 0

tell application "Calendar"
    tell calendar "{calendar}"
        make new event with properties {{summary:"{title}", start date:startDate, end date:endDate{get_event_extras(event)}}}
    end tell
end tell
'''


def build_text_summary(event: dict) -> str:
    """Build a text summary for clipboard."""
    title = event.get('title', 'Event')
    date_str = event.get('date_applescript', '')

    if event.get('all_day'):
        return f"{title} - {date_str} (all day) - {event.get('calendar', 'Calendar')}"

    start_time = event.get('start_time', '')
    end_time = event.get('end_time', '')
    tz_info = ''
    if event.get('start_tz'):
        tz_info = f" {event['start_tz']}"
        if event.get('end_tz') and event['end_tz'] != event['start_tz']:
            tz_info = f" {event['start_tz']}-{event['end_tz']}"

    return f"{title} - {date_str} {start_time}-{end_time}{tz_info} - {event.get('calendar', 'Calendar')}"


def notify(title: str, message: str, sound: bool = True):
    """Show macOS notification."""
    # Escape quotes and truncate
    message = message.replace('"', '\\"').replace('\n', ' ')[:100]
    title = title.replace('"', '\\"')

    # Try terminal-notifier first (more reliable in Alfred context)
    terminal_notifier = '/opt/homebrew/bin/terminal-notifier'
    if os.path.exists(terminal_notifier):
        args = [terminal_notifier, '-title', title, '-message', message, '-group', 'alfred-cal']
        if sound:
            args.extend(['-sound', 'default'])
        result = subprocess.run(args, capture_output=True)
        log(f"terminal-notifier result: {result.returncode}")
        return

    # Fallback to AppleScript
    sound_str = 'sound name "default"' if sound else ''
    script = f'display notification "{message}" with title "{title}" {sound_str}'
    result = subprocess.run(['osascript', '-e', script], capture_output=True, text=True)
    log(f"osascript notify result: {result.returncode} stderr={result.stderr}")


def get_available_calendars() -> list:
    """Get list of available calendar names."""
    try:
        result = subprocess.run(
            ['osascript', '-e', 'tell application "Calendar" to get name of calendars'],
            capture_output=True, text=True, check=True
        )
        return [c.strip() for c in result.stdout.split(',')]
    except:
        return []


# Calendar aliases - loaded from external config
import os

def load_config() -> dict:
    """Load calendar config from external file."""
    config_paths = [
        os.path.expanduser('~/code/dotfiles_private/config/alfred/cal-entry-config.json'),
        os.path.expanduser('~/.config/cal-entry/config.json'),
        os.path.join(os.path.dirname(__file__), 'config.json'),
    ]

    for path in config_paths:
        if os.path.exists(path):
            try:
                with open(path) as f:
                    return json.load(f)
            except:
                pass

    # Fallback defaults
    return {
        'calendar_aliases': {
            'work': 'Calendar',
            'personal': 'Personal',
        },
        'default_calendar': 'Work'
    }

CONFIG = load_config()
CALENDAR_ALIASES = CONFIG.get('calendar_aliases', {})
ZOOM_URL = CONFIG.get('zoom_url', '')
# Calendars that should use Outlook instead of Apple Calendar
OUTLOOK_CALENDARS = CONFIG.get('outlook_calendars', ['Calendar', 'Work'])


def build_outlook_applescript(event: dict) -> str:
    """Build AppleScript to create event in Microsoft Outlook."""
    calendar = event.get('calendar', 'Calendar')
    title = event.get('title', 'Event')
    title = title.replace('\\', '\\\\').replace('"', '\\"')
    flags = event.get('flags', [])

    # Show As: busy, free, tentative, out of office (working elsewhere not available via AppleScript)
    if 'wfh' in flags or 'free' in flags:
        show_as = 'free'
    elif 'tentative' in flags or event.get('tentative'):
        show_as = 'tentative'
    elif 'ooo' in flags or 'outofoffice' in flags:
        show_as = 'out of office'
    else:
        show_as = 'busy'

    # URL for zoom etc
    url_prop = ''
    if 'zoom' in flags and ZOOM_URL:
        url_prop = f', content:"{ZOOM_URL}"'

    # Location
    location_prop = ''
    location = event.get('location')
    if location:
        location = location.replace('"', '\\"')
        location_prop = f', location:"{location}"'

    if event.get('all_day'):
        dt = datetime.fromisoformat(event.get('date'))
        return f'''
tell application "Microsoft Outlook"
    set targetCal to calendar "{calendar}"
    make new calendar event at targetCal with properties {{subject:"{title}", start time:date "{dt.strftime("%A, %d %B %Y")} 00:00:00", end time:date "{dt.strftime("%A, %d %B %Y")} 23:59:59", all day flag:true, free busy status:{show_as}{location_prop}{url_prop}}}
end tell
'''
    else:
        date_iso = event.get('date')
        start_time = event.get('start_time', '09:00')
        end_time = event.get('end_time', '09:30')
        start_tz = event.get('start_tz')
        end_tz = event.get('end_tz')

        # Convert times if timezone specified
        if start_tz:
            start_dt = convert_to_local(date_iso, start_time, start_tz)
        else:
            dt = datetime.fromisoformat(date_iso)
            hours, minutes = map(int, start_time.split(':'))
            start_dt = dt.replace(hour=hours, minute=minutes)

        if end_tz:
            end_dt = convert_to_local(date_iso, end_time, end_tz)
        elif start_tz:
            end_dt = convert_to_local(date_iso, end_time, start_tz)
        else:
            dt = datetime.fromisoformat(date_iso)
            hours, minutes = map(int, end_time.split(':'))
            end_dt = dt.replace(hour=hours, minute=minutes)

        if end_dt <= start_dt:
            from datetime import timedelta
            end_dt = end_dt + timedelta(days=1)

        start_str = start_dt.strftime("%A, %d %B %Y %H:%M:%S")
        end_str = end_dt.strftime("%A, %d %B %Y %H:%M:%S")

        return f'''
tell application "Microsoft Outlook"
    set targetCal to calendar "{calendar}"
    make new calendar event at targetCal with properties {{subject:"{title}", start time:date "{start_str}", end time:date "{end_str}", free busy status:{show_as}{location_prop}{url_prop}}}
end tell
'''


def get_event_extras(event: dict) -> str:
    """Get additional AppleScript properties for the event."""
    extras = []
    flags = event.get('flags', [])

    # Add zoom/meet/teams URL to notes
    if 'zoom' in flags and ZOOM_URL:
        extras.append(f', url:"{ZOOM_URL}"')

    # Add location if specified
    location = event.get('location')
    if location:
        location = location.replace('"', '\\"')
        extras.append(f', location:"{location}"')

    return ''.join(extras)


def find_calendar(requested: str, available: list) -> str:
    """Find best matching calendar name (case-insensitive, with aliases)."""
    requested_lower = requested.lower()

    # Check aliases first
    if requested_lower in CALENDAR_ALIASES:
        return CALENDAR_ALIASES[requested_lower]

    # Exact match (case-insensitive)
    for cal in available:
        if cal.lower() == requested_lower:
            return cal

    # Partial match
    for cal in available:
        if requested_lower in cal.lower():
            return cal

    # Default to first calendar or 'Calendar'
    return available[0] if available else 'Calendar'


def main():
    log(f"=== Starting cal_action ===")
    log(f"argv: {sys.argv}")

    if len(sys.argv) < 2:
        notify("Calendar Error", "No event data provided", sound=True)
        return

    try:
        event = json.loads(sys.argv[1])
        log(f"Parsed event: {event}")
    except json.JSONDecodeError as e:
        log(f"JSON decode error: {e}")
        notify("Calendar Error", f"Invalid JSON: {e}", sound=True)
        return

    # Handle copy-only mode
    if event.get('copy_only'):
        summary = build_text_summary(event)
        subprocess.run(['pbcopy'], input=summary.encode(), check=True)
        subprocess.run(['open', '-a', 'Calendar'], check=True)
        notify("Copied to Clipboard", summary, sound=False)
        return

    # Find matching calendar
    available_calendars = get_available_calendars()
    log(f"Available calendars: {available_calendars}")
    requested_calendar = event.get('calendar', 'Calendar')
    matched_calendar = find_calendar(requested_calendar, available_calendars)
    log(f"Requested: {requested_calendar} -> Matched: {matched_calendar}")
    event['calendar'] = matched_calendar

    # Choose calendar app based on calendar name
    use_outlook = matched_calendar in OUTLOOK_CALENDARS
    log(f"OUTLOOK_CALENDARS: {OUTLOOK_CALENDARS}, use_outlook: {use_outlook}")

    try:
        title = event.get('title', 'Event')
        date_str = datetime.fromisoformat(event.get('date')).strftime('%a %d %b')

        if use_outlook:
            # Use Microsoft Graph API for Outlook calendars
            log("Using Graph API for Outlook calendar")
            result = create_event_graph_api(event)
            log(f"Graph API result: {result.get('id', 'no id')}")
        else:
            # Use AppleScript for Apple Calendar
            script = build_applescript(event)
            log(f"AppleScript:\n{script}")
            result = subprocess.run(
                ['osascript', '-e', script],
                capture_output=True,
                text=True,
                check=True
            )
            log(f"osascript stdout: {result.stdout}")
            log(f"osascript stderr: {result.stderr}")

        if event.get('all_day'):
            details = f"{title}\n{date_str} (all day) • {matched_calendar}"
        else:
            time_str = f"{event.get('start_time')}-{event.get('end_time')}"
            details = f"{title}\n{date_str} {time_str} • {matched_calendar}"
        log(f"Success: {details}")
        notify("Event Created", details, sound=False)

        # Open Calendar if requested (e.g., to add invitees)
        if event.get('open_calendar'):
            app = 'Microsoft Outlook' if use_outlook else 'Calendar'
            subprocess.run(['open', '-a', app], check=True)
    except subprocess.CalledProcessError as e:
        error_msg = e.stderr.strip() if e.stderr else "Unknown error"
        log(f"CalledProcessError: {e.returncode} - {error_msg}")
        log(f"stdout: {e.stdout}")
        notify("Calendar Error", error_msg, sound=True)
    except Exception as e:
        log(f"Exception: {type(e).__name__}: {e}")
        notify("Calendar Error", str(e), sound=True)


if __name__ == '__main__':
    main()
