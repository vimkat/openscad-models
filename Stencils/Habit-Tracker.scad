//
// Project Box
// Copyright (C) 2021 Adiac, Nils Weber
//
// Licensed under CC BY-NC-SA 4.0
//

////////////////////////////////////////////////////////////////////////////////

/* [Stencil Configuration] */

// Height per line on the paper (horizontal space between boxes) and therefore width/height of each checkbox
Line_Height = 6;

// Number of boxes in the vertical (Y) direction
Number_of_boxes_vertical = 9;

// Number of boxes in the horizontal (X) direction
Number_of_boxes_horizontal = 7;

// Space between boxes in the horizontal (X) direction
Horizontal_Space = 10;


/* [Look and Feel] */

// Thickness of the stencil
Stencil_Thickness = 1;

// Width of the slope on all edges
Slope_Size = 2;

/* [Hidden] */

////////////////////////////////////////////////////////////////////////////////

//CALCS
boxSize = Line_Height;
templateHeight = (Number_of_boxes_vertical * 2 + 1) * Line_Height;
templateWidth = (Number_of_boxes_horizontal + 1) * Horizontal_Space;

startX = (Horizontal_Space*2 - boxSize) / 2;
startY = Line_Height;
stepX = Horizontal_Space;
stepY = Line_Height * 2;

difference() {
	slopedCube([templateWidth,templateHeight], [templateWidth-Slope_Size, templateHeight-Slope_Size], Stencil_Thickness);

	for(iY = [0:Number_of_boxes_vertical-1]) {
		currentY = startY + iY * stepY;

		for(iX = [0:Number_of_boxes_horizontal-1]) {
			currentX = startX + iX * stepX;

			#translate([currentX,currentY, 0])
				slopedCube([Line_Height, Line_Height],
				           [Line_Height+Slope_Size,
				           Line_Height+Slope_Size],
				           Stencil_Thickness);
		}
	}
}


function to3d(dim2d, d3=0) = [dim2d[0], dim2d[1], d3];
module slopedCube(size_bottom, size_top, height) {
	cube_size_top = to3d(size_top, 0.001);
	cube_size_bottom = to3d(size_bottom, 0.001);

	translate(to3d(size_bottom)/2)
	hull() {
		translate([0, 0, height])
			cube(cube_size_top, center=true);

		cube(cube_size_bottom, center=true);
	}
}
