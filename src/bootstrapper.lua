local expected = {--[[$MODULES]]}

local modules = {}
for _, module in ipairs(script:GetChildren()) do
	if not module:IsA("ModuleScript") then
		continue
	end
	if modules[module.Name] then
		continue
	end
	local i = table.find(expected, module.Name)
	if i == nil then
		continue
	end
	modules[module.Name] = module
	table.remove(expected, i)
end

if #expected > 0 then
	error("missing the following submodules: " .. table.concat(expected, ", "))
end

local rt = setmetatable({}, {
	__index = function(self, name)
		local module = modules[name]
		if module == nil then
			error(string.format("unknown module %q", tostring(name)), 2)
		end
		local result = require(module)(self)
		self[name] = result
		return result
	end,
})

return rt
