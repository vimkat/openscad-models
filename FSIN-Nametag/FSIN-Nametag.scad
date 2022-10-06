//
// FSIN Nametag
// Copyright (C) 2021 Nils Weber
//
// Licensed under CC BY-NC-SA 4.0
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
Name = "Fachschaf";

// Thickness of the printed name
Thickness_Name = 0.5;

// Use small caps text style
Use_Smallcaps = true;


/* [Image] */

// Display an additional image on the right
Additional_Image = false;

// Path to the additional image
Additional_Image_Path = "";


/* [Hidden] */

$fn = 50;
logo = "fsin_compact_bw.svg";
logo_size = Height - 4 * Margin;
text_size = Height - 6 * Margin;
font = "FiraCode Nerd Font:bold";

////////////////////////////////////////////////////////////////////////////////
function substr(data, i, length=0) = (length == 0) ? _substr(data, i, len(data)) : _substr(data, i, length+i);
function _substr(str, i, j, out="") = (i==j) ? out : str(str[i], _substr(str, i+1, j, out));

function is_lowercase(char) =
	(ord(char) >= ord("a") && ord(char) <= ord("z"))
	|| char == "ä"
	|| char == "ö"
	|| char == "ü";

function to_upper(char) = is_lowercase(char) ? chr(ord(char) - 32) : char;

function offsets(string) = _offsets(string, [0]);
function _offsets(string, acc) =
    len(string) == 0
        ? acc
        : _offsets(substr(string, 1),
                   concat(acc,
                          acc[len(acc)-1] + (is_lowercase(string[0]) ? 0.64 : 0.90)));
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
    offs = offsets(Name);
    text_width = offs[len(offs)-1] * text_size;
    x_offset = (width-text_width)/2;
    
    /*
    // DEBUG: Text alignment helper
    %translate([0,-3,0]) cube([width, 1, 1]);
    %translate([x_offset,-2,0]) cube([text_width, 1, 1]);
    */
    
    for (i = [0:len(Name)-1]) {
        c = Name[i];

        translate([x_offset + offs[i] * text_size, 0, 0])
        linear_extrude(Thickness_Name)
            text(to_upper(c), size=text_size * (is_lowercase(c) ? 0.7 : 1), spacing=1, halign="left", font=font);
    }
}

if (Use_Smallcaps) {
    translate([Margin * 3 + logo_size, Margin * 3, Thickness_Base])
    color("black")
        smallcaps(Name, text_size, Width-logo_size - 5*Margin - (Additional_Image ? logo_size : 0));
} else {
    color("black")
    translate([Width/2 + logo_size/2, Height/2, Thickness_Base])
    linear_extrude(Thickness_Name)
        text(Name, size=text_size, halign="center", valign="center", font=font);
}


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
resize([logo_size, logo_size, 0])
	import(logo);

if (Additional_Image) {
    translate_vector = [Width - Margin*2-logo_size/2, Margin*2+logo_size/2, Thickness_Base];

    if (Additional_Image_Path == "") {
        %translate(translate_vector)
        color("red")
            cube([logo_size, logo_size, Thickness_Name], center=true);
    } else {
        translate(translate_vector)
        color("black")
        linear_extrude(Thickness_Name)
        resize([logo_size, 0, 0], auto=true)
            import(Additional_Image_Path, center=true);
    }
}
