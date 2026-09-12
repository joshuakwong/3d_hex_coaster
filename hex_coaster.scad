// ====================================================================
// Parametric 2019 Mac Pro Style Hexagonal Coaster
// True 3D "Cheese Grater" Lattice Pattern
// ====================================================================

// --------------------------------------------------------------------
// Key Parameters
// --------------------------------------------------------------------
coaster_flat_to_flat = 120; // mm width across flats
coaster_height       = 9;   // mm thickness
corner_radius        = 4;   // mm fillet radius on outer hexagonal corners
spacing              = coaster_height * 1.888; // distance between sphere centers

// Sphere radius derived from tangent geometry with overlap factor for 3D vent openings
sphere_radius        = spacing * sqrt(3) / 4 * 1.08; 

// Automatically calculate number of rings to dynamically fill any coaster size
rings = floor((coaster_flat_to_flat / sqrt(3) - sphere_radius) / spacing);

$fn                  = 80;  // resolution

// --------------------------------------------------------------------
// Coordinate Transformation Functions
// --------------------------------------------------------------------

// Convert axial hexagonal coordinates (q, r) to 2D Cartesian (x, y)
function hex_to_cartesian(q, r, sp) = [
    sp * (q + r * 0.5),
    sp * (r * sqrt(3) / 2)
];

// Interstitial XY offset for dual triangular lattice
function get_interstitial_offset(sp) = [
    sp / 2,
    sp * sqrt(3) / 6
];

// --------------------------------------------------------------------
// Geometry Modules
// --------------------------------------------------------------------

// Regular hexagonal base with rounded corner fillets
module hex_base(width, height, r_corner = 4) {
    if (r_corner > 0) {
        // Base circumradius adjusted so flat-to-flat width remains exact after offset
        r_inner_base = (width - 2 * r_corner) / sqrt(3);
        linear_extrude(height = height) {
            offset(r = r_corner, $fn = $fn)
                circle(r = r_inner_base, $fn = 6);
        }
    } else {
        r_outer = width / sqrt(3);
        cylinder(r = r_outer, h = height, $fn = 6);
    }
}

// Generate concentric hexagonal grid of cutout spheres on front face (z = coaster_height)
module front_spheres() {
    for (q = [-rings : rings]) {
        r_min = max(-rings, -rings - q);
        r_max = min(rings, rings - q);
        for (r = [r_min : r_max]) {
            pos = hex_to_cartesian(q, r, spacing);
            translate([pos[0], pos[1], coaster_height])
                sphere(r = sphere_radius);
        }
    }
}

// Generate interleaved/interstitial cutout spheres on back face (z = 0)
// Uses geometric boundary check to ensure a clean, unbroken outer coaster wall
module back_spheres() {
    offset = get_interstitial_offset(spacing);
    inradius = coaster_flat_to_flat / 2;
    max_center_radius = inradius - sphere_radius;

    for (q = [-rings - 1 : rings + 1]) {
        for (r = [-rings - 1 : rings + 1]) {
            pos = hex_to_cartesian(q, r, spacing);
            bx = pos[0] + offset[0];
            by = pos[1] + offset[1];
            
            // Only place spheres within the safe coaster boundary
            if (norm([bx, by]) <= max_center_radius) {
                translate([bx, by, 0])
                    sphere(r = sphere_radius);
            }
        }
    }
}

// Complete Coaster Assembly
module mac_pro_hex_coaster() {
    difference() {
        hex_base(coaster_flat_to_flat, coaster_height, corner_radius);
        front_spheres();
        back_spheres();
    }
}

// Render the coaster
mac_pro_hex_coaster();
