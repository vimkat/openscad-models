//
// FSIN Nametag
// Copyright (C) 2021 Nils Weber
//
// Licensed under the MIT License
//

////////////////////////////////////////////////////////////////////////////////

/* [Base] */

// Width of the nametag
Width = 80;

// Height of the nametag
Height = 20;

// Thickness of the nametag base
Thickness_Base = 2;

// Radius of the base plate corners
Roundness = 2; // [0.1:16]

// Size of the border around the nametag
Margin = 2;


/* [Name] */

// Name displayed on the nametag
Name = "JULIAN";

// Thickness of the printed name
Thickness_Name = 0.5;


/* [Hidden] */

$fn = 50;
logo = "fsin_compact_bw.svg";
logo_size = Height - 4 * Margin;
text_size = Height - 6 * Margin;
font = "FiraCode Nerd Font:bold";

echo(logo_size);

////////////////////////////////////////////////////////////////////////////////
function substr(data, i, length=0) = (length == 0) ? _substr(data, i, len(data)) : _substr(data, i, length+i);
function _substr(str, i, j, out="") = (i==j) ? out : str(str[i], _substr(str, i+1, j, out));
////////////////////////////////////////////////////////////////////////////////

// The base plate of the nametag
module base(width, height, thickness, radius) {
	color("white")
		hull() {
			translate([radius, radius, 0])
				cylinder(h=thickness, r=radius);
			translate([width - radius, radius,0])
				cylinder(h=thickness, r=radius);
			translate([width - radius, height - radius, 0])
				cylinder(h=thickness, r=radius);
			translate([radius, height - radius, 0])
				cylinder(h=thickness, r=radius);
		}
}

base(Width, Height, Thickness_Base, Roundness);

module smallcaps(Name, text_size, width) {
    text_width = text_size * 0.9 + (len(Name)-1) * text_size * 0.64;
    x_offset = (width-text_width)/2;
    
    /*
    %translate([0,-3,0]) cube([width, 1, 1]);
    %translate([x_offset,-2,0]) cube([text_width, 1, 1]);
    */
    
    // First letter
    translate([x_offset, 0, 0])
    linear_extrude(Thickness_Name)
        text(Name[0], size=text_size, halign="left", font=font);

    // Rest
    translate([x_offset + text_size * 0.9, 0, 0])
    linear_extrude(Thickness_Name)
        text(substr(Name, 1), size=text_size*0.7, spacing=1.1, halign="left", font=font);
}

translate([Margin * 3 + logo_size, Margin * 3, Thickness_Base])
color("black")
smallcaps(Name, text_size, Width-logo_size - 5*Margin);

difference() {
	translate([0, 0, Thickness_Base])
	color("black")
		base(Width, Height, Thickness_Name, Roundness);

	translate([Margin, Margin, Thickness_Base])
		base(Width - Margin * 2, Height - Margin * 2, Thickness_Name + 1, Roundness);
}

translate([Margin * 2, Margin * 2, Thickness_Base])
color("black")
linear_extrude(Thickness_Name)
resize([logo_size, logo_size, Thickness_Base])
	import(logo);
