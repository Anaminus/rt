
--@sec: Style
--@def: type Style
--@doc: Style manages the properties of an object by applying values according
-- to a particular Theme.
local Style = {__index={}}

--@sec: Style.new
--@ord: -1
--@def: Style.new(theme: Theme): Style
--@doc: new returns a new Style that applies styles according to *theme*.
local function new(theme)
	assert(theme, "Theme expected")
	local self = setmetatable({
		theme = theme,
		defs = {},
		objects = {},
	}, Style)
	return self
end

local function updateProperty(self, object, property)
	local state = self.objects[object]
	local map = state.map
	if type(map) == "string" then
		map = self.def[map]
	end
	if type(map) == "table" then
		local value = self.theme:Field(map[property], state.flagbits)
		if value ~= nil then
			object[property] = value
		end
	end
end

local function updateObject(self, object)
	local theme = self.theme
	local state = self.objects[object]
	local flags = state.flagbits
	local map = state.map
	if type(map) == "string" then
		map = self.def[map]
	end
	if type(map) == "table" then
		for property, field in pairs(map) do
			local value = theme:Field(field, flags)
			if value ~= nil then
				object[property] = value
			end
		end
	end
end

local function updateAll(self)
	local theme = self.theme
	for object, state in pairs(self.objects) do
		local flags = state.flagbits
		local map = state.map
		if type(map) == "string" then
			map = self.def[map]
		end
		if type(map) == "table" then
			for property, field in pairs(map) do
				local value = theme:Field(field, flags)
				if value ~= nil then
					object[property] = value
				end
			end
		end
	end
end

--@sec: Style.Define
--@def: Style:Define(name: string, map: Dictionary<string>?, update: boolean?)
--@doc: Define assigns to *name* a set of property names mapped to theme fields.
-- If *update* is true, then all objects attached to the style are updated.
function Style.__index:Define(name, map, update)
	assert(type(name) == "string")
	assert(map == nil or type(map) == "table")
	if type(map) == "table" then
		local m = {}
		for k, v in pairs(map) do
			if type(k) == "string" and type(v) == "string" then
				m[k] = v
			end
		end
		self.defs[name] = m
	else
		self.defs[name] = nil
	end
	if update == true then
		updateAll(self)
	end
end

--@sec: Style.Attach
--@def: Style:Attach(object: Instance|string, map: string|Dictionary<string|Dictionary<string>>, update: boolean?): Instance
--@doc: Attach attaches *map* to *object*. If *object* is a string, then a new
-- instance of the given class will be created. If *map* is a string, then it
-- indicates the name of a definition. Otherwise, it must be a table of property
-- names mapped to theme fields. If *update* is true or unspecified, then the
-- object will be updated. Returns the object.
function Style.__index:Attach(object, map, update)
	assert(type(map) == "string" or type(map) == "table")
	local state = self.objects[object]
	if state == nil then
		state = {
			flags = {},
			flaglist = {},
			flagbits = 0,
			map = nil,
		}
		self.objects[object] = state
	end
	if type(map) == "string" then
		state.map = map
	else
		local m = {}
		for k, v in pairs(map) do
			local tv = type(v)
			if type(k) == "string" and (tv == "string" or tv == "table" or tv == "function") then
				m[k] = v
			end
		end
		state.map = m
	end
	if update == true or update == nil then
		updateObject(self, object)
	end
	return object
end

--@sec: Style.Detach
--@def: Style:Detach(object: Instance)
--@doc: Detach removes the association of the object.
function Style.__index:Detach(object)
	self.objects[object] = nil
end

--@sec: Style.Update
--@def: Style:Update(object: Instance?, property: string?)
--@doc: Update updates the properties of all attached objects. If *object* is
-- specified, then only that attached object is updated. If *property* is also
-- specified, then only that property of *object* is updated.
function Style.__index:Update(object, property)
	if self.objects[object] then
		if type(property) == "string" then
			updateProperty(self, object, property)
			return
		end
		updateObject(self, object)
		return
	end
	updateAll(self)
end

--@sec: Style.Theme
--@def: Style:Theme(): Theme
--@doc: Theme returns the current theme used by the Style.
function Style.__index:Theme()
	return self.theme
end

--@sec: Style.SetTheme
--@def: Style:SetTheme(theme: Theme, update: boolean?)
--@doc: SetTheme sets the current theme used by the Style. If *update* is true
-- or unspecified, then all attached objects will be updated.
function Style.__index:SetTheme(theme, update)
	assert(theme, "Theme expected")
	self.theme = theme
	for _, state in pairs(self.objects) do
		state.flagbits = self.theme:Flags(state.flaglist)
	end
	if update == true or update == nil then
		updateAll(self)
	end
end

--@sec: Style.Flags
--@def: Style:Flags(object: GuiObject): {string}?
--@doc: Flags returns the flags set for *object*. Returns nil if *object* is not
-- attached.
function Style.__index:Flags(object)
	local state = self.objects[object]
	if state == nil then
		return nil
	end
	local flags = {}
	for flag in pairs(state.flags) do
		table.insert(flags, flag)
	end
	table.sort(flags)
	return flags
end

--@sec: Style.HasFlags
--@def: Style:HasFlags(object: GuiObject, flags: ...string): bool
--@doc: HasFlags returns true when *object* has all of the given flags, and
-- false otherwise. Flags not known by the style's theme are ignored. Returns
-- false if *object* is not attached.
function Style.__index:HasFlags(object, ...)
	local state = self.objects[object]
	if state == nil then
		return false
	end
	for _, flag in ipairs({...}) do
		if type(flag) == "string" and flag ~= "Default" then
			if not state.flags[flag] then
				return false
			end
		end
	end
	return true
end

local function fastremove(t, value)
	local n = #t
	if n == 1 and t[1] == value then
		t[1] = nil
		return
	end
	local i = table.find(t, value)
	if i == nil then
		return
	end
	t[i] = t[n]
	t[n] = nil
end

local function fastinsert(t, value)
	if table.find(t, value) ~= nil then
		return
	end
	table.insert(t, value)
end

--@sec: Style.SetFlags
--@def: Style:SetFlags(object: GuiObject, flags: ...string)
--@doc: SetFlags sets each of the given flags on *object*. Does nothing if
-- *object* is not attached.
function Style.__index:SetFlags(object, ...)
	local state = self.objects[object]
	if state == nil then
		return
	end
	for _, flag in ipairs({...}) do
		if type(flag) == "string" and flag ~= "Default" then
			state.flags[flag] = true
			fastinsert(state.flaglist, flag)
		end
	end
	state.flagbits = self.theme:Flags(state.flaglist)
	updateObject(self, object)
end

--@sec: Style.UnsetFlags
--@def: Style:UnsetFlags()
--@doc: UnsetFlags unsets each of the given flags on *object*. Does nothing if
-- *object* is not attached.
function Style.__index:UnsetFlags(object, ...)
	local state = self.objects[object]
	if state == nil then
		return
	end
	for _, flag in ipairs({...}) do
		if type(flag) == "string" and flag ~= "Default" then
			state.flags[flag] = nil
			fastremove(state.flaglist, flag)
		end
	end
	state.flagbits = self.theme:Flags(state.flaglist)
	updateObject(self, object)
end

--@sec: Style.SetExclusiveFlags
--@def: Style:SetExclusiveFlags()
--@doc: SetExclusiveFlags unsets all of the flags on *object*, then sets each of
-- the given flags. Does nothing if *object* is not attached.
function Style.__index:SetExclusiveFlags(object, ...)
	local state = self.objects[object]
	if state == nil then
		return
	end
	state.flags = {}
	state.flaglist = {}
	for _, flag in ipairs({...}) do
		if type(flag) == "string" and flag ~= "Default" then
			state.flags[flag] = true
			fastinsert(state.flaglist, flag)
		end
	end
	state.flagbits = self.theme:Flags(state.flaglist)
	updateObject(self, object)
end

--@sec: Style.Destroy
--@def: Style:Destroy()
--@doc: Destroy releases any resources held by the object.
function Style.__index:Destroy()
	self.defs = {}
	self.objects = {}
end

return {
	new = new,
}
