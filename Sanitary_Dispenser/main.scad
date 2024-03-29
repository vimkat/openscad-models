/*
 * Sanitary Dispenser
 *
 * © 2023 by Nils Weber
 * Licensed under [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/)
 */

use <../lib/solids.scad>;
use <../lib/functions.scad>;

// Variables ///////////////////////////////////////////////////////////////////

/* [Export] */

// Part of the model that should be rendered in the export
Part = "Body"; // ["Body", "Lid"]

// Generate custom supports
Supports = true;


/* [Tampons] */
Diameter = 15;
Length = 50;


/* [Pads] */
Pad_Length = 95;
Pad_Depth = 80;
Pad_Height = 7;


/* [Dispenser] */
Capacity = 30; // Number of tampons that should fit into the dispenser
Size_Grab_Point_Pads = 30;
Size_Grab_Point_Tampons = 20;


// How far should the dispenser stick out from the wall?


/* [Advanced] */
Tolerance_Tampons_Diameter = 0.5;
Tolerance_Tampons_Length = 1;
Tolerance_Pad_Length = 2;
Tolerance_Pad_Depth = 2;
Tolerance_Pad_Height = 1;
Tolerance_Lid = 0.5;
Radius = 5;
Wall_Thickness = 1.6;
Shear_Factor = 0.3;
Tampon_SVG_Path = "./tampon.svg";
Tampon_SVG_Size = [20, 0, 0];
Pad_SVG_Path = "./pad.svg";
Pad_SVG_Size = [25, 0, 0];
Nozzle = 0.4;

/* [Hidden] */
$fn = $preview ? 50 : 250;

tampon_diameter = Diameter + Tolerance_Tampons_Diameter;
tampon_length = Length + Tolerance_Tampons_Length;
tampons_per_layer = floor(Pad_Depth / tampon_diameter);

pad_length = Pad_Length + Tolerance_Pad_Length;
pad_depth = Pad_Depth + Tolerance_Pad_Depth;
pad_height = Pad_Height + Tolerance_Pad_Height;

size = [ // inner
	Radius + tampon_length + Wall_Thickness*3 + pad_length + Radius,
	pad_depth + 2*Wall_Thickness,
	tampon_diameter * ceil(1 + Capacity / tampons_per_layer),
];
corner_radii_2d = [Radius, 0, 0, 0];
corner_radii_3d = [Radius, Radius, 0, 0, Radius, Radius, 0, 0];
r_mode = ["Z", "Z", "", "", "Z", "Z", "", ""];

tampon_opening_height = tampon_diameter * 4;
tampon_compartment_size_2d = [
	Wall_Thickness + Radius + tampon_length,
	size.y,
];
pad_opening_height = pad_height * 1.5;
pad_compartment_size_2d = [
	size.x - tampon_compartment_size_2d.x - Wall_Thickness,
	size.y,
];
guard_width = (tampon_length - Size_Grab_Point_Tampons) / 2 + Wall_Thickness;
guard_height = tampon_diameter * 2;

// Modules /////////////////////////////////////////////////////////////////////

module base() {
	difference() {
		union() {
			translate([size.x/2 + Wall_Thickness, 0, 0])
			difference() {
				// base outer
				cube_r(size + mk3d(Wall_Thickness*2), r=corner_radii_3d, r_mode=r_mode, centerXY=true);

				// base inner
				translate([0, 0, Wall_Thickness])
				cube_r(size, r=corner_radii_3d, r_mode=r_mode, centerXY=true);

			}

			// separation wall
			translate([Wall_Thickness*2 + Radius + tampon_length, -size.y/2, Wall_Thickness])
			cube([Wall_Thickness, size.y, size.z]);
		}

		// cut off the top
		translate([size.x/2 + Wall_Thickness, 0, size.z + Wall_Thickness*2-1])
		cube([size.x+Wall_Thickness*2+1, size.y+Wall_Thickness*2+1, Wall_Thickness+1], center=true);
	}
}


module tampon_cutouts() {
	// front opening
	translate([0, Wall_Thickness/2 - size.y/2, Wall_Thickness*2])
	rotate([90, 0, 0])
	linear_extrude(Wall_Thickness*2)
	rect_r([tampon_length + Wall_Thickness*2, tampon_opening_height], r=Radius, center=false);

	// tampon icon
	translate([
		Wall_Thickness + tampon_length/2,
		-size.y / 2 - Wall_Thickness/2,
		tampon_diameter + tampon_opening_height + (size.z - tampon_diameter - tampon_opening_height) / 3
	])
	rotate([90, 0, 0])
	linear_extrude(Wall_Thickness/2)
	resize(Tampon_SVG_Size, auto=true)
	import(Tampon_SVG_Path, center=true);
}

module pad_cutouts() {
	// front opening
	translate([0, Wall_Thickness/2 - size.y/2, Wall_Thickness])
	rotate([90, 0, 0])
	linear_extrude(Wall_Thickness*2)
	rect_r([pad_length + Wall_Thickness*2, pad_opening_height], r=[0, 0, Radius, Radius], center=false);

	// bottom opening
	translate([Wall_Thickness + pad_length/2, -size.y/2 - Wall_Thickness, -0.5])
	cylinder(d=Size_Grab_Point_Pads, h=Wall_Thickness+1);

	// pad icon
	translate([
		Wall_Thickness + pad_length/2,
		-size.y / 2 - Wall_Thickness/2,
		pad_opening_height + (size.z - tampon_opening_height)
	])
	rotate([90, 0, 0])
	linear_extrude(Wall_Thickness/2)
	resize(Pad_SVG_Size, auto=true)
	import(Pad_SVG_Path, center=true);
}

module tampon_insides() {
	// top slope
	top_slope_width = size.y - Diameter * 1.25;
	multmatrix(shear(-Shear_Factor*1.5))
	translate([Wall_Thickness, -size.y/2, -Wall_Thickness/2 + tampon_diameter*3.75])
	cube_rc([Radius + tampon_length + Wall_Thickness, top_slope_width, Wall_Thickness/2], r=corner_radii_2d);

	// bottom slope
	translate([Wall_Thickness, -size.y/2, 0])
	multmatrix(shear(Shear_Factor))
	translate([0, 0, Wall_Thickness])
	cube_rc([Radius + tampon_length + Wall_Thickness, size.y, Wall_Thickness/2], r=corner_radii_2d);

	// left guard
	translate([Radius, -size.y/2, Wall_Thickness * 2])
	rotate([90, 0, 0])
	cube_rc([guard_width, guard_height, Wall_Thickness], r=[0, 0, Radius, 0]);

	// right guard
	translate([Wall_Thickness + Radius + tampon_length - (tampon_length - Size_Grab_Point_Tampons) / 2, -size.y/2, Wall_Thickness * 2])
	rotate([90, 0, 0])
	cube_rc([guard_width, guard_height, Wall_Thickness], r=[0, 0, 0, Radius]);
}

module supports() {
	// Tampon opening
	module tampon_support_beam() {
		translate([Wall_Thickness/2 + Radius + tampon_length/2, -size.y/2 - Wall_Thickness/2, guard_height + Wall_Thickness*1])
		cylinder(h=tampon_opening_height - guard_height + Wall_Thickness, d=Wall_Thickness);
	}

	translate([Size_Grab_Point_Tampons/2 + Radius + Wall_Thickness, 0, 0])
	tampon_support_beam();

	translate([-Size_Grab_Point_Tampons/2 - Radius, 0, 0])
	tampon_support_beam();

	// Pad opening
	module pad_support_beam() {
		translate([size.x - Radius + Wall_Thickness - pad_length/2, -size.y/2 - Wall_Thickness/2, Wall_Thickness])
		cylinder(h=pad_opening_height, d=Wall_Thickness);
	}

	translate([-Size_Grab_Point_Pads/2 - Wall_Thickness/2, 0, 0])
	pad_support_beam();

	translate([+Size_Grab_Point_Pads/2 + Wall_Thickness/2, 0, 0])
	pad_support_beam();
}

module body() {
	difference() {
		base();

		translate([Radius, 0, 0])
		tampon_cutouts();

		translate([size.x - Radius - pad_length, 0, 0])
		pad_cutouts();
	}

	tampon_insides();
	if (Supports) color("lightblue") supports();
}

module lid() {
		module lid_inside() {
			translate([-tampon_length - Wall_Thickness, 0])
			rect_r(tampon_compartment_size_2d - mk2d(Tolerance_Lid*2), r=corner_radii_2d, center=true);

			translate([tampon_length/2 + Wall_Thickness*2.5, 0])
			mirror([1, 0, 0])
			rect_r(pad_compartment_size_2d - mk2d(Tolerance_Lid*2), r=corner_radii_2d, center=true);
		}

	rotate([0, 180, 180])
	union() {
		linear_extrude(Wall_Thickness)
		rect_r(size + mk2d(Wall_Thickness*2), r=[Radius, Radius, 0, 0], center=true);

		color("tomato")
		translate([0, 0, -Wall_Thickness*2])
		linear_extrude(Wall_Thickness*2)
		difference() {
			lid_inside();
			offset(-Wall_Thickness) lid_inside();
		}
	}
}

// Functions ///////////////////////////////////////////////////////////////////

function shear(f) = [
	[1, 0, 0, 0],
	[0, 1, 0, 0],
	[0, f, 1, 0],
	[0, 0, 0, 1],
];

// Rendering ///////////////////////////////////////////////////////////////////

if (Part == "Body") body();
if (Part == "Lid") lid();
