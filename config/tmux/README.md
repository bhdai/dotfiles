## Keybindings

keybinds of tmux-tilish

| Keybinding                                                                           | Description                                          |
| ------------------------------------------------------------------------------------ | ---------------------------------------------------- |
| <kbd>Alt</kbd> + <kbd>0</kbd>-<kbd>9</kbd>                                           | Switch to workspace number 0-9                       |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>0</kbd>-<kbd>9</kbd>                        | Move pane to workspace 0-9                           |
| <kbd>Alt</kbd> + <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd>                    | Move focus left/down/up/right                        |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> | Move pane left/down/up/right                         |
| <kbd>Alt</kbd> + <kbd>o</kbd>                                                        | Move focus cyclically                                |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>o</kbd>                                     | Move pane cyclically                                 |
| <kbd>Alt</kbd> + <kbd>Enter</kbd>                                                    | Create a new pane at "the end" of the current layout |
| <kbd>Alt</kbd> + <kbd>s</kbd>                                                        | Switch to layout: split then vsplit                  |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>s</kbd>                                     | Switch to layout: only split                         |
| <kbd>Alt</kbd> + <kbd>v</kbd>                                                        | Switch to layout: vsplit then split                  |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>v</kbd>                                     | Switch to layout: only vsplit                        |
| <kbd>Alt</kbd> + <kbd>t</kbd>                                                        | Switch to layout: fully tiled                        |
| <kbd>Alt</kbd> + <kbd>z</kbd>                                                        | Switch to layout: zoom (fullscreen)                  |
| <kbd>Alt</kbd> + <kbd>r</kbd>                                                        | Refresh current layout                               |
| <kbd>Alt</kbd> + <kbd>n</kbd>                                                        | Name current workspace                               |
| <kbd>Alt</kbd> + <kbd>d</kbd>                                                        | Application launcher (if enabled)                    |
| <kbd>Alt</kbd> + <kbd>p</kbd>                                                        | Project launcher (if enabled)                        |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>q</kbd>                                     | Quit (close) pane                                    |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>e</kbd>                                     | Exit (detach) `tmux`                                 |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>c</kbd>                                     | Reload config                                        |

The <kbd>Alt</kbd> + <kbd>0</kbd> and <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>0</kbd>
bindings are "smart": depending on `base-index`, they either act on workspace 0 or 10.
Moreover, if you press <kbd>Alt</kbd> + <kbd>3</kbd> to switch to workspace 3 and then
press it again, you will be sent back to the previous workspace you were using.
