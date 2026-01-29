#!/usr/bin/env python3
"""
Alfred Script Filter for calendar quick entry.
Parses free-text natural language input and returns Alfred JSON with parsed event details.

Inspired by alfred-natural-calendar, supports patterns like:
- "meeting at 2pm"
- "lunch at Starbucks tomorrow 1pm"
- "#work meeting at 2pm"
- "meeting tomorrow 2pm for 2 hours"
- "meeting at 3pm with 30min alert"
- "meeting 2pm url: https://zoom.us/j/123456 notes: Quarterly review"
- "team sync every monday at 10am"
"""

import json
import re
import sys
from datetime import datetime, timedelta
from typing import Optional, Tuple, List

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

# Calendar shortcuts - supports /, @, and # prefixes
CALENDAR_PREFIXES = ['/', '@', '#']

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

# Mapping for recurrence rules (iCal format)
WEEKDAY_ICAL = {
    'monday': 'MO', 'mon': 'MO',
    'tuesday': 'TU', 'tue': 'TU',
    'wednesday': 'WE', 'wed': 'WE',
    'thursday': 'TH', 'thu': 'TH',
    'friday': 'FR', 'fri': 'FR',
    'saturday': 'SA', 'sat': 'SA',
    'sunday': 'SU', 'sun': 'SU',
}

# Special time keywords
SPECIAL_TIMES = {
    'noon': (12, 0),
    'midday': (12, 0),
    'midnight': (0, 0),
    'morning': (9, 0),
    'afternoon': (14, 0),
    'evening': (18, 0),
}

# Duration patterns
DURATION_KEYWORDS = {'for', 'lasting', 'duration'}
DURATION_UNITS = {
    'h': 60, 'hr': 60, 'hrs': 60, 'hour': 60, 'hours': 60,
    'm': 1, 'min': 1, 'mins': 1, 'minute': 1, 'minutes': 1,
}

# Alert/reminder keywords
ALERT_KEYWORDS = {'alert', 'reminder', 'remind'}

# Month names
MONTHS = {
    'jan': 1, 'january': 1,
    'feb': 2, 'february': 2,
    'mar': 3, 'march': 3,
    'apr': 4, 'april': 4,
    'may': 5,
    'jun': 6, 'june': 6,
    'jul': 7, 'july': 7,
    'aug': 8, 'august': 8,
    'sep': 9, 'sept': 9, 'september': 9,
    'oct': 10, 'october': 10,
    'nov': 11, 'november': 11,
    'dec': 12, 'december': 12,
}

DEFAULT_DURATION_MINUTES = 50


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


def strip_ordinal(s: str) -> str:
    """Remove ordinal suffix (st, nd, rd, th) from a string."""
    s_lower = s.lower()
    for suffix in ('st', 'nd', 'rd', 'th'):
        if s_lower.endswith(suffix) and len(s_lower) > len(suffix):
            base = s_lower[:-len(suffix)]
            if base.isdigit():
                return base
    return s_lower


def parse_two_token_date(token1: str, token2: str) -> Optional[datetime]:
    """Parse two-token dates like '4 March' or 'March 4'."""
    today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    t1_clean = strip_ordinal(token1)
    t2_clean = strip_ordinal(token2)

    day = None
    month = None

    # Try "4 March" format (day month)
    if t1_clean.isdigit() and t2_clean in MONTHS:
        day = int(t1_clean)
        month = MONTHS[t2_clean]
    # Try "March 4" format (month day)
    elif t1_clean in MONTHS and t2_clean.isdigit():
        month = MONTHS[t1_clean]
        day = int(t2_clean)

    if day and month:
        year = today.year
        try:
            result = datetime(year, month, day)
            if result < today:
                result = datetime(year + 1, month, day)
            return result
        except ValueError:
            return None

    return None


def is_month_name(token: str) -> bool:
    """Check if token is a month name."""
    return token.lower() in MONTHS


def parse_time_word(time_str: str) -> Optional[Tuple[int, int]]:
    """Parse time words and 12-hour times. Returns (hour, minute) in 24h or None."""
    time_lower = time_str.lower()

    # "now" - current time
    if time_lower == 'now':
        now = datetime.now()
        return (now.hour, now.minute)

    # Special time keywords
    if time_lower in SPECIAL_TIMES:
        return SPECIAL_TIMES[time_lower]

    # 12-hour format: 3pm, 7:30am
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


def parse_12h_time(time_str: str) -> Optional[Tuple[int, int]]:
    """Alias for backwards compatibility."""
    return parse_time_word(time_str)


def parse_duration(tokens: list, start_idx: int) -> Optional[Tuple[int, int]]:
    """Parse duration like 'for 2 hours' or 'for 30 minutes'. Returns (minutes, tokens_consumed) or None."""
    if start_idx >= len(tokens):
        return None

    token = tokens[start_idx].lower()
    if token not in DURATION_KEYWORDS:
        return None

    # Expect: "for 2 hours" or "for 30 minutes" or "for 1.5h"
    if start_idx + 1 >= len(tokens):
        return None

    next_token = tokens[start_idx + 1].lower()

    # Try "for 2h" or "for 30m" format (combined number+unit)
    match = re.match(r'^(\d+(?:\.\d+)?)(h|hr|hrs|hour|hours|m|min|mins|minute|minutes)$', next_token)
    if match:
        value = float(match.group(1))
        unit = match.group(2)
        minutes = int(value * DURATION_UNITS.get(unit, 60))
        return (minutes, 2)

    # Try "for 2 hours" format (separate number and unit)
    if start_idx + 2 < len(tokens):
        try:
            value = float(next_token)
            unit_token = tokens[start_idx + 2].lower()
            if unit_token in DURATION_UNITS:
                minutes = int(value * DURATION_UNITS[unit_token])
                return (minutes, 3)
        except ValueError:
            pass

    # Try just a number (assume hours): "for 2"
    try:
        value = float(next_token)
        minutes = int(value * 60)
        return (minutes, 2)
    except ValueError:
        pass

    return None


def parse_alert(tokens: list, start_idx: int) -> Optional[Tuple[int, int]]:
    """Parse alert like 'with 30min alert' or 'alert 1 hour before'. Returns (minutes, tokens_consumed) or None."""
    if start_idx >= len(tokens):
        return None

    token = tokens[start_idx].lower()

    # Pattern 1: "with 30min alert" or "with 1 hour reminder"
    if token == 'with' and start_idx + 2 < len(tokens):
        next_token = tokens[start_idx + 1].lower()
        # Try combined format: "30min"
        match = re.match(r'^(\d+)\s*(min|mins|minute|minutes|h|hr|hrs|hour|hours)$', next_token)
        if match:
            value = int(match.group(1))
            unit = match.group(2)
            minutes = value * DURATION_UNITS.get(unit, 1)
            # Check for alert/reminder keyword
            if start_idx + 2 < len(tokens) and tokens[start_idx + 2].lower() in ALERT_KEYWORDS:
                return (minutes, 3)

        # Try separate format: "with 30 minutes alert"
        try:
            value = int(next_token)
            if start_idx + 3 < len(tokens):
                unit_token = tokens[start_idx + 2].lower()
                keyword = tokens[start_idx + 3].lower()
                if unit_token in DURATION_UNITS and keyword in ALERT_KEYWORDS:
                    minutes = value * DURATION_UNITS[unit_token]
                    return (minutes, 4)
            # "with 30 alert" (assume minutes)
            if start_idx + 2 < len(tokens) and tokens[start_idx + 2].lower() in ALERT_KEYWORDS:
                return (value, 3)
        except ValueError:
            pass

    # Pattern 2: "alert 30 minutes before" or "alert 1 hour"
    if token in ALERT_KEYWORDS and start_idx + 1 < len(tokens):
        next_token = tokens[start_idx + 1].lower()
        # Combined: "alert 30min"
        match = re.match(r'^(\d+)\s*(min|mins|minute|minutes|h|hr|hrs|hour|hours)$', next_token)
        if match:
            value = int(match.group(1))
            unit = match.group(2)
            minutes = value * DURATION_UNITS.get(unit, 1)
            # Check for optional "before"
            consumed = 2
            if start_idx + 2 < len(tokens) and tokens[start_idx + 2].lower() == 'before':
                consumed = 3
            return (minutes, consumed)

        # Separate: "alert 30 minutes before"
        try:
            value = int(next_token)
            if start_idx + 2 < len(tokens):
                unit_token = tokens[start_idx + 2].lower()
                if unit_token in DURATION_UNITS:
                    minutes = value * DURATION_UNITS[unit_token]
                    consumed = 3
                    if start_idx + 3 < len(tokens) and tokens[start_idx + 3].lower() == 'before':
                        consumed = 4
                    return (minutes, consumed)
        except ValueError:
            pass

    return None


def parse_recurrence(tokens: list, start_idx: int) -> Optional[Tuple[str, int]]:
    """Parse recurrence like 'every monday' or 'every day'. Returns (rrule, tokens_consumed) or None."""
    if start_idx >= len(tokens):
        return None

    token = tokens[start_idx].lower()
    if token != 'every':
        return None

    if start_idx + 1 >= len(tokens):
        return None

    next_token = tokens[start_idx + 1].lower()

    # "every day" or "daily"
    if next_token in ('day', 'daily'):
        return ('FREQ=DAILY', 2)

    # "every week" or "weekly"
    if next_token in ('week', 'weekly'):
        return ('FREQ=WEEKLY', 2)

    # "every month" or "monthly"
    if next_token in ('month', 'monthly'):
        return ('FREQ=MONTHLY', 2)

    # "every year" or "yearly" or "annually"
    if next_token in ('year', 'yearly', 'annually'):
        return ('FREQ=YEARLY', 2)

    # "every monday", "every tuesday", etc.
    if next_token in WEEKDAY_ICAL:
        return (f'FREQ=WEEKLY;BYDAY={WEEKDAY_ICAL[next_token]}', 2)

    return None


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
    """Parse calendar selector like /Work, @Personal, or #work."""
    if token and token[0] in CALENDAR_PREFIXES:
        cal = token[1:]
        # Handle quoted calendar names: #"My Calendar"
        if cal.startswith('"') and cal.endswith('"'):
            cal = cal[1:-1]
        elif cal.startswith("'") and cal.endswith("'"):
            cal = cal[1:-1]
        return cal
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


def extract_url(query: str) -> Tuple[Optional[str], str]:
    """Extract URL from query. Returns (url, remaining_query)."""
    # Pattern 1: explicit "url: https://..."
    match = re.search(r'\burl:\s*(https?://[^\s]+)', query, re.IGNORECASE)
    if match:
        url = match.group(1)
        query = query[:match.start()] + query[match.end():]
        return (url, query.strip())

    # Pattern 2: standalone URL
    match = re.search(r'\b(https?://[^\s]+)', query)
    if match:
        url = match.group(1)
        query = query[:match.start()] + query[match.end():]
        return (url, query.strip())

    return (None, query)


def extract_notes(query: str) -> Tuple[Optional[str], str]:
    """Extract notes from query. Returns (notes, remaining_query)."""
    # Pattern: "notes: ..." or "note: ..." - captures until end or next keyword
    match = re.search(r'\bnotes?:\s*(.+?)(?=\s+url:|\s+alert\b|\s+with\s+\d|\s*$)', query, re.IGNORECASE)
    if match:
        notes = match.group(1).strip()
        query = query[:match.start()] + query[match.end():]
        return (notes, query.strip())

    return (None, query)


def is_stop_word(token: str, token_lower: str) -> bool:
    """Check if token should stop location parsing."""
    # Check if it's a day number (1-31) that could be part of a date
    day_clean = strip_ordinal(token)
    is_day_number = day_clean.isdigit() and 1 <= int(day_clean) <= 31

    return (
        token_lower in FLAGS or
        token_lower in DURATION_KEYWORDS or
        token_lower in WEEKDAYS or
        token_lower in SPECIAL_TIMES or
        token_lower in ALERT_KEYWORDS or
        token_lower in MONTHS or
        is_day_number or
        token_lower in ('at', 'on', 'from', 'tomorrow', 'today', 'every', 'with') or
        parse_date(token) is not None or
        parse_time_word(token) is not None or
        parse_time_range(token) is not None or
        parse_calendar(token) is not None
    )


def parse_input(query: str) -> dict:
    """Parse the full input query and return structured event data.

    Supports natural language patterns:
    - "meeting at 3pm" or "lunch at noon"
    - "meeting for 2 hours" or "call for 30 minutes"
    - "lunch at Starbucks tomorrow 1pm"
    - "#work meeting at 2pm"
    - "meeting tomorrow 2pm for 2 hours with 30min alert"
    - "meeting 2pm url: https://zoom.us/j/123456 notes: Quarterly review"
    - "team sync every monday at 10am"
    """
    # Extract URL first (before tokenising)
    url, query = extract_url(query)

    # Extract notes
    notes, query = extract_notes(query)

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
    start_time = None
    end_time = None
    duration_minutes = None
    start_tz = None
    end_tz = None
    calendar = None
    recurrence = None
    alerts = []
    flags = []
    title_parts = []

    i = 0
    while i < len(tokens):
        token = tokens[i]
        token_lower = token.lower()

        # Calendar selector (#work, /Work, @Personal)
        cal = parse_calendar(token)
        if cal:
            calendar = cal
            i += 1
            continue

        # Location with loc: prefix (unquoted)
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

        # Recurrence: "every monday", "every day"
        recurrence_result = parse_recurrence(tokens, i)
        if recurrence_result and not recurrence:
            recurrence, consumed = recurrence_result
            i += consumed
            continue

        # Alert: "with 30min alert", "alert 1 hour before"
        alert_result = parse_alert(tokens, i)
        if alert_result:
            alert_minutes, consumed = alert_result
            alerts.append(alert_minutes)
            i += consumed
            continue

        # Two-token date: "4 March", "March 4"
        if not date and i + 1 < len(tokens):
            two_token_date = parse_two_token_date(token, tokens[i + 1])
            if two_token_date:
                date = two_token_date
                i += 2
                continue

        # Single-token date
        parsed_date = parse_date(token)
        if parsed_date and not date:
            date = parsed_date
            i += 1
            continue

        # "at" keyword - could be time or location
        if token_lower == 'at' and i + 1 < len(tokens):
            next_token = tokens[i + 1]
            # Check if next token is a time
            parsed_time = parse_time_word(next_token)
            if parsed_time:
                if not start_time:
                    start_time = f"{parsed_time[0]:02d}:{parsed_time[1]:02d}"
                i += 2
                continue
            # Check if it's a time range
            time_range = parse_time_range(next_token)
            if time_range:
                if not start_time:
                    start_time, end_time = time_range
                i += 2
                continue
            # Otherwise it's a location - collect words until next keyword
            if not location:
                loc_parts = []
                j = i + 1
                while j < len(tokens):
                    t = tokens[j]
                    t_lower = t.lower()
                    # Stop at keywords
                    if is_stop_word(t, t_lower):
                        break
                    loc_parts.append(t)
                    j += 1
                if loc_parts:
                    location = ' '.join(loc_parts)
                    i = j
                    continue
            i += 1
            continue

        # Duration: "for 2 hours", "for 30 minutes"
        duration_result = parse_duration(tokens, i)
        if duration_result and not duration_minutes:
            duration_minutes, consumed = duration_result
            i += consumed
            continue

        # Time range (with hyphen): 14:00-15:00, 3pm-5pm
        time_range = parse_time_range(token)
        if time_range and not start_time:
            start_time, end_time = time_range
            i += 1
            continue

        # Single time word: noon, 3pm, now (without "at")
        parsed_time = parse_time_word(token)
        if parsed_time and not start_time:
            start_time = f"{parsed_time[0]:02d}:{parsed_time[1]:02d}"
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
            'location': location,
            'url': url,
            'notes': notes,
            'recurrence': recurrence,
            'alerts': sorted(set(alerts)) if alerts else None,
        }

    # Calculate end time from duration if provided (overrides default duration)
    if start_time and duration_minutes:
        start_h, start_m = map(int, start_time.split(':'))
        end_total = start_h * 60 + start_m + duration_minutes
        end_h, end_m = end_total // 60, end_total % 60
        if end_h >= 24:
            end_h = 23
            end_m = 59
        end_time = f"{end_h:02d}:{end_m:02d}"

    # Apply default duration if we have start but no end
    if start_time and not end_time:
        start_h, start_m = map(int, start_time.split(':'))
        end_total = start_h * 60 + start_m + DEFAULT_DURATION_MINUTES
        end_h, end_m = end_total // 60, end_total % 60
        if end_h >= 24:
            end_h = 23
            end_m = 59
        end_time = f"{end_h:02d}:{end_m:02d}"

    # No time specified = all-day event
    if not start_time:
        return {
            'title': title,
            'date': date,
            'all_day': True,
            'calendar': calendar or 'Work',
            'flags': flags,
            'tentative': 'tentative' in flags,
            'location': location,
            'url': url,
            'notes': notes,
            'recurrence': recurrence,
            'alerts': sorted(set(alerts)) if alerts else None,
        }

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
        'url': url,
        'notes': notes,
        'recurrence': recurrence,
        'alerts': sorted(set(alerts)) if alerts else None,
    }


def build_subtitle(event: dict) -> str:
    """Build Alfred subtitle showing parsed event."""
    date_str = format_date_display(event['date'])

    if event['all_day']:
        parts = [f"All-day on {date_str}", event['calendar']]
    else:
        time_str = f"{event['start_time']}"
        if event.get('start_tz'):
            time_str += f" {event['start_tz']}"
        time_str += f" → {event['end_time']}"
        if event.get('end_tz'):
            time_str += f" {event['end_tz']}"
        elif event.get('start_tz'):
            time_str += f" {event['start_tz']}"
        parts = [date_str, time_str, event['calendar']]

    # Add indicators for extra features
    if event.get('recurrence'):
        parts.append('🔁')
    if event.get('alerts'):
        parts.append('🔔')
    if event.get('url'):
        parts.append('🔗')
    if event.get('location'):
        parts.append('📍')

    return ' • '.join(parts)


def main():
    query = sys.argv[1] if len(sys.argv) > 1 else ''

    if not query.strip():
        # Empty query - show help
        result = {
            'items': [{
                'title': 'Calendar Quick Entry',
                'subtitle': 'e.g., "lunch at Starbucks tomorrow 1pm" or "#work meeting at 2pm for 1 hour"',
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
