//
// Map Marker
// Copyright (C) 2022 Nils Weber
//
// Licensed under CC BY-NC-SA 4.0
//

/* [Dimensions] */

// Diameter of the (inner) circle
Diameter = 25;

// Thickness of the (outside) wall
Wall = 2.4;

// Thickness of the entire marker
Thickness = 1;

/* [Marker] */

// Diameter of the marker ring
Marker_Diameter = 5;

// Text of the marker
Marker_Text = "1";

Font = "Roboto:bold";

/* [Hidden] */

$fn = 100;

ring_diameter = Diameter+Wall*2;
ring_radius = ring_diameter/2;
marker_offset = (ring_diameter - Marker_Diameter) / 2;
marker_text_size = Marker_Diameter * 0.85;

module base(marker, thickness=Thickness) {
    linear_extrude(thickness)
    difference() {
        
        // Base shape
        hull() {
            // Main ring
            circle(d=ring_diameter);

            // Marker
            translate([marker_offset, marker_offset, 0])
                circle(d=Marker_Diameter);
        }
        
        // Ring hole
        circle(d=Diameter);
        
        // Marker text
        translate([marker_offset - Wall/3, marker_offset - Wall/3, 0])
            text(marker, font=Font, size=marker_text_size, halign="center", valign="center");
    }
}


base(Marker_Text);
