//
// Stamp
// Copyright (C) 2022 Nils Weber
//
// Licensed under CC BY-NC-SA 4.0
//

////////////////////////////////////////////////////////////////////////////////

/* [Stamp Handle] */

// The shape of the stamp/handle
Stamp_Shape = "Cylindrical"; // [Cylindrical, Rectangular]

// Height of the stamp handle
Stamp_Height = 25;

/* [Stamp Stencil] */

// Diameter of the stamp
Stamp_Diameter = 15;

// Diameter of the stamp on the secondary axis (only used for rectangular stamps)
Stamp_Diameter_Secondary = 15;

// SVG file of the stencil design
Stencil_SVG = "";

// Invert stencil design
Invert_Stencil = false;

// Thickness of the stencil
Stencil_Thickness = 1;

// Thickness of the border drawn around the stencil (0 to deactivate)
Stencil_Border = 0;

// Size by with to shrink the stencil design (useful to adjust padding to border)
Stencil_Inset = 0;

/* [Hidden] */

$fn = 250;

size_x = Stamp_Diameter;
size_y = Stamp_Shape == "Cylindrical" ? Stamp_Diameter : Stamp_Diameter_Secondary;

////////////////////////////////////////////////////////////////////////////////

module base() {
	// Select stamp handle shape
	if (Stamp_Shape == "Cylindrical") {
		cylinder(h=Stamp_Height, d=Stamp_Diameter);
	} else if (Stamp_Shape == "Rectangular") {
		translate([-size_x/2, -size_y/2, 0])
		cube([size_x, size_y, Stamp_Height]);
	}
}

module stencil_inverted() {
	difference() {
		// Stencil base
		if (Stamp_Shape == "Cylindrical") {
			cylinder(h=Stencil_Thickness, d=size_x);
		} else if (Stamp_Shape == "Rectangular") {
			translate([-size_x/2, -size_y/2, 0])
			cube([size_x, size_y, Stencil_Thickness]);
		}

		// Stencil border
	if (Stencil_Border > 0) {
		if (Stamp_Shape == "Cylindrical") {
			translate([0, 0, -0.5]) // fix artifacts
			difference() {
				cylinder(h=Stencil_Thickness+1, d=Stamp_Diameter - Stencil_Border);
				cylinder(h=Stencil_Thickness+1, d=Stamp_Diameter - Stencil_Border*2);
			}
		} else if (Stamp_Shape == "Rectangular") {
			translate([-size_x/2, -size_y/2, 0])
			difference() {
				translate([Stencil_Border/2, Stencil_Border/2, -0.5])
				cube([size_x - Stencil_Border, size_y - Stencil_Border, Stencil_Thickness+1]);

				translate([Stencil_Border, Stencil_Border, -0.5])
				cube([size_x - Stencil_Border*2, size_y - Stencil_Border*2, Stencil_Thickness+1]);
			}
		}
	}

		// Stencil design
	if (Stencil_SVG != "") {
			translate([0, 0, -0.5]) // fix artifacts
			linear_extrude(Stencil_Thickness+1)
			resize([size_x - Stencil_Border*3 - Stencil_Inset, 0, 0], auto=true)
			mirror([1, 0, 0])
			import(Stencil_SVG, center=true);
		}
	}
}

module stencil_regular() {
	// Stencil border
	if (Stencil_Border > 0) {
		if (Stamp_Shape == "Cylindrical") {
			difference() {
				cylinder(h=Stencil_Thickness, d=Stamp_Diameter);
				translate([0, 0, -0.5]) // fix artifacts
				cylinder(h=Stencil_Thickness+1, d=Stamp_Diameter - Stencil_Border);
			}
		} else if (Stamp_Shape == "Rectangular") {
			translate([-size_x/2, -size_y/2, 0])
			difference() {
				cube([size_x, size_y, Stencil_Thickness]);

				translate([Stencil_Border/2, Stencil_Border/2, -0.5])
				cube([size_x - Stencil_Border, size_y - Stencil_Border, Stencil_Thickness+1]);
			}
		}
	}

	// Stencil Design
	if (Stencil_SVG != "") {
		linear_extrude(Stencil_Thickness)
		resize([size_x - Stencil_Border*2 - Stencil_Inset, 0, 0], auto=true)
		mirror([1, 0, 0])
		import(Stencil_SVG, center=true);
	}
}

////////////////////////////////////////////////////////////////////////////////

base();

translate([0, 0, Stamp_Height])
if (Invert_Stencil) {
	stencil_inverted();
} else {
	stencil_regular();
}

