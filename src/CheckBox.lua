return function(rt)
local Properties = rt.Properties

--@sec: CheckBox
--@def: type CheckBox
--@doc: CheckBox is a widget containing an interactive boolean state. Clicking
-- on the checkbox toggles the state between checked and unchecked.
--
-- The checkbox is able to have one of three states, each indicated by a
-- particular Lua value:
-- - true: The checkbox is checked.
-- - false: The checkbox is unchecked.
-- - nil: The checkbox is partially checked.
local CheckBox = {__index={}}

local function updateLayout(self)
	local s = self.size
	local p = self.padding
	local a = s+p*2
	self.rootConstraint.MinSize = a
	self.layoutFrame.Position = UDim2.new(0, p.X, 0, p.Y)
	self.layoutFrame.Size = UDim2.new(1, -2*p.X, 1, -2*p.Y)
	self.boxAspectRatio.AspectRatio = s.X/s.Y
	self.sizeConstraint.MaxSize = Vector2.new(s.X, math.huge)
	self.labelContainer.Position = UDim2.new(0, a.X, 0, 0)
	self.labelContainer.Size = UDim2.new(1, -a.X, 1, 0)
end

local function updateInteract(self)
	if self.style then
		local mod
		if self.disabled then
			mod = "Disabled"
		elseif self.state == true or self.state == nil then
			mod = "Selected"
		elseif self.pressed then
			mod = "Pressed"
		elseif self.hovered then
			mod = "Hover"
		end
		local state
		if self.state == true then
			state = "Checked"
		elseif self.state == nil then
			state = "Partial"
		else
			state = "Unchecked"
		end
		self.style:SetExclusiveFlags(self.checkBox, state, mod)
	end
end

local function click(self)
	if self.state == true then
		self.state = false
	elseif self.state == nil then
		self.state = false
	else
		self.state = true
	end
	updateInteract(self)
	self.event:Fire(self.state)
end

--@sec: CheckBox.new
--@ord: -1
--@def: CheckBox.new(state: bool?): CheckBox
--@doc: new returns a new CheckBox with an initial state. *state* defaults to
-- false.
local function new(state)
	local root = Instance.new("ImageButton")
	root.Name = "Root"
	root.Size = UDim2.new(1, 0, 1, 0)
	root.BackgroundTransparency = 1
	root.AutoButtonColor = false
		local rootConstraint = Instance.new("UISizeConstraint")
		rootConstraint.Name = "RootConstraint"
		rootConstraint.Parent = root
		local layoutFrame = Instance.new("Frame")
		layoutFrame.Name = "LayoutFrame"
		layoutFrame.BackgroundTransparency = 1
		layoutFrame.Parent = root
			local sizeConstraint = Instance.new("UISizeConstraint")
			sizeConstraint.Name = "SizeConstraint"
			sizeConstraint.Parent = layoutFrame
			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout.Parent = layoutFrame
			local checkBox = Instance.new("ImageLabel")
			checkBox.Name = "CheckBox"
			checkBox.Size = UDim2.new(1, 0, 1, 0)
			checkBox.BorderMode = Enum.BorderMode.Inset
			checkBox.Parent = layoutFrame
				local boxAspectRatio = Instance.new("UIAspectRatioConstraint")
				boxAspectRatio.AspectRatio = 1
				boxAspectRatio.Parent = checkBox
		local labelContainer = Instance.new("Frame")
		labelContainer.Name = "LabelContainer"
		labelContainer.BackgroundTransparency = 1
		labelContainer.Parent = root
			local uiSizeConstraint = Instance.new("UISizeConstraint")
			uiSizeConstraint.Parent = labelContainer
	local event = Instance.new("BindableEvent")

	local self = {
		root = root,
		layoutFrame = layoutFrame,
		sizeConstraint = sizeConstraint,
		checkBox = checkBox,
		boxAspectRatio = boxAspectRatio,
		labelContainer = labelContainer,
		rootConstraint = rootConstraint,
		event = event,
		connBegan = nil,
		connEnded = nil,

		props = nil,
		size = Vector2.new(16, 16),
		padding = Vector2.new(4, 4),

		style = nil,
		label = nil,

		state = false,
		disabled = false,
		hovered = false,
		pressed = false,

		--@sec: CheckBox.StateChanged
		--@def: CheckBox.StateChanged(state: bool|nil)
		--@doc: The StateChanged event is fired after the state of the checkbox
		-- changes.
		StateChanged = event.Event,
	}
	if state == true then
		self.state = true
	end
	self.props = Properties.new({
		CheckBoxSize = {
			Get = function()
				return self.size
			end,
			Set = function(v)
				self.size = v
				updateLayout(self)
			end,
		},
		Padding = {
			Get = function()
				return self.padding
			end,
			Set = function(v)
				self.padding = v
				updateLayout(self)
			end,
		},
	})
	self.connBegan = root.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self.hovered = true
			updateInteract(self)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not self.disabled then
				self.pressed = true
				updateInteract(self)
			end
		end
	end)
	self.connEnded = root.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self.hovered = false
			updateInteract(self)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if self.pressed and self.hovered and not self.disabled then
				click(self)
			end
			self.pressed = false
			updateInteract(self)
		end
	end)
	updateInteract(self)
	updateLayout(self)

	return setmetatable(self, CheckBox)
end

--@sec: CheckBox.Instance
--@def: CheckBox:Instance(): Instance
--@doc: Instance returns the GuiObject containing the checkbox.
function CheckBox.__index:Instance()
	return self.root
end

--@sec: CheckBox.State
--@def: CheckBox:State(): bool|nil
--@doc: State returns the current state of the checkbox.
-- - true: The checkbox is checked.
-- - false: The checkbox is unchecked.
-- - nil: The checkbox is partially checked.
function CheckBox.__index:State()
	return self.state
end

--@sec: CheckBox.SetState
--@def: CheckBox:SetState(state: bool|nil)
--@doc: SetState sets the state of the checkbox, updating the display, and
-- firing the StateChanged event. The checkbox may have one of three states:
-- - true: The checkbox is checked.
-- - false: The checkbox is unchecked.
-- - nil: The checkbox is partially checked.
function CheckBox.__index:SetState(state)
	if state == self.state then
		return
	end
	self.state = state
	updateInteract(self)
	self.event:Fire(self.state)
end

--@sec: CheckBox.Enabled
--@def: CheckBox:Enabled(): bool
--@doc: Enabled returns whether or not the checkbox is enabled.
function CheckBox.__index:Enabled()
	return not self.disabled
end

--@sec: CheckBox.SetEnabled
--@def: CheckBox:SetEnabled(enabled: bool)
--@doc: SetEnabled sets whether the checkbox is enabled. While disabled, the
-- checkbox cannot be interacted with by the user. SetState will still set the
-- state as usual, and still fires the StateChanged event.
function CheckBox.__index:SetEnabled(enabled)
	if not enabled == self.disabled then
		return
	end
	self.disabled = not enabled
	if self.disabled then
		self.pressed = false
	end
	updateInteract(self)
end

local checkBoxStyle = {
	BackgroundColor3       = "CheckedFieldBackground",
	BackgroundTransparency = "CheckBoxBoundsTransparency",
	BorderColor3           = "CheckedFieldBorder",
	Image                  = "CheckBoxImage",
	ImageColor3            = "CheckedFieldIndicator",
}

local checkBoxLayout = {
	CheckBoxSize = "CheckBoxSize",
	Padding      = "Padding",
}

local function detachStyle(self)
	if self.style then
		self.style:Detach(self.checkBox)
		self.style:Detach(self.props)
	end
end

--@sec: CheckBox.Style
--@def: CheckBox:Style(): Style
--@doc: Style returns the current Style applied to the checkbox.
function CheckBox.__index:Style()
	return self.style
end

--@sec: CheckBox.SetStyle
--@def: CheckBox:SetStyle(style: Style)
--@doc: SetStyle sets the style applied to the checkbox. The following theme
-- fields are used:
--
-- Field                      | Type    | Flags
-- ---------------------------|---------|------
-- CheckBoxBoundsTransparency | number  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
-- CheckBoxImage              | string  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
-- CheckBoxSize               | Vector2 |
-- CheckedFieldBackground     | Color3  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
-- CheckedFieldBorder         | Color3  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
-- CheckedFieldIndicator      | Color3  | (Disabled, Hover, Pressed, Selected), (Checked, Partial, Unchecked)
-- Padding                    | Vector2 |
function CheckBox.__index:SetStyle(style)
	if style == self.style then
		return
	end
	detachStyle(self)
	self.style = style
	if style then
		style:Attach(self.checkBox, checkBoxStyle)
		style:Attach(self.props, checkBoxLayout)
	end
	updateInteract(self)
end

--@sec: CheckBox.Label
--@def: CheckBox:Label(): GuiObject|nil
--@doc: Label returns the label applied to the checkbox.
function CheckBox.__index:Label()
	return self.label
end

--@sec: CheckBox.SetLabel
--@def: CheckBox:SetLabel(label: GuiObject|nil)
--@doc: SetLabel sets the label applied to the checkbox.
function CheckBox.__index:SetLabel(label)
	assert(typeof(label) == "Instance" and label:IsA("GuiObject"), "GuiObject expected")
	if label == self.label then
		return
	end
	if self.label then
		self.label.Parent = nil
	end
	self.label = label
	if label then
		label.Position = UDim2.new(0, 0, 0, 0)
		label.Size = UDim2.new(1, 0, 1, 0)
		label.Parent = self.labelContainer
	end
end

--@sec: CheckBox.Destroy
--@def: CheckBox:Destroy()
--@doc: Destroy releases the resources used by the object.
function CheckBox.__index:Destroy()
	detachStyle(self)
	if self.connBegan then
		self.connBegan:Disconnect()
		self.connBegan = nil
	end
	if self.connEnded then
		self.connEnded:Disconnect()
		self.connEnded = nil
	end
	if self.label then
		self.label.Parent = nil
	end
	self.root:Destroy()
end

return {
	new = new,
}
end
