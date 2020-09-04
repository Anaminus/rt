return function(rt)
--@sec: Properties
--@def: type Properties
--@doc: Properties implements a type with gettable and settable properties.
local Properties = {}

local propsIndex = newproxy(false)

--@sec: Properties[string] {Properties.__index}
--@ord: 1
--@def: Properties[name: string]: (value: any?)
--@doc: Indexing a Properties object will return the result of the Get callback
-- of the property corresponding to *name*. Throws an error if *name* is not a
-- valid property.
function Properties:__index(name)
	local prop = self[propsIndex][name]
	if prop == nil then
		error(string.format("%q is not a valid member", tostring(name)), 2)
	end
	return prop.Get()
end

--@sec: Properties[string] = value {Properties.__newindex}
--@ord: 1
--@def: Properties[name: string] = (value: any?)
--@doc: Newindexing a Properties object will call the Set callback of the
-- property corresponding to *name*, passing *value* as an argument. Throws an
-- error if *name* is not a valid property, or if Set is not defined for the
-- property.
function Properties:__newindex(name, value)
	local prop = self[propsIndex][name]
	if prop == nil then
		error(string.format("%q is not a valid member", tostring(name)), 2)
	end
	if prop.Set == nil then
		error(string.format("cannot set property %q", tostring(name)), 2)
	end
	if value == prop.Get() then
		return -- No change.
	end
	prop.Set(value)
end

--@sec: PropertyDefs
--@ord: 1
--@def: type PropertyDefs = {[string]: PropertyDef}
--@doc: PropertyDefs maps a property name to a property definition.

--@sec: PropertyDef
--@ord: 1
--@def:
-- type PropertyDef = {
-- 	Get: () -> any?,
-- 	Set: ((v: any?) -> ())?,
-- }
--@doc: PropertyDef defines functions called when a property is indexed.
--
-- The Get callback is called when getting the property. It is expected to
-- return the value of the property.
--
-- The Set callback is called when setting the property. If Set is nil, then
-- attempting to set the property will throw an error indicating that the
-- property is read-only. Set receives the new value of the property. Set is not
-- called if *v* is equal to the result of Get.

--@sec: Properties.new
--@ord: -1
--@def: Properties.new(defs: PropertyDefs): Properties
--@doc: new returns a new Properties.
local function new(defs)
	assert(type(defs) == "table", "table expected")
	local props = {}
	for name, def in pairs(defs) do
		if type(name) == "string" and type(def) == "table" then
			if type(def.Get) ~= "function" then
				continue
			end
			if def.Set ~= nil and type(def.Set) ~= "function" then
				continue
			end
			props[name] = {
				Get = def.Get,
				Set = def.Set,
			}
		end
	end
	return setmetatable({[propsIndex] = props}, Properties)
end

return {
	new = new,
}
end
