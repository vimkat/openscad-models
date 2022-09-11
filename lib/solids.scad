//
// solids.scad
// Library for basic solid objects
// Copyright (C) 2022 Nils Weber
//
// Licensed under CC BY-NC-SA 4.0
//

////////////////////////////////////////////////////////////////////////////////

// cube_rc produces a cube with rounded corners but a flat top/bottom.
//
// wx       Size in X direction
// wy       Size in Y direction
// h        Height/thickness of the cube
// r        Radius of the rounded corners (has to be > 0)
// centerXY Translates the cube into the center on the XY-plane
// centerXY Translates the cube into the center on the Z-plane
module cube_rc(wx, wy, h, r, centerXY=false, centerZ=false) {
	translate([
		centerXY ? -wx/2 : 0,
		centerXY ? -wy/2 : 0,
		centerZ  ? -h/2  : 0,
	])
	hull() {
		translate([r, r, h/2])
		cylinder(h=h, r=r, center=true);
		translate([wx-r, r, h/2])
		cylinder(h=h, r=r, center=true);
		translate([wx-r, wy-r, h/2])
		cylinder(h=h, r=r, center=true);
		translate([r, wy-r, h/2])
		cylinder(h=h, r=r, center=true);
	}
}
