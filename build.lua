local output = (...) or "rt.rbxm"

local model = DataModel.new()
local bootstrapper = file.read(os.expand("$sd/src/bootstrapper.lua"))
bootstrapper.Name = "rt"
bootstrapper.Parent = model

local modules = {}
for _, f in ipairs(os.dir(os.expand("$sd/src/classes"))) do
	if not f.IsDir and os.split(f.Name, "fext") == ".lua" then
		local module = file.read(os.join(os.expand("$sd/src/classes"), f.Name))
		module.Parent = bootstrapper
		table.insert(modules, module.Name)
	end
end

local list = {}
for _, module in ipairs(modules) do
	table.insert(list, string.format("\t%q,", module))
end
bootstrapper.Source = types.ProtectedString(
	string.gsub(
		bootstrapper.Source.Value,
		"%-%-%[%[%$MODULES%]%]",
		"\n"..table.concat(list, "\n").."\n"
	)
)

file.write(output, model, "rbxm")
