# Lattice
[Lattice]: #user-content-lattice
```
type lattice
```

Lattice is a container that positions and sizes its children using the
grid-like "lattice" layout. The X and Y axes of the grid each consist of a
list of "spans". A span is a numeric value with either a constant or
fractional unit:

- `px`: A constant size, in UDim.Offset units.
- `fr`: A fraction of the remaining non-constant span of the axis. The
  calculated fraction is the value divided by the sum of all fr units on the
  axis. So, if an axis contained `1fr`, `2fr`, `3fr`, and `1fr`, the total
  space would be 7 fractional units, and the `2fr` would take up 2/7 of the
  available fractional space.

The position and size of an object is defined in terms of a rectangle of
cells on the grid.

The calculated positions and sizes of objects are static; the given bounds of
an object is reduced to a Position and Size UDim2, which are applied to the
object. This makes resizing a lattice container inexpensive.

## Lattice.new
[Lattice.new]: #user-content-latticenew
```
Lattice.new(): Lattice
```

new returns a new Lattice container.

## Lattice.AddChild
[Lattice.AddChild]: #user-content-latticeaddchild
```
Lattice:AddChild(child: GuiObject, x0: number, y0: number, x1: number, y1: number)
Lattice:AddChild(child: GuiObject, v: Vector2)
Lattice:AddChild(child: GuiObject, rect: Rect)
```

AddChild adds *child* to the lattice at a given position. The remaining
arguments specify the lower and upper bounds that determine the position and
size of the child:

- *x0* is the X coordinate of the lower bound.
- *y0* is the Y coordinate of the lower bound.
- *x1* is the X coordinate of the upper bound.
- *y1* is the Y coordinate of the upper bound.
- *v* specifies the lower bound. The upper bound is determined by adding 1 to
  each coordinate of the lower bound.
- *rect* specifies the bounds from a rectangle.

Each component is converted to an integer, and normalized so that the
resulting rectangle is not inverted.

The resulting rectangle determines the position and size of the object in
cell coordinates. If the rectangle lies partially outside the lattice grid,
then the components are constrained. If the rectangle lies completely outside
the grid, then the object is not rendered.

## Lattice.Columns
[Lattice.Columns]: #user-content-latticecolumns
```
Lattice:Columns(): {Span}
```

Columns returns the columns of the Lattice.

## Lattice.Constraints
[Lattice.Constraints]: #user-content-latticeconstraints
```
Lattice:Constraints(): (min: Vector2, max: Vector2)
```

Constraints returns the constraints applied to the Lattice's container.
*min* is the minimum size of the fractional space for each axis, while *max*
is the maximum size. Units are the same as UDim.Offset.

## Lattice.GetChildren
[Lattice.GetChildren]: #user-content-latticegetchildren
```
Lattice:GetChildren(): {GuiObject}
```

GetChildren returns the child objects of the Lattice container.

## Lattice.Instance
[Lattice.Instance]: #user-content-latticeinstance
```
Lattice:Instance(): Instance
```

Instance returns the GuiObject that contains the cells of the grid.

## Lattice.Rect
[Lattice.Rect]: #user-content-latticerect
```
Lattice:Rect(child: GuiObject): Rect?
```

Rect returns the cell boundary of *child*. Returns nil if *child* is not
in the container.

## Lattice.RemoveChild
[Lattice.RemoveChild]: #user-content-latticeremovechild
```
Lattice:RemoveChild(child: GuiObject)
```

RemoveChild removes *child* from the lattice. Does nothing if *child* is
not in the container.

## Lattice.Rows
[Lattice.Rows]: #user-content-latticerows
```
Lattice:Rows(): {Span}
```

Rows returns the rows of the Lattice.

## Lattice.SetColumns
[Lattice.SetColumns]: #user-content-latticesetcolumns
```
Lattice:SetColumns(columns: {Span|string})
```

SetColumns sets the columns of the Lattice. If an entry in *columns* is
a string, it must be formatted as `<number><unit>`, where `<number>` is a
valid number, and `<unit>` is either `px` or `fr`.

## Lattice.SetConstraints
[Lattice.SetConstraints]: #user-content-latticesetconstraints
```
Lattice:SetConstraints(min: Vector2?, max: Vector2?)
```

SetConstraints applies constraints to the size of the fractional space
of the Lattice's container. *min* determines the minimum size of the
fractional space for each axis, while *max* determines the maximum size.
Units are the same as UDim.Offset.

If *min* is nil, then the minimum size is 0. If *max* is nil, then the
maximum size is unbounded.

## Lattice.SetRows
[Lattice.SetRows]: #user-content-latticesetrows
```
Lattice:SetRows(rows: {Span|string})
```

SetRows sets the rows of the Lattice. If an entry in *rows* is a string,
it must be formatted as `<number><unit>`, where `<number>` is a valid number,
and `<unit>` is either `px` or `fr`.

# Span
[Span]: #user-content-span
```
type Span = {
	N: number,
	U: string,
}
```

Span describes a value of a Lattice span. Field `N` is the value of the
span, and field `U` is the unit, which should be either "px" or "fr".

