from helpers import *

bg = "#1e1e2e"
black = "#181926"
white = "#cad3f5"
grey = "#939ab7"
red = "#ed8796"
frost_green = "#94e2d5"
cyan = "#74c7ec"
green = "#a6e3a1"
yellow = "#f9e2af"
blue = "#89b4fa"
magenta = "#cba6f7"
orange = "#f5a97f"

BACKGROUND = bg
BAR_BACKGROUND = bg
WORKSPACES_BACKGROUND = bg
TODOS_BACKGROUND = bg

BORDER_DIM = white
BORDER_LIT = blue

BORDER_TITLE_DIM = grey, bg 
BORDER_TITLE_LIT = black, blue

SEARCH_COLOR = red # highlight color when searching
YANK_COLOR = blue # a color flash for yanking a todo/workspace/description
SAVE_ON_ESCAPE = True # whether to cancel the todo or save it when esc is pressed. `False` means cancel

WORKSPACE =  {
    "dim": grey,
    "highlight": white,
    "editing": orange,
    "pointer": " ",
    "children_hint": "(+{count})", 
}

COLUMN_ORDER = ["description", "due", "urgency"]  # order of columns for todo pane
TODO = {
    "color_todos": False, # this will color the todos based on their status (overdue: red, pending: yellow, done:green)
    "dim": grey, # style/color for unfocused todo
    "highlight": white, # style/color for focused todo when not editing
    "editing": orange, # style/color for focused todo when not editing
    "pointer": " ", # cursor pointer
    "due_icon": " ", # icon to use for due
    "effort_icon": "  ", # icon to use for effort
    "effort_color": yellow, # color to use for effort
    "recurrence_icon": "  ", # icon to use for recurrence
    "recurrence_color": green, # color to use for recurrence
    "tags_icon": "  ", # icon to use for tags
    "tags_seperator": "pipe",  # seperator for multiple tags (Options: icon, pipe, comma)
    "tags_color": red, # color for tags
    "completed_icon": f"[{green}]✓[/{green}] ", # icon for completed todo
    "pending_icon": f"[{yellow}][/{yellow}] ", # icon for pending todo
    "overdue_icon": f"[{red}][/{red}] ", # icon for overdue todo
    "urgency1_icon": "~", # icon for urgency 1 (lowest)
    "urgency2_icon": "", 
    "urgency3_icon": "",
    "urgency4_icon": "",
    
    # See workspace children hint for details
    # VARS
    # remaining: Todos remaining
    # done     : Todos done 
    # total    : Total todos
    "children_hint": " ({done}/{total})",
}

EMPTY_TODO = [
    "No tasks currently...",
]

pending_tasks_line = f"You have [{yellow}]{get_total_pending()}[/{yellow}] tasks [{yellow}] pending[/{yellow}], with [{yellow}]{get_pending_today()}[/{yellow}] due [{yellow}]today[/{yellow}] and [{red}]{get_total_overdue()}[/{red}] [{red}] overdue[/{red}]."
pending_tasks_tags = 6
pending_tasks_len = len(pending_tasks_line) - pending_tasks_tags*(2*len(yellow) + 5)

completed_today_line = f"So far [{green}]{get_total_completed()}[/{green}] tasks have been [{green}]✓ completed[/{green}], [{green}]{get_total_completed_today()}[/{green}] for today."
completed_today_tags = 3
completed_today_len = len(completed_today_line) - completed_today_tags*(2*len(yellow) + 5)

delta = pending_tasks_len - completed_today_len
longest_line = pending_tasks_len

ART = f"""
[{cyan}]  _{"_" * longest_line}_
 / {" " * longest_line} \\ [/{cyan}]
[{cyan}]||[/{cyan}] {pending_tasks_line} [{cyan}]||[/{cyan}]
[{cyan}]||[/{cyan}] {" " * longest_line} [{cyan}]||[/{cyan}]
[{cyan}]||[/{cyan}] {" " * (delta // 2)}{completed_today_line}{" " * (delta - delta // 2)} [{cyan}]||[/{cyan}]
[{cyan}] \\_{"_" * longest_line}_/
                                \\
                                 \\ [/{cyan}]
[{grey}]                                   ^__^
                                   (oo)\\_______
                                   (__)\\       )\\/\\
                                       ||----w |
                                       ||     ||[/{grey}]
"""

DASHBOARD = [ART]

def time():
    return tag(" ", get_time(), yellow)

status_icons = {
    "NORMAL": [" ", green],
    "INSERT": [" ", grey],
    "DATE": [" ", orange],
    "SEARCH": [" ", green],
    "SORT": [" ", magenta],
    "K PENDING": [" ", yellow],
}

def status(status):
    icon, color = status_icons[status]
    return colored(f" {icon} ", "r " + color) + " " + colored(f"{status}", "b " + color)

bar = {"A": [" ", status], "C": [time]}

keybindings = {
        "move down": "k",
        "shift down": "K",
        "move up": "l",
        "shift up": "L",
        "move to top": "gg",
        "exit": "q",
        "switch pane": "<tab>",
        "switch pane workspace": "j",
        "switch pane todo": "ö",
        "remove item": "dd",
        "edit due": "t",
        "toggle expand": "ä",
        "toggle expand parent": "Ä"
}
