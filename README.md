# Mac Pro Style Hexagonal Coaster (OpenSCAD)

A fully parametric OpenSCAD script for generating a hexagonal coaster featuring the 3D "cheese grater" lattice pattern inspired by the 2019 Mac Pro.

---

## Features

- **3D Mac Pro Lattice Geometry:** Front and back spherical cuts intersect mid-thickness to carve open 3-lobed (cloverleaf) pass-through vents inside each cell.
- **Dynamic Parametric Scaling:** Automatically calculates the number of concentric rings (`rings`) to fill any specified coaster size while preserving an intact outer margin.
- **Filleted Hexagonal Base:** Outer vertical corners feature configurable smooth corner fillets without distorting the exact flat-to-flat width.
- **Dual/Interleaved Lattice Alignment:** Mathematical dual-lattice offset ensures front and back patterns align cleanly.

---

## Geometric & Mathematical Principles

### 1. Hexagonal Grid Coordinates
The lattice centers are computed using 2D axial coordinates $(q, r)$:

$$\begin{aligned}
x &= \text{spacing} \cdot \left(q + \frac{r}{2}\right) \\
y &= \text{spacing} \cdot \left(r \cdot \frac{\sqrt{3}}{2}\right)
\end{aligned}$$

Points within $N$ concentric rings satisfy:

$$|q| \le N, \quad |r| \le N, \quad |q + r| \le N$$

### 2. Dual Interstitial Offset
The back face cuts ($z = 0$) are placed at the centroid of the triangles formed by three adjacent front face cuts ($z = \text{coaster\_height}$):

```math
\vec{\delta}_{\text{interstitial}} = \left[ \frac{\text{spacing}}{2}, \; \frac{\text{spacing} \cdot \sqrt{3}}{6} \right]
```

### 3. Surface Tangency & 3D Vent Overlap
To replicate the Mac Pro pattern:
- **Surface Tangent Radius:** $r_{\text{tangent}} = \text{spacing} \cdot \frac{\sqrt{3}}{4}$
- **Sphere Overlap Factor:** Scaled by $\approx 1.08\times$ so the spherical cutouts overlap mid-thickness at $z = \frac{\text{height}}{2}$, opening 3 internal vents per cup.

### 4. Dynamic Ring Count
The number of concentric rings is dynamically computed as:

```math
\text{rings} = \left\lfloor \frac{\frac{\text{coaster\_flat\_to\_flat}}{\sqrt{3}} - \text{sphere\_radius}}{\text{spacing}} \right\rfloor
```

---

## Parameters

| Parameter | Default | Description |
| :--- | :--- | :--- |
| `coaster_flat_to_flat` | `120` | Width across flats in mm |
| `coaster_height` | `9` | Coaster thickness in mm |
| `corner_radius` | `4` | Fillet radius on outer hexagon corners in mm |
| `spacing` | `coaster_height * 1.888` | Distance between sphere centers in mm |
| `sphere_radius` | `spacing * sqrt(3) / 4 * 1.08` | Radius of spherical cutout volumes |
| `rings` | *auto-calculated* | Number of concentric hexagonal rings |
| `$fn` | `80` | Facet resolution for spheres and fillets |

---

## Rendering & CLI Commands

### 1. Quick Full Render
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  --render --viewall \
  -o coaster.png hex_coaster.scad
```

### 2. Top (Front) View
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  --render --viewall \
  --camera "0,0,0,0,0,0,30" \
  -o front_view.png hex_coaster.scad
```

### 3. Bottom (Back) View
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  --render --viewall \
  --camera "0,0,0,180,0,0,30" \
  -o back_view.png hex_coaster.scad
```

### 4. Isometric Preview (DeepOcean Colorscheme)
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  --colorscheme "DeepOcean" \
  --imgsize 1024,1024 \
  --autocenter --viewall \
  --camera "0,0,0,55,0,25,250" \
  --render \
  -o isometric.png hex_coaster.scad
```

### 5. Export to STL for 3D Printing
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  -o hex_coaster.stl hex_coaster.scad
```
