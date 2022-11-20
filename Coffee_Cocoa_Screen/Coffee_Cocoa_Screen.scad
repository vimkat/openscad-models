//
// Coffee Cococa Screen
// Copyright (C) 2022 Nils Weber
//
// Licensed under CC BY-NC-SA 4.0
//

////////////////////////////////////////////////////////////////////////////////

/* [Screen] */

// Diameter of the entire screen (should be at least the diameter of your cup)
Screen_Diameter = 100;

// Thickness of the Screen
Thickness = 1;


/* [Design] */

// Diameter of the design printed on the screen
Design_Diameter = 50;

// Path to the design SVG
Design_Path = "";

////////////////////////////////////////////////////////////////////////////////

/* [Hidden] */
$fn = Screen_Diameter * 2;

module base() {
	cylinder(d=Screen_Diameter);
}

module design() {
	t = Thickness + 1;

	resize([Design_Diameter, 0, t], auto=true)
	translate([0, 0, -0.5])
	linear_extrude(t)
	import(Design_Path, center=true);
}

difference() {
	base();
	design();
}
