# Properties
[Properties]: #user-content-properties
```
type Properties
```

Properties implements a type with gettable and settable properties.

## Properties.new
[Properties.new]: #user-content-propertiesnew
```
Properties.new(defs: PropertyDefs): Properties
```

new returns a new Properties.

## Properties[string]
[Properties.__index]: #user-content-propertiesstring
```
Properties[name: string]: (value: any?)
```

Indexing a Properties object will return the result of the Get callback
of the property corresponding to *name*. Throws an error if *name* is not a
valid property.

## Properties[string] = value
[Properties.__newindex]: #user-content-propertiesstring--value
```
Properties[name: string] = (value: any?)
```

Newindexing a Properties object will call the Set callback of the
property corresponding to *name*, passing *value* as an argument. Throws an
error if *name* is not a valid property, or if Set is not defined for the
property.

# PropertyDef
[PropertyDef]: #user-content-propertydef
```
type PropertyDef = {
	Get: () -> any?,
	Set: ((v: any?) -> ())?,
}
```

PropertyDef defines functions called when a property is indexed.

The Get callback is called when getting the property. It is expected to
return the value of the property.

The Set callback is called when setting the property. If Set is nil, then
attempting to set the property will throw an error indicating that the
property is read-only. Set receives the new value of the property. Set is not
called if *v* is equal to the result of Get.

# PropertyDefs
[PropertyDefs]: #user-content-propertydefs
```
type PropertyDefs = {[string]: PropertyDef}
```

PropertyDefs maps a property name to a property definition.

