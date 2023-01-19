//
// Power Strip Mount
// Copyright (C) 2023 Nils Weber
//
// Licensed under CC BY-NC-SA 4.0
//

////////////////////////////////////////////////////////////////////////////////

Height = 57.5;

Depth = 41;

Width = 3.5;

Thickness = 2;

Height_Clamps = 10;

Width_Mount = 5;

Height_Mount = 5;

All_Closed = false;

linear_extrude(Width)
union() {
	difference() {
		square([Depth + Thickness*2, Height + Thickness*2]);

		translate([Thickness, Thickness])
		square([Depth, Height]);

		if (!All_Closed) {
			translate([-Thickness/2, Height_Clamps+Thickness])
			square([Thickness*2, Height - Height_Clamps*2]);
		}
	}

	translate([Depth+Thickness*2, Height+Thickness - Height_Mount])
	difference() {
		square([Width_Mount + Thickness, Height_Mount + Thickness]);

		translate([-1,-1])
		square([Width_Mount+1, Height_Mount+1]);
	}
}
