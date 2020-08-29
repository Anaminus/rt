local function copyFields(fields)
	if type(fields) ~= "table" then
		return {}
	end
	local copy = {}
	for k, v in pairs(fields) do
		if type(v) ~= "table" then
			copy[k] = v
			continue
		end
		local c = {}
		for k, v in pairs(v) do
			c[k] = v
		end
		copy[k] = c
	end
	return copy
end

--@sec: Theme
--@def: type Theme
--@doc:
local Theme = {__index={}}

--@sec Theme.new
--@ord: -1
--@def: Theme.new(fields: ThemeFields): Theme
local function new(fields)
	assert(fields == nil or type(fields) == "table", "table expected")
	return setmetatable({
		fields = copyFields(fields),
	}, Theme)
end

--@sec: ThemeFields
--@ord: 1
--@def: type ThemeFields = {[string]: ThemeField|any}

--@sec: ThemeField
--@ord: 1
--@def: type ThemeFields = {[string]: any}

--@sec: Theme.ThemeField
--@def: Theme:Field(name: string, modifier: string?): any
function Theme.__index:Field(name, modifier)
	assert(type(name) == "string", "string expected")
	assert(modifier == nil or type(modifier) == "string", "string expected")
	local value = self.fields[name]
	if value == nil then
		error(string.format("unknown field %q", name), 2)
	end
	if type(value) == "table" then
		if modifier ~= nil then
			local result = value[modifier]
			if result ~= nil then
				return result
			end
		end
		return value.Default
	end
	return value
end

local studioThemes, currentTheme; do
	local ok, Studio = pcall(function()
		return settings().Studio
	end)
	if ok then
		studioThemes = {}
		for _, theme in ipairs(Studio:GetAvailableThemes()) do
			studioThemes[theme.Name] = theme
		end
		currentTheme = Studio.Theme
	end
end

local StudioTheme = {__index={}}

--@sec: Theme.fromStudio
--@ord: -1
--@def: Theme.fromStudio(theme: string|StudioTheme, fields: ThemeFields): Theme
local function fromStudio(theme, fields)
	if studioThemes == nil then
		error("current identity cannot use fromStudio", 2)
	end
	if theme == nil then
		theme = currentTheme
	elseif type(theme) == "string" then
		theme = studioThemes[theme]
		if theme == nil then
			error(string.format("unknown theme %q", theme), 2)
		end
	end
	assert(typeof(theme) == "Instance" and theme:IsA("StudioTheme"), "StudioTheme expected")
	assert(fields == nil or type(fields) == "table", "table expected")
	return setmetatable({
		theme = theme,
		fields = copyFields(fields),
	}, StudioTheme)
end

local function indexEnum(enum, by)
	local index = {}
	for _, item in ipairs(enum:GetEnumItems()) do
		index[item[by]] = item
	end
	return index
end

local colors = indexEnum(Enum.StudioStyleGuideColor, "Name")
local modifiers = indexEnum(Enum.StudioStyleGuideModifier, "Name")
function StudioTheme.__index:Field(name, modifier)
	assert(type(name) == "string", "string expected")
	assert(modifier == nil or type(modifier) == "string", "string expected")
	local value = self.fields[name]
	if value ~= nil then
		if type(value) == "table" then
			if modifier ~= nil then
				local result = value[modifier]
				if result ~= nil then
					return result
				end
			end
			return value.Default
		end
		return value
	end
	local value = colors[name]
	if value ~= nil then
		return self.theme:GetColor(value, modifiers[modifier])
	end
	error(string.format("unknown field %q", name), 2)
end

return {
	new = new,
	fromStudio = fromStudio,
}
