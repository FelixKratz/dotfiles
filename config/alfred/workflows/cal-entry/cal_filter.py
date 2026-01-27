#!/usr/bin/env python3
"""
Alfred Script Filter for calendar quick entry.
Parses free-text input and returns Alfred JSON with parsed event details.
"""

import json
import re
import sys
from datetime import datetime, timedelta
from typing import Optional, Tuple

# Timezone mappings to UTC offset (hours)
TIMEZONES = {
    # Europe
    "GMT": 0, "UTC": 0, "LON": 0,
    "WET": 0, "WEST": 1,
    "CET": 1, "CEST": 2,
    "EET": 2, "EEST": 3,
    # Americas
    "ET": -5, "EST": -5, "EDT": -4,
    "CT": -6, "CST": -6, "CDT": -5,
    "MT": -7, "MST": -7, "MDT": -6,
    "PT": -8, "PST": -8, "PDT": -7,
    "NYC": -5, "CHI": -6, "DEN": -7, "LA": -8,
    # Others
    "IST": 5.5,  # India
    "JST": 9,    # Japan
    "AEST": 10,  # Australia Eastern
    "AEDT": 11,
}

# Calendar shortcuts
CALENDAR_PREFIXES = ['/', '@']

# Recognised flags
FLAGS = {
    'zoom': 'Zoom',
    'meet': 'Google Meet',
    'teams': 'Teams',
    'tentative': None,
    'free': None,
    'busy': None,
    'wfh': 'WFH',
    'travel': 'Travel',
    'elsewhere': None,
    'ooo': 'OOO',
    'outofoffice': 'OOO',
}

WEEKDAYS = {
    'mon': 0, 'monday': 0,
    'tue': 1, 'tuesday': 1,
    'wed': 2, 'wednesday': 2,
    'thu': 3, 'thursday': 3,
    'fri': 4, 'friday': 4,
    'sat': 5, 'saturday': 5,
    'sun': 6, 'sunday': 6,
}


def parse_date(token: str) -> Optional[datetime]:
    """Parse a date token, return datetime or None."""
    token_lower = token.lower()
    today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

    if token_lower == 'today':
        return today
    if token_lower == 'tomorrow':
        return today + timedelta(days=1)

    # Weekday
    if token_lower in WEEKDAYS:
        target_weekday = WEEKDAYS[token_lower]
        current_weekday = today.weekday()
        days_ahead = target_weekday - current_weekday
        if days_ahead <= 0:  # Target day is today or in past, go to next week
            days_ahead += 7
        return today + timedelta(days=days_ahead)

    # yyyy-mm-dd
    if re.match(r'^\d{4}-\d{2}-\d{2}$', token):
        try:
            return datetime.strptime(token, '%Y-%m-%d')
        except ValueError:
            return None

    # dd/mm or dd.mm
    match = re.match(r'^(\d{1,2})[./](\d{1,2})$', token)
    if match:
        day, month = int(match.group(1)), int(match.group(2))
        year = today.year
        try:
            result = datetime(year, month, day)
            if result < today:
                result = datetime(year + 1, month, day)
            return result
        except ValueError:
            return None

    return None


def parse_12h_time(time_str: str) -> Optional[Tuple[int, int]]:
    """Parse 12-hour time like 3pm, 7:30am. Returns (hour, minute) in 24h or None."""
    match = re.match(r'^(\d{1,2})(?::(\d{2}))?\s*(am|pm)$', time_str, re.IGNORECASE)
    if match:
        hour = int(match.group(1))
        minute = int(match.group(2)) if match.group(2) else 0
        is_pm = match.group(3).lower() == 'pm'
        if is_pm and hour != 12:
            hour += 12
        elif not is_pm and hour == 12:
            hour = 0
        return (hour, minute)
    return None


DEFAULT_DURATION_MINUTES = 50


def parse_time_range(token: str) -> Optional[Tuple[str, str]]:
    """Parse a time range token, return (start, end) times as HH:MM or None."""
    # Normalise separators: en-dash, arrow, 'to' -> hyphen
    normalised = re.sub(r'\s*(–|→|>|to)\s*', '-', token, flags=re.IGNORECASE)

    # Try 12-hour format range: 3pm-5pm, 7am-9am, 3:30pm-5pm
    match_12h = re.match(r'^(\d{1,2}(?::\d{2})?\s*(?:am|pm))-(\d{1,2}(?::\d{2})?\s*(?:am|pm))$', normalised, re.IGNORECASE)
    if match_12h:
        start = parse_12h_time(match_12h.group(1))
        end = parse_12h_time(match_12h.group(2))
        if start and end:
            return (f"{start[0]:02d}:{start[1]:02d}", f"{end[0]:02d}:{end[1]:02d}")

    # HH:MM-HH:MM or HH-HH (24-hour range)
    match = re.match(r'^(\d{1,2}):?(\d{2})?-(\d{1,2}):?(\d{2})?$', normalised)
    if match:
        start_h = int(match.group(1))
        start_m = int(match.group(2)) if match.group(2) else 0
        end_h = int(match.group(3))
        end_m = int(match.group(4)) if match.group(4) else 0
        return (f"{start_h:02d}:{start_m:02d}", f"{end_h:02d}:{end_m:02d}")

    # Single 12-hour time: 3pm, 7:30am -> add default duration
    single_12h = parse_12h_time(token)
    if single_12h:
        start_h, start_m = single_12h
        end_minutes = start_h * 60 + start_m + DEFAULT_DURATION_MINUTES
        end_h, end_m = end_minutes // 60, end_minutes % 60
        if end_h >= 24:
            end_h = 23
            end_m = 59
        return (f"{start_h:02d}:{start_m:02d}", f"{end_h:02d}:{end_m:02d}")

    # Single 24-hour time: 14:00, 9:30 -> add default duration
    match_single = re.match(r'^(\d{1,2}):(\d{2})$', token)
    if match_single:
        start_h = int(match_single.group(1))
        start_m = int(match_single.group(2))
        end_minutes = start_h * 60 + start_m + DEFAULT_DURATION_MINUTES
        end_h, end_m = end_minutes // 60, end_minutes % 60
        if end_h >= 24:
            end_h = 23
            end_m = 59
        return (f"{start_h:02d}:{start_m:02d}", f"{end_h:02d}:{end_m:02d}")

    return None


def parse_timezone_range(token: str) -> Optional[Tuple[str, Optional[str]]]:
    """Parse timezone token, return (start_tz, end_tz) or (tz, None) for single."""
    token_upper = token.upper()

    # Range: NYC-LON, PT-ET, etc.
    match = re.match(r'^([A-Z]+)\s*[-–→>]\s*([A-Z]+)$', token_upper)
    if match:
        start_tz, end_tz = match.group(1), match.group(2)
        if start_tz in TIMEZONES and end_tz in TIMEZONES:
            return (start_tz, end_tz)

    # Single timezone
    if token_upper in TIMEZONES:
        return (token_upper, None)

    return None


def parse_location(token: str) -> Optional[str]:
    """Parse location token like loc:"Some place" or loc:Someplace."""
    if token.lower().startswith('loc:'):
        loc = token[4:]
        # Remove surrounding quotes if present
        if loc.startswith('"') and loc.endswith('"'):
            loc = loc[1:-1]
        elif loc.startswith("'") and loc.endswith("'"):
            loc = loc[1:-1]
        return loc
    return None


def parse_calendar(token: str) -> Optional[str]:
    """Parse calendar selector like /Work or @Personal."""
    if token and token[0] in CALENDAR_PREFIXES:
        return token[1:]
    return None


def next_quarter_hour() -> datetime:
    """Return the next quarter hour from now."""
    now = datetime.now()
    minutes = now.minute
    # Round up to next quarter
    quarter = ((minutes // 15) + 1) * 15
    if quarter >= 60:
        now = now + timedelta(hours=1)
        quarter = 0
    return now.replace(minute=quarter, second=0, microsecond=0)


def format_date_for_applescript(dt: datetime) -> str:
    """Format date for AppleScript: 'Friday, January 17, 2026'."""
    return dt.strftime('%A, %B %d, %Y').replace(' 0', ' ')


def format_date_display(dt: datetime) -> str:
    """Format date for display: 'Fri 17 Jan 2026'."""
    return dt.strftime('%a %d %b %Y').replace(' 0', ' ')


def parse_input(query: str) -> dict:
    """Parse the full input query and return structured event data."""
    # Handle quoted location specially - extract it first
    location = None
    loc_match = re.search(r'loc:"([^"]+)"', query)
    if loc_match:
        location = loc_match.group(1)
        query = query[:loc_match.start()] + query[loc_match.end():]
    else:
        loc_match = re.search(r"loc:'([^']+)'", query)
        if loc_match:
            location = loc_match.group(1)
            query = query[:loc_match.start()] + query[loc_match.end():]

    tokens = query.split()

    # Check for WFH mode
    is_wfh = tokens and tokens[0].lower() == 'wfh'
    if is_wfh:
        tokens = tokens[1:]

    # Parse tokens
    date = None
    time_range = None
    start_tz = None
    end_tz = None
    calendar = None
    flags = []
    title_parts = []

    i = 0
    while i < len(tokens):
        token = tokens[i]
        token_lower = token.lower()

        # Calendar selector
        cal = parse_calendar(token)
        if cal:
            calendar = cal
            i += 1
            continue

        # Location (unquoted)
        loc = parse_location(token)
        if loc and not location:
            location = loc
            i += 1
            continue

        # Flags
        if token_lower in FLAGS:
            flags.append(token_lower)
            i += 1
            continue

        # Date
        parsed_date = parse_date(token)
        if parsed_date and not date:
            date = parsed_date
            i += 1
            continue

        # Time range
        parsed_time = parse_time_range(token)
        if parsed_time and not time_range:
            time_range = parsed_time
            i += 1
            continue

        # Timezone (check if it could be a range with next token)
        if i + 1 < len(tokens):
            combined = token + '-' + tokens[i + 1]
            tz_result = parse_timezone_range(combined)
            if tz_result and tz_result[1]:
                start_tz, end_tz = tz_result
                i += 2
                continue

        tz_result = parse_timezone_range(token)
        if tz_result:
            start_tz, end_tz = tz_result
            i += 1
            continue

        # Otherwise it's part of the title
        title_parts.append(token)
        i += 1

    # Build title
    title = ' '.join(title_parts) if title_parts else ('WFH' if is_wfh else 'Event')

    # Flags like zoom/meet/teams are handled by adding URL, no need to modify title

    # Apply location to title
    if location:
        title += f' at {location}'

    # Defaults
    if not date:
        date = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

    if is_wfh:
        # All-day event
        return {
            'title': 'WFH' if not title_parts else title,
            'date': date,
            'all_day': True,
            'calendar': calendar or 'Work',
            'flags': flags,
            'tentative': 'tentative' in flags,
        }

    # Timed event
    if not time_range:
        start_dt = next_quarter_hour()
        if start_dt.date() > date.date():
            # Next quarter hour is tomorrow, use the provided date
            start_dt = date.replace(hour=9, minute=0)
        else:
            start_dt = date.replace(hour=start_dt.hour, minute=start_dt.minute)
        end_dt = start_dt + timedelta(minutes=30)
        start_time = start_dt.strftime('%H:%M')
        end_time = end_dt.strftime('%H:%M')
    else:
        start_time, end_time = time_range

    return {
        'title': title,
        'date': date,
        'start_time': start_time,
        'end_time': end_time,
        'start_tz': start_tz,
        'end_tz': end_tz,
        'calendar': calendar or 'Work',
        'all_day': False,
        'flags': flags,
        'tentative': 'tentative' in flags,
        'location': location,
    }


def build_subtitle(event: dict) -> str:
    """Build Alfred subtitle showing parsed event."""
    date_str = format_date_display(event['date'])

    if event['all_day']:
        return f"All-day on {date_str} • {event['calendar']}"

    time_str = f"{event['start_time']}"
    if event.get('start_tz'):
        time_str += f" {event['start_tz']}"
    time_str += f" → {event['end_time']}"
    if event.get('end_tz'):
        time_str += f" {event['end_tz']}"
    elif event.get('start_tz'):
        time_str += f" {event['start_tz']}"

    return f"{date_str} • {time_str} • {event['calendar']}"


def main():
    query = sys.argv[1] if len(sys.argv) > 1 else ''

    if not query.strip():
        # Empty query - show help
        result = {
            'items': [{
                'title': 'Calendar Quick Entry',
                'subtitle': 'Type: title date time /calendar (e.g., "Meet John Fri 14-15 /Work")',
                'valid': False,
            }]
        }
        print(json.dumps(result))
        return

    try:
        event = parse_input(query)

        # Serialise date for JSON
        event_json = event.copy()
        event_json['date'] = event['date'].isoformat()
        event_json['date_applescript'] = format_date_for_applescript(event['date'])

        title_display = event['title']
        if event.get('tentative'):
            title_display += ' !!'

        result = {
            'items': [{
                'title': title_display,
                'subtitle': build_subtitle(event),
                'arg': json.dumps(event_json),
                'valid': True,
                'mods': {
                    'alt': {
                        'subtitle': f"Create as tentative • {build_subtitle(event)}",
                        'arg': json.dumps({**event_json, 'tentative': True}),
                        'valid': True,
                    },
                    'cmd': {
                        'subtitle': f"Copy to clipboard and open Calendar",
                        'arg': json.dumps({**event_json, 'copy_only': True}),
                        'valid': True,
                    },
                    'shift': {
                        'subtitle': f"Create and open Calendar (to add invitees)",
                        'arg': json.dumps({**event_json, 'open_calendar': True}),
                        'valid': True,
                    },
                },
            }]
        }
        print(json.dumps(result))

    except Exception as e:
        result = {
            'items': [{
                'title': 'Parse error',
                'subtitle': str(e),
                'valid': False,
            }]
        }
        print(json.dumps(result))


if __name__ == '__main__':
    main()
