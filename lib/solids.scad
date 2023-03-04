//
// solids.scad
// Library for basic solid objects
// Copyright (C) 2023 Nils Weber
//
// Licensed under CC BY-NC-SA 4.0
//

////////////////////////////////////////////////////////////////////////////////

// cube_rc produces a cube with rounded corners but a flat top/bottom.
module cube_rc(s, r, center=undef, centerXY=false, centerZ=false) {
	_centerXY = is_undef(center) ? centerXY : center;
	_centerZ = is_undef(center) ? centerZ : center;

	translate([0, 0, _centerZ ? h/2 : 0])
	linear_extrude(s.z)
	rect_r(s, r, center=_centerXY);
}

// rect_r produces a rectangle with rounded corners.
module rect_r(s, r, center=false) {
	_r = is_list(r) ? r : [r, r, r, r];

	module corner(i) {
		translate([
			(i == 1 || i == 2 ? s.x : _r[i]*2) - _r[i],
			(i == 2 || i == 3 ? s.y : _r[i]*2) - _r[i],
		])
		if (_r[i]) {
			circle(r=_r[i]);
		} else {
			translate([
				s.x/4 * (i == 1 || i == 2 ? -1 : 1),
				s.y/4 * (i == 2 || i == 3 ? -1 : 1),
			])
			square([s.x/2, s.y/2], center=true);
		}
	}

	translate(
		center
			? [-s.x/2, -s.y/2]
			: [0, 0])
	hull() {
		corner(0);
		corner(1);
		corner(2);
		corner(3);
	}
}

module cube_r(s, r, r_mode=undef, center=undef, centerXY=false, centerZ=false) {
	_r = is_list(r) ? r : [r, r, r, r, r, r, r, r];

	module corner(i) {
		translate([
			((i%4) == 1 || (i%4) == 2 ? s.x : _r[i]*2) - _r[i],
			((i%4) == 2 || (i%4) == 3 ? s.y : _r[i]*2) - _r[i],
			(i >= 4 ? s.z - _r[i] : _r[i]),
		])

		if (_r[i] != 0) {
			// rounding needs to happen
			_mode = is_undef(r_mode) ? "XYZ" : r_mode[i];

			// decide rounding based on _mode
			if (_mode == "XYZ") {
				// rounded in X/Y/Z (the standard)
				sphere(r=_r[i]);
			} else {
				// check mask for rounding axis
				assert(len(_mode) == 1, concat(str("rounding mode for corner ", i, " has to be 'XYZ' or a single axis, '", r_mode[i], "' given")));
				translate([
					_mode=="X" ? (s.x/4 - _r[i]) * ((i%4) == 1 || (i%4) == 2 ? -1 : 1) : 0,
					_mode=="Y" ? (s.y/4 - _r[i]) * ((i%4) == 2 || (i%4) == 3 ? -1 : 1) : 0,
					_mode=="Z" ? (s.z/4 - _r[i]) * (i >= 4 ? -1 : 1) : 0,
				])
				resize([
					_mode == "X" ? s.x/2 : 0,
					_mode == "Y" ? s.y/2 : 0,
					_mode == "Z" ? s.z/2 : 0,
				], auto=false)
				rotate(
					_mode == "Z"
						? [0, 0, 0]
					: _mode == "Y"
						? [90, 0, 0]
					: _mode == "X"
						? [0, 90, 0]
					: assert(false, "invalid r_mode") // can't happen because of assert above
				)
				cylinder(r=_r[i], h=1, center=true);
			}
		} else {
			// no rounding at all
			translate([
				s.x/4 * ((i%4) == 1 || (i%4) == 2 ? -1 : 1),
				s.y/4 * ((i%4) == 2 || (i%4) == 3 ? -1 : 1),
				s.z/4 * (i >= 4 ? -1 : 1),
			])
			cube([s.x/2, s.y/2, s.z/2], center=true);
		}
	}


	_centerXY = is_undef(center) ? centerXY : center;
	_centerZ = is_undef(center) ? centerZ : center;
	translate([
		_centerXY ? -s.x/2 : 0,
		_centerXY ? -s.y/2 : 0,
		_centerZ  ? -s.z/2  : 0,
	])

	hull() {
		corner(0);
		corner(1);
		corner(2);
		corner(3);
		corner(4);
		corner(5);
		corner(6);
		corner(7);
	}
}
