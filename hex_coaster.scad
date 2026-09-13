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

// --------------------------------------------------------------------
// Viewport Animation Control
// --------------------------------------------------------------------
// Target and framing
$vpt = [0, 0, 0];
$vpd = 230;
$vpf = 35; // Field of view (degrees)

// Simplified 3-stage viewport sequence:
// Total angular travel = 405 + 855 + 180 = 1440°
//   Stage 1: [0,  0, 0]   -> [405, 0, 45]   (x flips 360° then blends z during last 45°)
//   Stage 2: [45, 0, 45]  -> [75,  0, 900]  (continuous climb 45°->75° on x, 45°->900° on z)
//   Stage 3: [75, 0, 900] -> [0,   0, 1080] (smooth return to flat: 1080 ≡ 0)

t1 = 405 / 1440;
t2 = t1 + 855 / 1440;
// Stage 3 runs t2 to 1.0

// Threshold inside Stage 1 where full 360° flip ends and blend begins (360/405 ≈ 0.889)
blend_thresh = 360 / 405;

$vpr = ($t < t1) ?
    let(u = $t / t1)
    (u < blend_thresh) ?
        // Pure flip: 0° -> 360° on x, 0° on z
        [360 * (u / blend_thresh), 0, 0] :
        // Blend zone: 360° -> 405° on x, 0° -> 45° on z
        let(v = (u - blend_thresh) / (1 - blend_thresh))
        [360 + 45 * v, 0, 45 * v] :
    ($t < t2) ?
    // Stage 2: smooth continuous pitch climb 45° -> 75° and yaw rotation 45° -> 900°
    let(u = ($t - t1) / (t2 - t1))
    [45 + (75 - 45) * u, 0, 45 + (900 - 45) * u] :
    // Stage 3: return from [75, 0, 900] to [0, 0, 1080] (1080° ≡ 0°)
    let(u = ($t - t2) / (1 - t2))
    [75 * (1 - u), 0, 900 + 180 * u];

