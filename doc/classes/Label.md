# Label
[Label]: #user-content-label
```
type Label
```

Label is a widget that displays text.

## Label.new
[Label.new]: #user-content-labelnew
```
Label.new(text: string?): Label
```

new returns a new Label with initial text. *text* defaults to an empty
string.

## Label.Destroy
[Label.Destroy]: #user-content-labeldestroy
```
Label:Destroy()
```

Destroy releases the resources used by the object.

## Label.Enabled
[Label.Enabled]: #user-content-labelenabled
```
Label:Enabled(): bool
```

Enabled returns whether or not the label is enabled.

## Label.Instance
[Label.Instance]: #user-content-labelinstance
```
Label:Instance(): Instance
```

Instance returns the GuiObject containing the label.

## Label.SetEnabled
[Label.SetEnabled]: #user-content-labelsetenabled
```
Label:SetEnabled(enabled: bool)
```

SetEnabled sets whether the label is enabled.

## Label.SetStyle
[Label.SetStyle]: #user-content-labelsetstyle
```
Label:SetStyle(style: Style)
```

SetStyle sets the style applied to the label. The following theme fields
are used:

Field    | Type   | Flags
---------|--------|------
Font     | number | Disabled
FontSize | string | Disabled
MainText | Color3 | Disabled

## Label.Style
[Label.Style]: #user-content-labelstyle
```
Label:Style(): Style
```

Style returns the current Style applied to the label.

