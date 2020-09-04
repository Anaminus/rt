return function(rt)
--@sec: Lattice
--@def: type lattice
--@doc: Lattice is a container that positions and sizes its children using the
-- grid-like "lattice" layout. The X and Y axes of the grid each consist of a
-- list of "spans". A span is a numeric value with either a constant or
-- fractional unit:
--
-- - `px`: A constant size, in UDim.Offset units.
-- - `fr`: A fraction of the remaining non-constant span of the axis. The
--   calculated fraction is the value divided by the sum of all fr units on the
--   axis. So, if an axis contained `1fr`, `2fr`, `3fr`, and `1fr`, the total
--   space would be 7 fractional units, and the `2fr` would take up 2/7 of the
--   available fractional space.
--
-- The position and size of an object is defined in terms of a rectangle of
-- cells on the grid.
--
-- The calculated positions and sizes of objects are static; the given bounds of
-- an object is reduced to a Position and Size UDim2, which are applied to the
-- object. This makes resizing a lattice container inexpensive.
local Lattice = {__index={}}

--@sec: Lattice.new
--@ord: -1
--@def: Lattice.new(): Lattice
--@doc: new returns a new Lattice container.
local function new()
	local inst = Instance.new("Frame")
	inst.Name = "Lattice"
	inst.BackgroundTransparency = 0
	inst.Position = UDim2.new(0,0,0,0)
	inst.Size = UDim2.new(1,0,1,0)
	local constraint = Instance.new("UISizeConstraint", inst)
	return setmetatable({
		inst = inst,

		coln = {},
		colu = {},
		cols = {},

		rown = {},
		rowu = {},
		rows = {},

		cidx = {},
		cell = {},
		rect = {},

		constraint = constraint,
		minCnstr = Vector2.new(0,0),
		maxCnstr = Vector2.new(math.huge,math.huge),
		colmin = 0,
		rowmin = 0,
	}, Lattice)
end

local function parseUnit(value)
	if type(value) == "table" then
		if type(value.N) ~= "number" then
			return nil, nil, "first entry of unit table must be a number"
		end
		if value.U ~= "px" and value.U ~= "fr" then
			return nil, nil, "second entry of unit table must be 'px' or 'fr'"
		end
		return value.N, value.U, nil
	elseif type(value) == "string" then
		local n = string.match(value, "^(.*)px$")
		if n then
			n = tonumber(n)
			if n == nil then
				return nil, nil, "unit string must begin with number"
			end
			return n, "px", nil
		end
		local n = string.match(value, "^(.*)fr$")
		if n then
			n = tonumber(n)
			if n == nil then
				return nil, nil, "unit string must begin with number"
			end
			return n, "fr", nil
		end
		return nil, nil, "unit string must end with 'px' or 'fr'"
	end
	return nil, nil, string.format("cannot parse %s as unit", type(value))
end

local function buildAxis(ns, us)
	local sumConst = 0
	local sumFract = 0
	for i, n in ipairs(ns) do
		if us[i] == "px" then
			sumConst += n
		elseif us[i] == "fr" then
			sumFract += n
		end
	end
	local norm = 0
	if sumFract == 0 then
		sumFract = 1
		norm = 1
	end

	local lines = table.create(#ns + norm + 1, nil)
	local L = 0        -- Sum of px units encountered
	local R = sumConst -- Sum of px units not encountered
	local N = 0        -- Sum of fr units encountered
	local T = sumFract -- Sum of fr units
	for i, n in ipairs(ns) do
		lines[i] = UDim.new(N/T, L - (R+L)*(N/T))
		if us[i] == "px" then
			L += n
			R -= n
		elseif us[i] == "fr" then
			N += n
		end
	end
	if norm > 0 then
		lines[#ns+1] = UDim.new(N/T, L - (R+L)*(N/T))
		N += 1
	end
	lines[#ns+1+norm] = UDim.new(N/T, L - (R+L)*(N/T))
	return lines, sumConst
end

local function updateConstraints(self)
	self.constraint.MinSize = self.minCnstr+Vector2.new(self.colmin, self.rowmin)
	self.constraint.MaxSize = self.maxCnstr+Vector2.new(self.colmin, self.rowmin)
end

local zeroUDim = UDim.new(0, 0)
local function reflowCell(self, i)
	local inst = self.cell[i]
	local rect = self.rect[i]
	local x0, y0, x1, y1 = rect.Min.X, rect.Min.Y, rect.Max.X, rect.Max.Y
	if x1 < 0 or y1 < 0 or x0 >= #self.cols or y0 >= #self.rows then
		inst.Visible = false
		return
	end
	x0 = math.max(x0, 0)
	y0 = math.max(y0, 0)
	x1 = math.min(x1, #self.cols-1)
	y1 = math.min(y1, #self.rows-1)

	local pos = UDim2.new(self.cols[x0+1], self.rows[y0+1])
	inst.Position = pos
	inst.Size = UDim2.new(self.cols[x1+1], self.rows[y1+1]) - pos
	inst.Visible = true
end

local function reflowAll(self)
	for i = 1, #self.cell do
		reflowCell(self, i)
	end
end

--@sec: Lattice.Instance
--@def: Lattice:Instance(): Instance
--@doc: Instance returns the GuiObject that contains the cells of the grid.
function Lattice.__index:Instance()
	return self.inst
end

--@sec: Lattice.Columns
--@def: Lattice:Columns(): {Span}
--@doc: Columns returns the columns of the Lattice.
function Lattice.__index:Columns()
	local cols = table.create(#self.colu, nil)
	for i, u in ipairs(self.colu) do
		cols[i] = {N = self.coln[i], U = u}
	end
	return cols
end

--@sec: Lattice.SetColumns
--@def: Lattice:SetColumns(columns: {Span|string})
--@doc: SetColumns sets the columns of the Lattice. If an entry in *columns* is
-- a string, it must be formatted as `<number><unit>`, where `<number>` is a
-- valid number, and `<unit>` is either `px` or `fr`.
function Lattice.__index:SetColumns(cols)
	assert(type(cols) == "table", "table expected")
	local coln = {}
	local colu = {}
	for i, value in ipairs(cols) do
		local n, u, err = parseUnit(value)
		if err then
			error(string.format("bad entry #%d: %s", i, err), 2)
		end
		table.insert(coln, n)
		table.insert(colu, u)
	end
	self.coln = coln
	self.colu = colu
	self.cols, self.colmin = buildAxis(coln, colu)
	updateConstraints(self)
	reflowAll(self)
end

--@sec: Lattice.Rows
--@def: Lattice:Rows(): {Span}
--@doc: Rows returns the rows of the Lattice.
function Lattice.__index:Rows()
	local rows = table.create(#self.rowu, nil)
	for i, u in ipairs(self.rowu) do
		rows[i] = {N = self.rown[i], U = u}
	end
	return rows
end

--@sec: Lattice.SetRows
--@def: Lattice:SetRows(rows: {Span|string})
--@doc: SetRows sets the rows of the Lattice. If an entry in *rows* is a string,
-- it must be formatted as `<number><unit>`, where `<number>` is a valid number,
-- and `<unit>` is either `px` or `fr`.
function Lattice.__index:SetRows(rows)
	assert(type(rows) == "table", "table expected")
	local rown = {}
	local rowu = {}
	for i, value in ipairs(rows) do
		local n, u, err = parseUnit(value)
		if err then
			error(string.format("bad entry #%d: %s", i, err), 2)
		end
		table.insert(rown, n)
		table.insert(rowu, u)
	end
	self.rown = rown
	self.rowu = rowu
	self.rows, self.rowmin = buildAxis(rown, rowu)
	updateConstraints(self)
	reflowAll(self)
end

--@sec: Lattice.AddChild
--@def:
-- Lattice:AddChild(child: GuiObject, x0: number, y0: number, x1: number, y1: number)
-- Lattice:AddChild(child: GuiObject, v: Vector2)
-- Lattice:AddChild(child: GuiObject, rect: Rect)
--@doc: AddChild adds *child* to the lattice at a given position. The remaining
-- arguments specify the lower and upper bounds that determine the position and
-- size of the child:
--
-- - *x0* is the X coordinate of the lower bound.
-- - *y0* is the Y coordinate of the lower bound.
-- - *x1* is the X coordinate of the upper bound.
-- - *y1* is the Y coordinate of the upper bound.
-- - *v* specifies the lower bound. The upper bound is determined by adding 1 to
--   each coordinate of the lower bound.
-- - *rect* specifies the bounds from a rectangle.
--
-- Each component is converted to an integer, and normalized so that the
-- resulting rectangle is not inverted.
--
-- The resulting rectangle determines the position and size of the object in
-- cell coordinates. If the rectangle lies partially outside the lattice grid,
-- then the components are constrained. If the rectangle lies completely outside
-- the grid, then the object is not rendered.
function Lattice.__index:AddChild(child, a0, a1, a2, a3)
	assert(typeof(child) == "Instance" and child:IsA("GuiObject"), "GuiObject expected")
	local x0, y0, x1, y1
	if typeof(a0) == "Vector2" then
		x0 = a0.X
		y0 = a0.Y
		x1 = a0.X + 1
		y1 = a0.Y + 1
	elseif typeof(a0) == "Rect" then
		x0 = a0.Min.X
		y0 = a0.Min.Y
		x1 = a0.Max.X
		y1 = a0.Max.Y
	else
		assert(type(a0) == "number", "number expected")
		assert(type(a1) == "number", "number expected")
		assert(type(a2) == "number", "number expected")
		assert(type(a3) == "number", "number expected")
		x0, y0, x1, y1 = a0, a1, a2, a3
	end
	x0 = math.modf(x0)
	y0 = math.modf(y0)
	x1 = math.modf(x1)
	y1 = math.modf(y1)
	if x1 < x0 then
		x0, x1 = x1, x0
	end
	if y1 < y0 then
		y0, y1 = y1, y0
	end
	local rect = Rect.new(x0, y0, x1, y1)
	local i = self.cidx[child]
	if i == nil then
		table.insert(self.cell, child)
		table.insert(self.rect, rect)
		i = #self.cell
		self.cidx[child] = i
		child.Parent = self.inst
	else
		self.rect[i] = rect
	end
	reflowCell(self, i)
end

--@sec: Lattice.RemoveChild
--@def: Lattice:RemoveChild(child: GuiObject)
--@doc: RemoveChild removes *child* from the lattice. Does nothing if *child* is
-- not in the container.
function Lattice.__index:RemoveChild(child)
	assert(typeof(child) == "Instance" and child:IsA("GuiObject"), "GuiObject expected")
	local i = self.cidx[child]
	if i == nil then
		return
	end
	child.Parent = nil
	self.cidx[child] = nil
	table.remove(self.cell, i)
	table.remove(self.x, i)
	table.remove(self.y, i)
end

--@sec: Lattice.GetChildren
--@def: Lattice:GetChildren(): {GuiObject}
--@doc: GetChildren returns the child objects of the Lattice container.
function Lattice.__index:GetChildren()
	local n = #self.cell
	local children = table.create(n)
	table.move(self.cell, 1, n, 1, children)
	return children
end

--@sec: Lattice.Rect
--@def: Lattice:Rect(child: GuiObject): Rect?
--@doc: Rect returns the cell boundary of *child*. Returns nil if *child* is not
-- in the container.
function Lattice.__index:Rect(child)
	assert(typeof(child) == "Instance" and child:IsA("GuiObject"), "GuiObject expected")
	local i = self.cidx[child]
	if i == nil then
		return nil
	end
	return self.x[i], self.y[i]
end

--@sec: Lattice.Constraints
--@def: Lattice:Constraints(): (min: Vector2, max: Vector2)
--@doc: Constraints returns the constraints applied to the Lattice's container.
-- *min* is the minimum size of the fractional space for each axis, while *max*
-- is the maximum size. Units are the same as UDim.Offset.
function Lattice.__index:Constraints()
	return self.minCnstr, self.maxCnstr
end

--@sec: Lattice.SetConstraints
--@def: Lattice:SetConstraints(min: Vector2?, max: Vector2?)
--@doc: SetConstraints applies constraints to the size of the fractional space
-- of the Lattice's container. *min* determines the minimum size of the
-- fractional space for each axis, while *max* determines the maximum size.
-- Units are the same as UDim.Offset.
--
-- If *min* is nil, then the minimum size is 0. If *max* is nil, then the
-- maximum size is unbounded.
function Lattice.__index:SetConstraints(min, max)
	assert(min == nil or typeof(min) == "Vector2", "Vector2 expected")
	assert(max == nil or typeof(max) == "Vector2", "Vector2 expected")
	self.minCnstr = min or Vector2.new(0, 0)
	self.maxCnstr = max or Vector2.new(math.huge, math.huge)
	updateConstraints(self)
end

--@sec: Span
--@ord: 1
--@def:
-- type Span = {
-- 	N: number,
-- 	U: string,
-- }
--@doc: Span describes a value of a Lattice span. Field `N` is the value of the
-- span, and field `U` is the unit, which should be either "px" or "fr".

return {
	new = new,
}
end
