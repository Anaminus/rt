# rt
**rt** ("rote") is a GUI library for [Roblox](https://www.roblox.com/). It
focuses primarily on interfaces for Studio plugins, but can be applied to Roblox
GUIs in general.

## Usage
rt consists of a bootstrapper module, which contains a number of submodules. The
bootstrapper is required as usual:

```lua
local rt = require(...)
```

The bootstrapper returns a handler. When this handler is indexed, the submodule
corresponding to the indexed name is required. For example, to get the CheckBox
class:

```lua
local CheckBox = rt.CheckBox
local cb = CheckBox.new()
```

Submodules should not be required directly.

The bootstrapper will throw an error if any of the expected submodules are
missing. If this is the case, rt should be redownloaded or reinstalled.

The following submodules are available:

Class                                   | Description
----------------------------------------|------------
[CheckBox](doc/classes/CheckBox.md)     | An interactive boolean widget.
[Lattice](doc/classes/Lattice.md)       | A grid-like container.
[Properties](doc/classes/Properties.md) | A generic properties container.
[Style](doc/classes/Style.md)           | Dynamically style GUIs.
[Theme](doc/classes/Theme.md)           | Define the appearance of GUIs.

## Installation
rt can be built with [rbxmk](https://github.com/Anaminus/rbxmk) by running
`build.lua` with the output file as the first argument:

```bash
rbxmk build.lua rt.rbxm
```
