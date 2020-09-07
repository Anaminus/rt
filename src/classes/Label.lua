return function(rt)
--@sec: Label
--@def: type Label
--@doc: Label is a widget that displays text.
local Label = {__index={}}

local function updateInteract(self)
	if self.style then
		local mod
		if self.disabled then
			mod = "Disabled"
		end
		self.style:SetExclusiveFlags(self.root, mod)
	end
end

--@sec: Label.new
--@ord: -1
--@def: Label.new(text: string?): Label
--@doc: new returns a new Label with initial text. *text* defaults to an empty
-- string.
local function new(text)
	assert(text == nil or type(text) == "string", "string expected")

	local root = Instance.new("TextLabel")
	root.Name = "Root"
	root.Size = UDim2.new(1, 0, 1, 0)
	root.BackgroundTransparency = 1
	root.Font = Enum.Font.SourceSans
	root.TextSize = 14
	root.Text = text or ""

	local self = {
		root = root,
		style = nil,
		disabled = false,
	}

	return setmetatable(self, Label)
end

--@sec: Label.Instance
--@def: Label:Instance(): Instance
--@doc: Instance returns the GuiObject containing the label.
function Label.__index:Instance()
	return self.root
end

--@sec: Label.Enabled
--@def: Label:Enabled(): bool
--@doc: Enabled returns whether or not the label is enabled.
function Label.__index:Enabled()
	return not self.disabled
end

--@sec: Label.SetEnabled
--@def: Label:SetEnabled(enabled: bool)
--@doc: SetEnabled sets whether the label is enabled.
function Label.__index:SetEnabled(enabled)
	if not enabled == self.disabled then
		return
	end
	self.disabled = not enabled
	if self.disabled then
		self.pressed = false
	end
	updateInteract(self)
end

local labelStyle = {
	Font       = "Font",
	TextSize   = "FontSize",
	TextColor3 = "MainText",
}

local function detachStyle(self)
	if self.style then
		self.style:Detach(self.root)
	end
end

--@sec: Label.Style
--@def: Label:Style(): Style
--@doc: Style returns the current Style applied to the label.
function Label.__index:Style()
	return self.style
end

--@sec: Label.SetStyle
--@def: Label:SetStyle(style: Style)
--@doc: SetStyle sets the style applied to the label. The following theme fields
-- are used:
--
-- Field    | Type   | Flags
-- ---------|--------|------
-- Font     | number | Disabled
-- FontSize | string | Disabled
-- MainText | Color3 | Disabled
function Label.__index:SetStyle(style)
	if style == self.style then
		return
	end
	detachStyle(self)
	self.style = style
	if style then
		style:Attach(self.root, labelStyle)
	end
	updateInteract(self)
end

--@sec: Label.Destroy
--@def: Label:Destroy()
--@doc: Destroy releases the resources used by the object.
function Label.__index:Destroy()
	detachStyle(self)
	self.root:Destroy()
end

return {
	new = new,
}
end
