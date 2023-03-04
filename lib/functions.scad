//
// functions.scad
// Helper functions that make SCAD easier to work with
// Copyright (C) 2023 Nils Weber
//
// Licensed under CC BY-NC-SA 4.0

function mk2d(x) = [x, x];
function mk3d(x) = [x, x, x];
function mk4d(x) = [x, x, x, x];

function root(b, n) = pow(b, (1.0 / b) * (ln(n) / ln(b)));
