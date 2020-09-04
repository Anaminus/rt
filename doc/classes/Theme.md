# Theme
[Theme]: #user-content-theme
```
type Theme
```

Theme maps a name to a value through a field. A field can have multiple
values, determined by a number of flags. When defining a field with multiple
values, each value is mapped to a combination of flags.

When making a query, a field is searched for the value that matches the
largest unambiguous subset of flags. If the given flag set does not match,
then each subset is checked. If two subsets with the same number of flags
match, then all subsets with that number of flags are skipped. If no subsets
match, then the default for the field is returned.

For example, say a field was defined with values mapped to the following sets
of flags:
- `A`
- `A|B|C`
- `A|B|D`

Then, this field is queried with the set `A|B|C|D`. The field does not define
`A|B|C|D`, so each combination of three flags is checked. This would match
both `A|B|C` and `A|B|D`. Because multiple sets have matched, all
combinations of three flags are skipped. Next, all combinations of two flags
are checked. The field does not define any sets with two flags, so there are
no matches. Finally, each single flag is checked. The field defines flag `A`,
which matches. No other single flags match, so querying flags `A|B|C|D`
returns the value of `A`.

The "Default" flag corresponds to 0, or no set flags.

## Theme.fromStudio
[Theme.fromStudio]: #user-content-themefromstudio
```
Theme.fromStudio(theme: string|StudioTheme, defs: ThemeDefs, extraFlags: ThemeFlags?): Theme
```

fromStudio returns a Theme derived from a StudioTheme. Fields of the
theme correspond to the items of the StudioStyleGuideColor enum.

*theme* is either a StudioTheme or a string corresponding to the Name of a
StudioTheme available from `Studio:GetAvailableThemes()`.

*defs* are additional field definitions. Defined fields have priority over
StudioTheme fields; if a queried field is not found, then the StudioTheme is
searched. See [Theme.new][Theme.new] for more information on field
definitions.

*extraFlags* specifies additional flags for the theme to keep track of.

The theme defines flags corresponding to the items of the
StudioStyleGuideModifier enum. When querying a StudioTheme field, the flag
set must contain exactly one of modifier names in order to match that
modifier. If the set contains more than one, or none, then the Default
modifier is used.

fromStudio throws an error if called from an identity that cannot use
StudioThemes.

## Theme.new
[Theme.new]: #user-content-themenew
```
Theme.new(defs: ThemeDefs, extraFlags: ThemeFlags?): Theme
```

new returns a new theme.

*defs* defines the fields of the theme. Each key is the name of a field. If
the value is a ThemeFieldDef, then each of its entries defines a set of flags
mapped to a value. Otherwise, the value is mapped directly to the name.

For example, the following table defines values of the "Foo" and "Bar"
fields. The Bar field defines values for each combination of the flags A, B,
and C:
```lua
def = {
	Foo = 0,
	Bar = {
		Default = 0,
		A = 1,
		B = 2,
		C = 3,
		[{"A","B"}] = 4,
		[{"A","C"}] = 5,
		[{"B","C"}] = 6,
		[{"A","B","C"}] = 7,
	},
}
```

*extraFlags* specifies additional flags for the theme to keep track of.

## Theme.Field
[Theme.Field]: #user-content-themefield
```
Theme:Field(name: string, flags: ThemeFlags|ThemeFlagSet|nil): any?
```

Field returns the value of field *name* that matches *flags*. If *flags*
is unspecified, then the Default value is returned. Returns nil if the field
was not found.

## Theme.Flags
[Theme.Flags]: #user-content-themeflags
```
Theme:Flags(flags: ThemeFlags): ThemeFlagSet
```

Flags returns an integer with each bit set corresponding to the given
flags. Flags not known by the theme are ignored.

# ThemeDefs
[ThemeDefs]: #user-content-themedefs
```
type ThemeDefs = {[string]: ThemeFieldDef|any}
```

ThemeDefs defines the fields for a theme. Each key is the name of a
field. If a value is a ThemeFieldDef, then each of its entries defines a set
of flags mapped to a value. Otherwise, the value is mapped directly to the
field, corresponding to the Default flag.

# ThemeFieldDef
[ThemeFieldDef]: #user-content-themefielddef
```
type ThemeFieldDef = {[string|ThemeFlags] = any, Default = any}
```

ThemeFieldDef maps flag sets to values.

# ThemeFlagSet
[ThemeFlagSet]: #user-content-themeflagset
```
type ThemeFlagSet = number
```

ThemeFlagSet is an integer, where each bit indicates whether a flag is
set.

# ThemeFlags
[ThemeFlags]: #user-content-themeflags
```
type ThemeFlags = {string}
```

ThemeFlags is a list of strings, each indicating the name of a flag.

