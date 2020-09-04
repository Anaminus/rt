# CheckBox
[CheckBox]: #user-content-checkbox
```
type CheckBox
```

CheckBox is a widget containing an interactive boolean state. Clicking
on the checkbox toggles the state between checked and unchecked.

The checkbox is able to have one of three states, each indicated by a
particular Lua value:
- true: The checkbox is checked.
- false: The checkbox is unchecked.
- nil: The checkbox is partially checked.

## CheckBox.new
[CheckBox.new]: #user-content-checkboxnew
```
CheckBox.new(state: bool?): CheckBox
```

new returns a new CheckBox with an initial state. *state* defaults to
false.

## CheckBox.Destroy
[CheckBox.Destroy]: #user-content-checkboxdestroy
```
CheckBox:Destroy()
```

Destroy releases the resources used by the object.

## CheckBox.Enabled
[CheckBox.Enabled]: #user-content-checkboxenabled
```
CheckBox:Enabled(): bool
```

Enabled returns whether or not the checkbox is enabled.

## CheckBox.Instance
[CheckBox.Instance]: #user-content-checkboxinstance
```
CheckBox:Instance(): Instance
```

Instance returns the GuiObject containing the checkbox.

## CheckBox.Label
[CheckBox.Label]: #user-content-checkboxlabel
```
CheckBox:Label(): GuiObject|nil
```

Label returns the label applied to the checkbox.

## CheckBox.SetEnabled
[CheckBox.SetEnabled]: #user-content-checkboxsetenabled
```
CheckBox:SetEnabled(enabled: bool)
```

SetEnabled sets whether the checkbox is enabled. While disabled, the
checkbox cannot be interacted with by the user. SetState will still set the
state as usual, and still fires the StateChanged event.

## CheckBox.SetLabel
[CheckBox.SetLabel]: #user-content-checkboxsetlabel
```
CheckBox:SetLabel(label: GuiObject|nil)
```

SetLabel sets the label applied to the checkbox.

## CheckBox.SetState
[CheckBox.SetState]: #user-content-checkboxsetstate
```
CheckBox:SetState(state: bool|nil)
```

SetState sets the state of the checkbox, updating the display, and
firing the StateChanged event. The checkbox may have one of three states:
- true: The checkbox is checked.
- false: The checkbox is unchecked.
- nil: The checkbox is partially checked.

## CheckBox.SetStyle
[CheckBox.SetStyle]: #user-content-checkboxsetstyle
```
CheckBox:SetStyle(style: Style)
```

SetStyle sets the style applied to the checkbox. The following theme
fields are used:

Field                      | Type    | Flags
---------------------------|---------|------
CheckBoxBoundsTransparency | number  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
CheckBoxImage              | string  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
CheckBoxSize               | Vector2 |
CheckedFieldBackground     | Color3  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
CheckedFieldBorder         | Color3  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
CheckedFieldIndicator      | Color3  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
Padding                    | Vector2 |

## CheckBox.State
[CheckBox.State]: #user-content-checkboxstate
```
CheckBox:State(): bool|nil
```

State returns the current state of the checkbox.
- true: The checkbox is checked.
- false: The checkbox is unchecked.
- nil: The checkbox is partially checked.

## CheckBox.StateChanged
[CheckBox.StateChanged]: #user-content-checkboxstatechanged
```
CheckBox.StateChanged(state: bool|nil)
```

The StateChanged event is fired after the state of the checkbox
changes.

## CheckBox.Style
[CheckBox.Style]: #user-content-checkboxstyle
```
CheckBox:Style(): Style
```

Style returns the current Style applied to the checkbox.

