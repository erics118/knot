# knot

simple notes app

## features

### shortcuts

show/hide the notes window with a global shortcut.
you can also close the window with `esc` or `cmd-w`

`cmd-q` quits the app

`cmd-,` opens settings

### title bar

shows the tab number and the first line of the tab.

### status bar

shows the number of characters or the number of words.
click on it to toggle between those.

### tabs

show the title bar in settings first, as the only indication of the tab is in
the title bar.

then navigate them with `cmd-{1-5}`, `cmd-[`, and `cmd-]`

## settings

### shortcut

choose the shortcut. defaults to `hyper-x`

shortcut behavior:
- focus or hide window
  - if the window is focused, it will hide the window
  - otherwise, (ie not focused, or hidden), it will show and focus the window
- show or hide window
  - if the window is shown (even if not focused), it will hide the window
  - otherwise, (ie the window is hidden), it will show and focus the window

### background color

requires a restart to update, because bugged

### title bar

the following options show/hide various things in the title bar.
- show close window button - show/hide the red traffic light button
- show minimize window button - show/hide the yellow traffic light button
- show zoom window button - show/hide the green traffic light button
- show window title - shows the title of the window

show title bar - has three options
- always
- on hover
- never

the title bar encompasses the traffic light and the window title.

### status bar

show status bar - has three options
- always
- on hover
- never
