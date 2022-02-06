//
// Project Box
// Copyright (C) 2021 Nils Weber
//
// Licensed under CC BY-NC-SA 4.0
//

////////////////////////////////////////////////////////////////////////////////

/* [Dimensions] */

// Base Width
Width = 100;

// Base Depth
Depth = 50;

// Box Height
Height = 20;

/* [Screw] */

// Screw diameter
Screw_Diameter = 2;

// Screw length
Screw_Length = 4;

// Diameter of the lid hole (should be larger than Screw Diameter)
Hole_Diameter = 3;

// Thickness of the screw terminal
Terminal_Wall_Thickness = 2;

/* [Hole] */

// Offset between right wall and hole
Hole_Position = 0;

// Width of the hole
Hole_Width = 4;

// Height of the hole
Hole_Height = 4;

/* [Standoffs] */

// Whether or not to render standoffs for PCBs
Use_Standoffs = false;

// Distance between standoffs in X direction
Standoff_Length = 30;

// Distance between standoffs in Y direction
Standoff_Width = 20;

// Alignment of the standoffs on the X axis
Standoff_Alignment_X = "L"; // [T:Top, M:Middle, B:Bottom]

// Alignment of the standoffs on the Y axis
Standoff_Alignment_Y = "L"; // [L:Left, C:Center, R:Right]

// Distance to move the standoffs from their alignment position
Standoff_Offset = [0, 0];

// Height of the standoffs
Standoff_Height = 5;

// Screw diameter used to screw into the standoffs
Standoff_Screw_Diameter = 2;

// Length of the screw used to screw into the standoffs
Standoff_Screw_Length = 4;

// Thickness of the standoff walls
Standoff_Wall_Thickness = 2;


/* [Quality] */

// Thickness of outer walls and lid
Wall_Thickness = 2.4;

// Percentage to shrink the lid to be able to slide the lid
Tolerance = 0.5;

/* [Hidden] */

////////////////////////////////////////////////////////////////////////////////

$fn = 50;
width_outer = Width + Wall_Thickness * 2;
height_outer = Height + Wall_Thickness * 3;
depth_outer = Depth + Wall_Thickness * 2;

/*
module fillet_cube(dimensions, radius=1) {
	width = dimensions[0];
	depth = dimensions[1];
	height = dimensions[2];

	hull() {
		translate([0, 0, 0])
			cylinder(h=height, r=radius);
		translate([width + radius, 0, 0])
			cylinder(h=height, r=radius);
		translate([width + radius, depth + radius, 0])
			cylinder(h=height, r=radius);
		translate([0, depth + radius, 0])
			cylinder(h=height, r=radius);
	}
}
*/

terminal_diameter = Screw_Diameter + Terminal_Wall_Thickness*2;
terminal_height = Screw_Length + Terminal_Wall_Thickness*2;

difference() {
	union() {
		difference() {
			// Base
			cube([width_outer, depth_outer, height_outer]);

			// Cutout inside
			translate([Wall_Thickness, Wall_Thickness, Wall_Thickness])
				cube([Width, Depth, Height + Wall_Thickness * 2]);

			// Cutout lid

			translate([Wall_Thickness/2, Wall_Thickness/2, Wall_Thickness + Height])
				cube([Width + Wall_Thickness * 1.5, Depth + Wall_Thickness, Wall_Thickness]);
			/* translate([Wall_Thickness/2, Wall_Thickness/2, Wall_Thickness*2 + Height]) */
			/* 	cube([Width + Wall_Thickness * 1.5, Depth + Wall_Thickness, Wall_Thickness*2]); */

			// Cutout lid opening
			translate([Width + Wall_Thickness, Wall_Thickness, Height + Wall_Thickness * 2])
				cube([Wall_Thickness, Depth, Wall_Thickness]);
		}

	}

	translate([Width + Wall_Thickness, Depth + Wall_Thickness - Hole_Width - Hole_Position, Height + Wall_Thickness - Hole_Height])
		#cube([Wall_Thickness, Hole_Width, Hole_Height]);
}


translate([Width + Wall_Thickness, depth_outer/2, Height + Wall_Thickness])
	screw_terminal();

module screw_terminal() {
	module outline(height=Screw_Length) {
		union() {
			translate([0, terminal_diameter/2, 0])
				cylinder(h=height, d=terminal_diameter);
			translate([0, 0, 0])
				cube([terminal_diameter/2, terminal_diameter, height]);
		}
	}

	translate([-Terminal_Wall_Thickness - Screw_Diameter/2, -terminal_diameter/2, -Screw_Length])
	difference() {
		intersection() {
			hull() {
				translate([-terminal_diameter/2, 0, 0])
					rotate(45, [0,1,0])
					cube([terminal_diameter + Terminal_Wall_Thickness*2, terminal_diameter, Terminal_Wall_Thickness]);
				outline();
			}

			translate([0, 0, -terminal_diameter])
				outline(Screw_Length + terminal_diameter);
		}

		// Screw hole
		translate([0, terminal_diameter/2, 0])
			cylinder(h=Screw_Length, d=Screw_Diameter);
	}
}

module lid() {
	lid_thickness = Wall_Thickness - Tolerance;
	lid_width = Width + Wall_Thickness/2 + Wall_Thickness;
	lid_length = (Depth + Wall_Thickness) - Tolerance;

	difference() {
		cube ([lid_width, lid_length, lid_thickness]);

		translate([lid_width - Hole_Diameter - Wall_Thickness, lid_length/2, 0])
			cylinder(h=lid_thickness, d=Hole_Diameter);
	}
}

// Position lid on top of box
// translate([Wall_Thickness/2, Wall_Thickness/2 + Tolerance/2, Height + Wall_Thickness])
translate([0, -Depth - Wall_Thickness*4, 0])
	lid();

// Standoffs //{{{

module standoff() {
	difference() {
		cylinder(h=Standoff_Height, d=Standoff_Screw_Diameter + Standoff_Wall_Thickness * 2);
		translate([0, 0, Standoff_Height-Standoff_Screw_Length])
			cylinder(h=Standoff_Screw_Length, d=Standoff_Screw_Diameter);
	}
}

module standoffs() {
	standoff();
	translate([Standoff_Length, 0, 0])	
		standoff();
	translate([0, Standoff_Width, 0])
		standoff();
	translate([Standoff_Length, Standoff_Width, 0])
		standoff();
}

if (Use_Standoffs) {
	standoff_pos_x =
		Standoff_Alignment_X == "T" ? Wall_Thickness + Standoff_Wall_Thickness + Standoff_Screw_Diameter/2 :
		Standoff_Alignment_X == "M" ? (Width + Wall_Thickness - Standoff_Length)/2 :
		Standoff_Alignment_X == "B" ? Width + Wall_Thickness - Standoff_Wall_Thickness - Standoff_Screw_Diameter/2 - Standoff_Length :
		0;

	standoff_pos_y =
		Standoff_Alignment_Y == "L" ? Wall_Thickness + Standoff_Wall_Thickness + Standoff_Screw_Diameter/2 :
		Standoff_Alignment_Y == "C" ? (Depth + Wall_Thickness - Standoff_Width)/2 :
		Standoff_Alignment_Y == "R" ? Depth + Wall_Thickness - Standoff_Wall_Thickness - Standoff_Screw_Diameter/2 - Standoff_Width :
		0;

	standoff_pos = [standoff_pos_x, standoff_pos_y] + Standoff_Offset;
	translate(concat(standoff_pos, [Wall_Thickness]))
		standoffs();
}

//}}}
