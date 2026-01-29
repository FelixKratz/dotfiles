# Alfred Calendar Quick Entry

Natural language calendar entry for Alfred with Microsoft Graph API support.

## Features

- Natural language parsing: `lunch at Starbucks tomorrow 2pm for 1 hour`
- Date formats: `friday`, `4 March`, `tomorrow`, `2026-03-04`
- Time formats: `3pm`, `14:00`, `noon`, time ranges `2pm-4pm`
- Duration: `for 2 hours`, `for 30 minutes`
- Location: `at Conference Room A` or `loc:"Long Location Name"`
- Calendar selection: `#work`, `/personal`, `@family`
- Alerts: `with 30min alert`, `alert 1 hour before`
- Notes & URLs: `notes: Bring laptop`, `url: https://zoom.us/j/123`
- Recurrence: `every monday`, `every day`
- Flags: `zoom`, `teams`, `tentative`, `free`, `wfh`, `ooo`

## Setup

### 1. Install m365auth (for Outlook/Exchange calendars)

```bash
pipx install m365auth
```

### 2. Configure OAuth2

Create an Azure AD app registration with `Calendars.ReadWrite` permission, then:

```bash
get-token --profile calendar \
  --client-id YOUR_CLIENT_ID \
  --tenant YOUR_TENANT_ID \
  --scopes "https://graph.microsoft.com/Calendars.ReadWrite"
```

This opens a browser for authentication and saves the refresh token.

### 3. Create config file

Create `~/code/dotfiles_private/config/alfred/cal-entry-config.json` or `~/.config/cal-entry/config.json`:

```json
{
  "calendar_aliases": {
    "work": "Calendar",
    "personal": "Personal"
  },
  "default_calendar": "Work",
  "zoom_url": "https://zoom.us/my/yourroom",
  "outlook_calendars": ["Calendar"]
}
```

- `outlook_calendars`: Calendars that use Graph API (Outlook/Exchange)
- Other calendars use Apple Calendar via AppleScript

### 4. Install workflow

Double-click `cal-entry.alfredworkflow` or run:

```bash
open config/alfred/workflows/cal-entry.alfredworkflow
```

## Examples

```
meeting at 2pm
lunch at Starbucks tomorrow 1pm
#work project review at Room 301 4 March 2pm for 2 hours
team sync every monday at 10am with 15min alert
zoom call tomorrow 3pm notes: Quarterly review
```

## Dependencies

- Python 3 (uses stdlib only)
- m365auth (for Graph API token refresh)
- Alfred 5 with Powerpack
