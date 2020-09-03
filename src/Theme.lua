--@sec: Theme
--@def: type Theme
--@doc: Theme maps a name to a value through a field. A field can have multiple
-- values, determined by a number of flags. When defining a field with multiple
-- values, each value is mapped to a combination of flags.
--
-- When making a query, a field is searched for the value that matches the
-- largest unambiguous subset of flags. If the given flag set does not match,
-- then each subset is checked. If two subsets with the same number of flags
-- match, then all subsets with that number of flags are skipped. If no subsets
-- match, then the default for the field is returned.
--
-- For example, say a field was defined with values mapped to the following sets
-- of flags:
-- - `A`
-- - `A|B|C`
-- - `A|B|D`
--
-- Then, this field is queried with the set `A|B|C|D`. The field does not define
-- `A|B|C|D`, so each combination of three flags is checked. This would match
-- both `A|B|C` and `A|B|D`. Because multiple sets have matched, all
-- combinations of three flags are skipped. Next, all combinations of two flags
-- are checked. The field does not define any sets with two flags, so there are
-- no matches. Finally, each single flag is checked. The field defines flag `A`,
-- which matches. No other single flags match, so querying flags `A|B|C|D`
-- returns the value of `A`.
--
-- The "Default" flag corresponds to 0, or no set flags.
local Theme = {__index={}}

-- getFlags gets the numeric value of a list of flags.
local function getFlags(map, flags)
	local n = 0
	for _, flag in ipairs(flags) do
		local v = map[flag]
		if v then
			n = bit32.bor(n, v)
		end
	end
	return n
end

-- processFlagMap sets the value of each entry in map to a power of two, sorted
-- by name. "Default" is set to 0.
local function processFlagMap(map)
	local sorted = {}
	for flag in pairs(map) do
		if flag ~= "Default" then
			table.insert(sorted, flag)
		end
	end
	if #sorted > 53 then
		error("definition contains too many flags", 4)
	end
	table.sort(sorted)
	for i, flag in ipairs(sorted) do
		map[flag] = 2^(i-1)
	end
	map.Default = 0
end

-- processFields a field definition into a set of fields.
local function processFields(def, extraFlags)
	local map = {}
	for _, flag in ipairs(extraFlags) do
		if type(flag) == "string" then
			map[flag] = true
		end
	end
	if def then
		for _, value in pairs(def) do
			if type(value) == "table" then
				for flags in pairs(value) do
					if type(flags) == "string" then
						map[flags] = true
					elseif type(flags) == "table" then
						for _, flag in ipairs(flags) do
							if type(flag) == "string" then
								map[flag] = true
							end
						end
					end
				end
			end
		end
	end
	processFlagMap(map)

	local fields = {}
	if def then
		for name, value in pairs(def) do
			local field = {cache={}}
			if type(value) == "table" then
				for flags, value in pairs(value) do
					if type(flags) == "string" then
						field[map[flags]] = value
					elseif type(flags) == "table" then
						field[getFlags(map, flags)] = value
					end
				end
			else
				field[0] = value
			end
			fields[name] = field
		end
	end
	return fields, map
end

--@sec: Theme.new
--@ord: -1
--@def: Theme.new(defs: ThemeDefs, extraFlags: ThemeFlags?): Theme
--@doc: new returns a new theme.
--
-- *defs* defines the fields of the theme. Each key is the name of a field. If
-- the value is a ThemeFieldDef, then each of its entries defines a set of flags
-- mapped to a value. Otherwise, the value is mapped directly to the name.
--
-- For example, the following table defines values of the "Foo" and "Bar"
-- fields. The Bar field defines values for each combination of the flags A, B,
-- and C:
-- ```lua
-- def = {
-- 	Foo = 0,
-- 	Bar = {
-- 		Default = 0,
-- 		A = 1,
-- 		B = 2,
-- 		C = 3,
-- 		[{"A","B"}] = 4,
-- 		[{"A","C"}] = 5,
-- 		[{"B","C"}] = 6,
-- 		[{"A","B","C"}] = 7,
-- 	},
-- }
-- ```
--
-- *extraFlags* specifies additional flags for the theme to keep track of.
local function new(def, extraFlags)
	assert(type(def) == "table", "table expected")
	assert(extraFlags == nil or type(extraFlags) == "table", "table expected")
	local fields, flags = processFields(def, extraFlags)
	return setmetatable({
		fields = fields,
		flags = flags,
	}, Theme)
end

--@sec: ThemeDefs
--@ord: 1
--@def: type ThemeDefs = {[string]: ThemeFieldDef|any}
--@doc: ThemeDefs defines the fields for a theme. Each key is the name of a
-- field. If a value is a ThemeFieldDef, then each of its entries defines a set
-- of flags mapped to a value. Otherwise, the value is mapped directly to the
-- field, corresponding to the Default flag.

--@sec: ThemeFieldDef
--@ord: 1
--@def: type ThemeFieldDef = {[string|ThemeFlags] = any, Default = any}
--@doc: ThemeFieldDef maps flag sets to values.

--@sec: ThemeFlags
--@ord: 1
--@def: type ThemeFlags = {string}
--@doc: ThemeFlags is a list of strings, each indicating the name of a flag.

--@sec: ThemeFlagSet
--@ord: 1
--@def: type ThemeFlagSet = number
--@doc: ThemeFlagSet is an integer, where each bit indicates whether a flag is
-- set.

-- popcnt returns the number of bits set in v.
local function popcnt(v)
	-- https://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetParallel
	v = v - bit32.band(bit32.rshift(v, 1), 0x55555555)
	v = bit32.band(v, 0x33333333) + bit32.band(bit32.rshift(v, 2), 0x33333333)
	return bit32.rshift(bit32.band(v + bit32.rshift(v, 4), 0xF0F0F0F) * 0x1010101, 24)
end

-- binomial returns the binomial coefficient of (n, k). Assumes n >= k.
local function binomial(n, k)
    if k > n/2 then
    	k = n - k
    end
    local a = 1
    local b = 1
    for i = 1, k do
        a = a*(n-i+1)
        b = b*i
    end
    return a/b
end

-- nthsetbit returns the nth bit of v that is set.
local function nthsetbit(v, n)
	for i = 0, n-1 do
		v = bit32.band(v, v-1)
	end
	return bit32.band(v, bit32.bnot(v-1))
end

-- nextbitperm returns the next bit permutation of v.
local function nextbitperm(v)
	-- https://graphics.stanford.edu/~seander/bithacks.html#NextBitPermutation
	local t = bit32.bor(v, (v - 1)) + 1
	return bit32.bor(t, (bit32.rshift((bit32.band(t, -t) / bit32.band(v, -v)), 1) - 1))
end

-- Match searches the given field for a value matching the largest unambiguous
-- subset of flags. If the given flags do not match, then each subset is
-- checked. If two subsets with the same number of flags match, then all subsets
-- with that number of flags are skipped. If no subsets match, then the default
-- for the field is returned.
local function match(self, field, flags)
	local n
	if type(flags) == "number" then
		n = flags
	elseif type(flags) == "table" then
		n = getFlags(self.flags, flags)
	else
		return field[0]
	end
	local value = field[n]
	if value ~= nil then
		return value
	end

	local p = field.cache[n]
	if p then
		return field[p]
	end

	local selection = nil
	local c = popcnt(n)
	-- Enumerate the subsets of n that contain i flags, from the greatest to the
	-- least number of flags. The length-c set is just n, which was already
	-- checked, so it is skipped.
	for i = c-1, 1, -1 do
		-- f determines which bits of n will be set.
		local f = 2^i-1
		-- Enumerate each length-i subset.
		for _ = 0, binomial(c, i)-1 do
			-- q is the bits of n set according to f. The kth set bit of n is
			-- set in q if the kth bit of f is set.
			local q = 0
			for k = 0, c-1 do
				if bit32.extract(f, k) > 0 then
					q = q + nthsetbit(n, k)
				end
			end
			local value = field[q]
			if value ~= nil then
				if selection then
					-- Multiple subsets of the same length were found. There's
					-- no reasonable way to pick one over another, so skip all
					-- length-i subsets instead.
					selection = nil
					p = 0
					break
				end
				selection = value
				p = q
			end
			-- Compute the next subset.
			f = nextbitperm(f)
		end
		if selection then
			field.cache[n] = p
			return selection
		end
	end
	-- No subsets were matched, return the default.
	field.cache[n] = 0
	return field[0]
end

--@sec: Theme.Field
--@def: Theme:Field(name: string, flags: ThemeFlags|ThemeFlagSet|nil): any?
--@doc: Field returns the value of field *name* that matches *flags*. If *flags*
-- is unspecified, then the Default value is returned. Returns nil if the field
-- was not found.
function Theme.__index:Field(name, flags)
	local field = self.fields[name]
	if field == nil then
		return nil
	end
	return match(self, field, flags)
end

--@sec: Theme.Flags
--@def: Theme:Flags(flags: ThemeFlags): ThemeFlagSet
--@doc: Flags returns an integer with each bit set corresponding to the given
-- flags. Flags not known by the theme are ignored.
function Theme.__index:Flags(flags)
	assert(type(flags) == "table", "table expected")
	return getFlags(self.flags, flags)
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
--@def: Theme.fromStudio(theme: string|StudioTheme, defs: ThemeDefs, extraFlags: ThemeFlags?): Theme
--@doc: fromStudio returns a Theme derived from a StudioTheme. Fields of the
-- theme correspond to the items of the StudioStyleGuideColor enum.
--
-- *theme* is either a StudioTheme or a string corresponding to the Name of a
-- StudioTheme available from `Studio:GetAvailableThemes()`.
--
-- *defs* are additional field definitions. Defined fields have priority over
-- StudioTheme fields; if a queried field is not found, then the StudioTheme is
-- searched. See [Theme.new][Theme.new] for more information on field
-- definitions.
--
-- *extraFlags* specifies additional flags for the theme to keep track of.
--
-- The theme defines flags corresponding to the items of the
-- StudioStyleGuideModifier enum. When querying a StudioTheme field, the flag
-- set must contain exactly one of modifier names in order to match that
-- modifier. If the set contains more than one, or none, then the Default
-- modifier is used.
--
-- fromStudio throws an error if called from an identity that cannot use
-- StudioThemes.
local function fromStudio(theme, def, extraFlags)
	assert(type(def) == "table", "table expected")
	assert(extraFlags == nil or type(extraFlags) == "table", "table expected")
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
	assert(def == nil or type(def) == "table", "table expected")
	local itemFlags = Enum.StudioStyleGuideModifier:GetEnumItems()
	for i, item in ipairs(itemFlags) do
		if item.Name ~= "Default" then
			itemFlags[i] = item.Name
		end
	end
	if extraFlags then
		for _, flag in ipairs(extraFlags) do
			table.insert(itemFlags, flag)
		end
	end
	local fields, flags = processFields(def, itemFlags)
	local modmap = {}
	for _, item in ipairs(Enum.StudioStyleGuideModifier:GetEnumItems()) do
		if item.Name ~= "Default" then
			modmap[flags[item.Name]] = item
		end
	end
	return setmetatable({
		theme = theme,
		fields = fields,
		flags = flags,
		modmap = modmap,
		cache = {},
	}, StudioTheme)
end

local function matchModifier(self, n)
	local selection = nil
	for flag, item in pairs(self.modmap) do
		if bit32.band(flag, n) ~= 0 then
			if selection then
				return Enum.StudioStyleGuideModifier.Default
			end
			selection = item
		end
	end
	if selection then
		return selection
	end
	return Enum.StudioStyleGuideModifier.Default
end

local function indexEnum(enum, by)
	local index = {}
	for _, item in ipairs(enum:GetEnumItems()) do
		index[item[by]] = item
	end
	return index
end

local colors = indexEnum(Enum.StudioStyleGuideColor, "Name")
function StudioTheme.__index:Field(name, flags)
	local field = self.fields[name]
	if field ~= nil then
		return match(self, field, flags)
	end
	local color = colors[name]
	if color == nil then
		return nil
	end
	local n
	if flags == nil then
		return self.theme:GetColor(color)
	elseif type(flags) == "number" then
		n = flags
	else
		n = getFlags(self.flags, flags)
	end
	local mod = self.cache[n]
	if mod then
		return self.theme:GetColor(color, mod)
	end
	local p = matchModifier(self, n)
	self.cache[n] = p
	return self.theme:GetColor(color, p)
end

function StudioTheme.__index:Flags(flags)
	assert(type(flags) == "table", "table expected")
	return getFlags(self.flags, flags)
end

return {
	new = new,
	fromStudio = fromStudio,
}
