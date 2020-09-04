# Style
[Style]: #user-content-style
```
type Style
```

Style manages the properties of an object by applying values according
to a particular Theme.

## Style.new
[Style.new]: #user-content-stylenew
```
Style.new(theme: Theme): Style
```

new returns a new Style that applies styles according to *theme*.

## Style.Attach
[Style.Attach]: #user-content-styleattach
```
Style:Attach(object: Instance|string, map: string|Dictionary<string|Dictionary<string>>, update: boolean?): Instance
```

Attach attaches *map* to *object*. If *object* is a string, then a new
instance of the given class will be created. If *map* is a string, then it
indicates the name of a definition. Otherwise, it must be a table of property
names mapped to theme fields. If *update* is true or unspecified, then the
object will be updated. Returns the object.

## Style.Define
[Style.Define]: #user-content-styledefine
```
Style:Define(name: string, map: Dictionary<string>?, update: boolean?)
```

Define assigns to *name* a set of property names mapped to theme fields.
If *update* is true, then all objects attached to the style are updated.

## Style.Destroy
[Style.Destroy]: #user-content-styledestroy
```
Style:Destroy()
```

Destroy releases any resources held by the object.

## Style.Detach
[Style.Detach]: #user-content-styledetach
```
Style:Detach(object: Instance)
```

Detach removes the association of the object.

## Style.Flags
[Style.Flags]: #user-content-styleflags
```
Style:Flags(object: GuiObject): {string}?
```

Flags returns the flags set for *object*. Returns nil if *object* is not
attached.

## Style.HasFlags
[Style.HasFlags]: #user-content-stylehasflags
```
Style:HasFlags(object: GuiObject, flags: ...string): bool
```

HasFlags returns true when *object* has all of the given flags, and
false otherwise. Flags not known by the style's theme are ignored. Returns
false if *object* is not attached.

## Style.SetExclusiveFlags
[Style.SetExclusiveFlags]: #user-content-stylesetexclusiveflags
```
Style:SetExclusiveFlags()
```

SetExclusiveFlags unsets all of the flags on *object*, then sets each of
the given flags. Does nothing if *object* is not attached.

## Style.SetFlags
[Style.SetFlags]: #user-content-stylesetflags
```
Style:SetFlags(object: GuiObject, flags: ...string)
```

SetFlags sets each of the given flags on *object*. Does nothing if
*object* is not attached.

## Style.SetTheme
[Style.SetTheme]: #user-content-stylesettheme
```
Style:SetTheme(theme: Theme, update: boolean?)
```

SetTheme sets the current theme used by the Style. If *update* is true
or unspecified, then all attached objects will be updated.

## Style.Theme
[Style.Theme]: #user-content-styletheme
```
Style:Theme(): Theme
```

Theme returns the current theme used by the Style.

## Style.UnsetFlags
[Style.UnsetFlags]: #user-content-styleunsetflags
```
Style:UnsetFlags()
```

UnsetFlags unsets each of the given flags on *object*. Does nothing if
*object* is not attached.

## Style.Update
[Style.Update]: #user-content-styleupdate
```
Style:Update(object: Instance?, property: string?)
```

Update updates the properties of all attached objects. If *object* is
specified, then only that attached object is updated. If *property* is also
specified, then only that property of *object* is updated.

