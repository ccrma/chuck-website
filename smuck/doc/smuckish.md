# SMucKish: The input language of SMucK

- ["Interleaved" Input]
- ["Multi-stage" Input]
- [Pitch](#)
    - [Key Signature](#key-signature)
- [Rhythm](#change-color)
- [Dynamics](#change-the-lighting)
-

## "Interleaved" Input Syntax
The "interleaved" input syntax is a way to specify pitch, rhythm, and dynamics in a single string. As a quick example:
```
Measure measure("c4|q|mf d e f g|e|mp a b c")
```
Output:
![interleaved 1](../images/interleaved_1.svg)


```
dsfjsdlfjsdklfs
```


## Pitch

### Pitch Strings
```
"a"           // A (octave 4 by default)
"a#"          // A-sharp
"a##"         // A-double-sharp (works for an arbitrary number of sharps, e.g. "a######")
"ab"          // A-flat
"abb"         // A-double-flat (works for an arbitrary number of flats, e.g. "abbbbb")
"an"          // A-natural


"a2"          // A in octave 2 (valid octave range is 0-9)
"a


"a3"  // A in octave 3

"a#3" // a sharp in octave 3
```

```
Measure measure;
measure.set_pitch("C4 B D")
```

The position, rotation, and scale of an object is called its **Transform**. Transform data, and methods for manipulating that data, are contained entirely in the `GGen` "Graphics Generator" class. As a quick example:

```c
GCube cube --> GG.scene(); // connect a cube to the scene
cube.pos(@(1,2,3)); // set cube's position to xyz coordinate (1,2,3)
cube.scaX(2); // double the cube's width along the x axis

while (true) {
 GG.nextFrame() => now;
 GG.dt() => cube.rotateY; // rotate the cube on its y axis
}
```

For rotation, to avoid [gimbal lock](https://en.wikipedia.org/wiki/Gimbal_lock) prefer using the `rotate` and `lookAt` functions below (which internally are implemented with quaternions rather than Euler angles )

```c
// Recommended rotation methods
GGen ggen;

// Rotate this GGen by the given radians on the X axis in local space.
ggen.rotateX(float radians)

// Rotate this GGen by the given radians on the Y axis in local space.
ggen.rotateY(float radians)

// Rotate this GGen by the given radians on the Z axis in local space.
ggen.rotateZ(float radians)

// Rotate this GGen by the given radians on the given axis in local space.
ggen.rotateOnLocalAxis(vec3 axis, float radians)

// Rotate this GGen by the given radians on the given axis in world space.
ggen.rotateOnWorldAxis(vec3 axis, float radians)

// Rotate this ggen to face the given position in world space.
ggen.lookAt(vec3 pos)
```

Find more info in the links below.

### CKdoc <!-- omit in toc -->

- [GGen](https://chuck.stanford.edu/chugl/api/chugl-ggens.html#GGen)

### Examples <!-- omit in toc -->

- [basic/orbits.ck](https://chuck.stanford.edu/chugl/examples/basic/orbits.ck)

### Further Learning Resources <!-- omit in toc -->

- <https://learnopengl.com/Guest-Articles/2021/Scene/Scene-Graph>

___

## Change color?

Colors are represented as RGB values where each channel value ranges from 0 to 1. Most color methods in ChuGL take color input as a chuck `vec3`. For example:

```c
GCube cube --> GG.scene();

cube.color(@(1, 0, 0));  // make the cube red
cube.color(@(0, 1, 0));  // make the cube green
cube.color(@(0, 0, 1));  // make the cube blue
```

ChuGL also comes with a helpful `Color` class that includes builtin colors:

```c
// Color utility class

// builtin colors
Color.MAGENTA => cube.color;
Color.SKY => cube.color;

// random color!
Color.random() => cube.color;

// helper functions for converting between hsv and rgb color spaces
Color.hsv2rgb(vec3 hsv);
Color.rgb2hsv(vec3 rgb);
```

Online color pickers often return RGB color values in the range (0,255) rather than (0,1). To convert, simply divide each channel by 255. A value of `@(1,1,1)` corresponds to the color `(255, 255, 255)`.

```c
// using the rgb8unorm color (50, 102, 168)
@(50, 102, 168) / 255 => cube.color;
```

ChuGL by default supports a **HDR** render pipeline, meaning that you can supply color intensities greater than `1`, and they will be tone-mapped down back to into **LDR** (low-dynamic range) in the final output pass. This is useful for advanced lighting effects such as physically-based rendering and bloom.

### CKdoc <!-- omit in toc -->

- [Color](https://chuck.stanford.edu/chugl/api/chugl-basic.html#Color)
  
___

## Change the Lighting?

ChuGL currently supports 2 dynamic lighting types: point lights (`GPointLight`) and directional lights `GDirLight`. The default ChuGL scene comes with a directional light angled slightly downward, which you can access as follows:

```c
// get the default directional light
GG.scene().light() @=> GDirLight light; 

// lights are GGens, so we can manipulate them using the same methods
light.rotateZ(Math.PI); // rotate the light downwards by PI radians

// make light half as bright
.5 => light.intensity;

// change light color
Color.YELLOW => light.color;
```

See the API reference for more.

### CKdoc <!-- omit in toc -->

- [GLight](https://chuck.stanford.edu/chugl/api/chugl-ggens.html#GLight)
- [GPointLight](https://chuck.stanford.edu/chugl/api/chugl-ggens.html#GPointLight)
- [GDirLight](https://chuck.stanford.edu/chugl/api/chugl-ggens.html#GDirLight)

### Examples <!-- omit in toc -->

- [basic/pbr.ck](https://chuck.stanford.edu/chugl/examples/basic/pbr.ck)
- [basic/light.ck](https://chuck.stanford.edu/chugl/examples/basic/light.ck)

___

## Get mouse/keyboard input?

You have a couple options here

- Use ChucK's builtin `Hid` class, which is more complicated to use but necessary if you need sub-frame timing accuracy.
- Use ChuGL's `GWindow` class, which is simpler but only updates mouse/keyboard state at a per-frame granularity.

 See the CKDoc links below for examples.

### CKdoc <!-- omit in toc -->

- [Hid](https://chuck.stanford.edu/doc/reference/io.html#Hid)
- [GWindow](https://chuck.stanford.edu/chugl/api/chugl-basic.html#GWindow)

___

## Add/Remove graphics objects from the scene? Connect/Disconnect objects from each other?

`GGens` are connected via the "gruck" operator `-->`.

You can remove graphics objects by disconnecting them from the scene to which they are currently connected. There are a few options for this, enumerated below:

```c
// connect a cube to the scene. the cube will now be rendered
GCube cube --> GG.scene();  

// disconnect the cube via the "ungruck" operator. LHS is child, RHS is parent.
cube --< GG.scene();
// OR
cube.detachParent(); // remove cube from its parent
// OR 
GG.scene().detachChildren(); // disconnects ALL children of GG.scene()
// OR
cube.detach(); // disconnects cube from its parent AND all children from cube
```

___

## Add Bloom?

The `bloom.ck` example has everything you need to know.

### CKdoc <!-- omit in toc -->

- [BloomPass](https://chuck.stanford.edu/chugl/api/chugl-pass.html#BloomPass)

### Examples <!-- omit in toc -->

- [rendergraph/bloom.ck](https://chuck.stanford.edu/chugl/examples/rendergraph/bloom.ck)

___

## Control the camera?

```cpp
// Option 1: control the default camera like a GGen
GG.camera().lookAt(@(1,2,3)); // face the camera towards @(1,2,3)

// Option 2: use the builtin Orbit camera controller
GOrbitCamera orbit_cam --> GG.scene();
GG.scene().camera(orbit_cam);

// Option 3: use the builtin Fly camera controller
GFlyCamera fly_cam --> GG.scene();
GG.scene().camera(fly_cam);

// Option 4: create a subclass of GCamera and implement your own controller
class CustomCamera extends GCamera {
 // your code here...
 fun void update(float dt) {
  // your code here...
 }
}
CustomCamera custom_cam --> GG.scene();
GG.scene().camera(custom_cam);
```

### CKdoc <!-- omit in toc -->

- [GCamera](https://chuck.stanford.edu/chugl/api/chugl-ggens.html#GCamera)
- [GOrbitCamera](https://chuck.stanford.edu/chugl/api/chugl-ggens.html#GOrbitCamera)
- [GFlyCamera](https://chuck.stanford.edu/chugl/api/chugl-ggens.html#GFlyCamera)
  
___

## Load 3D models and other assets?

Use the `AssLoader` (asset loader) helper class. Currently only supports wavefront `.obj` files.

### CKdoc <!-- omit in toc -->

- [AssLoader](https://chuck.stanford.edu/chugl/api/chugl-basic.html#AssLoader)

### Examples <!-- omit in toc -->

- [basic/asset_loading.ck](https://chuck.stanford.edu/chugl/examples/basic/asset_loading.ck)
  - for this to work, download the examples `data` folder as well
  - <https://chuck.stanford.edu/chugl/examples/data/>

___

## Load Textures?

```c
// simple way
Texture.load(me.dir() + "./path/to/texture" ) @=> Texture tex;

// with options
TextureLoadDesc load_desc;
true => load_desc.flip_y;  // flip the texture vertically
true => load_desc.gen_mips; // generate mip maps automatically
Texture.load(me.dir() + "./path/to/texture", load_desc) @=> Texture tex;
```

- If your texture appears incorrect, try flipping it vertically (different asset creation tools disagree on whether the y axis points up or down)

### CKdoc <!-- omit in toc -->

- [Texture](https://chuck.stanford.edu/chugl/api/chugl-tex.html#Texture)
- [TextureLoadDesc](https://chuck.stanford.edu/chugl/api/chugl-tex.html#TextureLoadDesc)

### Examples <!-- omit in toc -->

- [deep/snowstorm.ck](https://chuck.stanford.edu/chugl/examples/deep/snowstorm.ck)
  - requires downloading the examples `data` folder
  - <https://chuck.stanford.edu/chugl/examples/data/>

___

## Write to a Texture?

```c
// make a 100x100 texel texture
TextureDesc desc;
100 => desc.width;
100 => desc.height;

Texture tex(desc);

// simple way: write to the entire texture at once
float pixel_data[100 * 100 * 4]; // stores r,g,b,a data per texel
tex.write(pixel_data);

// more verbose, with options (to write to a rectangular subregion)
TextureWriteDesc write_desc;
50 => write_desc.width;
50 => write_desc.height;
tex.write(pixel_data, write_desc);  // writes to 50x50 subregion

```

### CKdoc <!-- omit in toc -->

- [Texture](https://chuck.stanford.edu/chugl/api/chugl-tex.html#Texture)
- [TextureWriteDesc](https://chuck.stanford.edu/chugl/api/chugl-tex.html#TextureWriteDesc)

### Examples <!-- omit in toc -->

- [deep/audio_donut.ck](https://chuck.stanford.edu/chugl/examples/deep/audio_donut.ck)
- [deep/game_of_life.ck](https://chuck.stanford.edu/chugl/examples/deep/game_of_life.ck)

___

## Make my own geometries?

If you want your geometry to work with the ChuGL builtin materials, they will need to contain the following attributes at the following binding locations:

- location 0.  vec3 positions
- location 1. vec3 normals
- location 2. vec2 uvs
- location 3. vec4 tangents

There are convenience functions for setting these values:

```c
Geometry geo;

// Set the positions for a geometry. Equivalent to vertexAttribute(0, 3, positions)
geo.positions(vec3[] positions)

// Set the normals for a geometry. Equivalent to vertexAttribute(1, 3, normals)
geo.normals(vec3[] normals)

// Set the UVs for a geometry. Equivalent to vertexAttribute(2, 2, uvs)
geo.uvs(vec2[] uvs)

// Set the tangents for a geometry. Equivalent to vertexAttribute(3, 4, tangents)
geo.tangents(vec4[] tangents)

// OR you can auto-generate the tangents via:
geo.generateTangents(); // must be called AFTER supplying position, normal, and uv data. Will write tangents to vertex attribute location 4.
```

Alternatively, if you want to make custom geometries to work with custom shaders:

```c
Geometry geo;

// Set the float vertex attribute data for a geometry. location must be between 0 and AttributeLocation_Max.
geo.vertexAttribute(int location, int numComponents, float[] attributeData)

// Set the integer vertex attribute data for a geometry. location must be between 0 and Geometry.AttributeLocation_Count.
geo.vertexAttribute(int location, int numComponents, int[] attributeData)


// the vertex layout of the shader you use to render this geometry must match the vertex attribute layout of the geometry. E.g.

// create a custom geometry where the vertex attributes, in order, are:
// vec3
// int
// int4
geo.vertexAttribute(0, 3, [1.0, 2.0, 3.0]); // vec3
geo.vertexAttribute(1, 1, [1]); // int
geo.vertexAttribute(2, 4, [1, 2, 3, 4]); // int 4


// when creating a custom shader, specify the matching vertex layout
ShaderDesc shader_desc;
[
 VertexFormat.Float3, 
 VertexFormat.Int, 
 VertexFormat.Int4
] @=> shader_desc.vertexLayout;

// ....
```

ChuGL also supports programmable vertex pulling. Pulled buffers (implemented as storage buffers) are exposed to your custom wgsl shader under `@group(3)`

```c
Geometry geo;

// set pulled vertex attribute data
geo.pulledVertexAttribute(0, [1,2,3,4]);
geo.pulledVertexAttribute(1, [5,6,7,8]);


"
// [1,2,3,4]
@group(3) @binding(0) var<storage> pulled_vertex_data_0 : array<f32>; 
// [5,6,7,8]
@group(3) @binding(0) var<storage> pulled_vertex_data_1 : array<f32>; 

@vertex 
fn vs_main(@builtin(instance_index) instance : u32) -> VertexOutput
{
 // your shader code...
}
" @=> string shader_code

```

### CKdoc <!-- omit in toc -->

- [Geometry](https://chuck.stanford.edu/chugl/api/chugl-geo.html#Geometry)

### Examples <!-- omit in toc -->

- [basic/custom_geo.ck](https://chuck.stanford.edu/chugl/examples/basic/custom_geo.ck)
- [deep/boids_compute.ck](https://chuck.stanford.edu/chugl/examples/rendergraph/boids_compute.ck)

### Further Learning Resources <!-- omit in toc -->

- <https://ktstephano.github.io/rendering/opengl/prog_vtx_pulling>

___

## Add a UI?

For developer UI, ChuGL wraps a majority of the [Dear ImGUI](https://github.com/ocornut/imgui) immediate mode API. Dear ImGUI has pretty comprehensive online documentation, in particular this [interactive online manual](https://pthom.github.io/imgui_manual_online/manual/imgui_manual.html) To try to implement UI, I often do the following:

- Open up the interactive manual at <https://pthom.github.io/imgui_manual_online/manual/imgui_manual.html>
- Click through the demo code until you find a widget / feature you're like to use
- The interactive manual will show the line of code in `cpp` that generates this widget
- Go to the `UI` ChuGL CKDOC page and find the corresponding wrapper method. Most ImGUI methods map 1:1 with ChuGL UI methods like so:
  - `ImGui::Button` becomes `UI.button`

For in-game UI (UI that the end user, not developer, interacts with) ChuGL does not currently have an out-of-box solution. It's up to you to design your own! Some ideas include:

- for 2D games:
  - Use GText and GPlane to create UI widgets.
  - See [mousepick.ck](https://chuck.stanford.edu/chugl/examples/basic/mousepick.ck) for how to get camera rays through the mouse position, which can be used for intersection testing with UI widgets.
  - Set the camera mode to orthographic, and place UI widgets at a special depth (e.g. z = 5) so that they are drawn on top of everything else
- for 3D games:
  - Same as 2D, except draw your UI in separate `RenderPass` with an orthographic camera because the main camera for your main scene probably has to be in perspective mode.

Helpful `GCamera` methods for in-game UI:

```c
// GCamera member functions, call like so:
GCamera camera;
camera.screenCoordToWorldPos(...);

// Returns the world position of a point in screen space at a given distance from the camera. Useful in combination with GWindow.mousePos() for mouse picking.
vec3 screenCoordToWorldPos(vec2 screen_pos, float distance)


// Get a screen coordinate from a world position by casting a ray from worldPos back to the camera and finding the intersection with the near clipping planeworld_pos is a vec3 representing a world position.Returns a vec2 screen coordinate.Remember, screen coordinates have origin at the top-left corner of the window.
vec2 worldPosToScreenCoord(vec3 world_pos)


// Convert a point in clip space to world space. Clip space x and y should be in range [-1, 1], and z in the range [0, 1]. For x and y, 0 is the center of the screen. For z, 0 is the near clip plane and 1 is the far clip plane.
vec3 NDCToWorldPos(vec3 clip_pos)

//Convert a point in world space to this camera's clip space.
vec3 worldPosToNDC(vec3 world_pos)
```

### CKdoc <!-- omit in toc -->

- <https://chuck.stanford.edu/chugl/api/chugl-ui.html>

### Examples <!-- omit in toc -->

- Most examples have UI snippets
- [deep/ckfxr.ck](https://chuck.stanford.edu/chugl/examples/rendergraph/ckfxr.ck)

### Further Learning Resources <!-- omit in toc -->

- <https://github.com/ocornut/imgui>
- <https://www.rfleury.com/p/ui-part-2-build-it-every-frame-immediate>
- <https://handwiki.org/wiki/Immediate_mode_GUI>
- <https://caseymuratori.com/blog_0001>

___

## View the Current Scenegraph?

```c
while (true) {
 GG.nextFrame() => now;

 if (UI.begin("window title")) {
  // pass any ggen to show this ggen and all children
  UI.scenegraph(GG.scene()); 
 }
 UI.end();
}
```

___

## Give names to objects in the UI scenegraph view?

Every ChuGL component (GGens, Textures, Materials, Shaders, etc) has a `.name()` method, which if set will appear in the scenegraph view. E.g.

```c
GGen my_ggen --> GG.scene();
my_ggen.name("my ggen");
GG.scene().name("scene name");
```

___

## Create an object where my mouse is?

```c
// convert from mouse position to world space
1.0 => float distance_from_camera;
GG.camera().screenCoordToWorldPos(GWindow.mousePos(), distance_from_camera) => vec3 pos;

// spawn something at that location
GCube cube --> GG.scene();
cube.pos(pos);
```

### CKdoc <!-- omit in toc -->

- [GCamera](https://chuck.stanford.edu/chugl/api/chugl-ggens.html#GCamera)

### Examples <!-- omit in toc -->

- [basic/mousepick.ck](https://chuck.stanford.edu/chugl/examples/basic/mousepick.ck)
  
___

## Get the object I'm clicking on?

ChuGL currently does not support color picking, so you'll have to roll your own intersection testing.

To get a ray from the camera to mouse position:

```c
GG.camera().screenCordToWorldPos(GWindow.mousePos(), 1) => vec3 ray;
```

- you can then use this ray to do intersection testing with the objects in your scene to determine which one is being clicked

For 2D scenes and simple shapes like axis-aligned bounding boxes (AABB), you can get the world-space xy coordinate of your mouse and compare it with with the extents of your bounding box:

```c
GG.camera().orthographi(); // 2d scene, set camera to orthographic

GPlane aabb --> GG.scene(); // the aabb we want to intersection test

 // returns true if mouse is hovering over the plane
fun int isHovered(GPlane plane, vec3 mouse_pos) {
 plane.scaWorld() => vec3 worldScale;  // get dimensions
 worldScale.x / 2.0 => float halfWidth;
 worldScale.y / 2.0 => float halfHeight;
 pad.posWorld() => vec3 worldPos;   // get position

 if (
  mouse_pos.x > worldPos.x - halfWidth 
  && 
  mouse_pos.x < worldPos.x + halfWidth 
  && 
  mouse_pos.y > worldPos.y - halfHeight 
  && 
  mouse_pos.y < worldPos.y + halfHeight
 ) {
  return true;
 }
 return false;
}

GG.camera().screenCordToWorldPos(GWindow.mousePos(), 1) => vec3 mouse_world_pos; // get mouse world position
isHovered(aabb, mouse_world_pos); // perform isection test
```

### CKdoc <!-- omit in toc -->

- [GCamera](https://chuck.stanford.edu/chugl/api/chugl-ggens.html#GCamera)

### Examples <!-- omit in toc -->

- [basic/mousepick.ck](https://chuck.stanford.edu/chugl/examples/basic/mousepick.ck)
- [sequencers/drum_machine.ck](https://chuck.stanford.edu/chugl/examples/sequencers/drum_machine.ck)
  - showcases aabb intersection testing

### Further Learning Resources <!-- omit in toc -->

- 2D Intersection testing
  - <https://noonat.github.io/intersect/>
  - <https://studiofreya.com/3d-math-and-physics/simple-aabb-vs-aabb-collision-detection/>
- 3D Intersection testing
  - <https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection.html>
- 3D Intersection Acceleration Structures (probably way overkill, talk to Andrew before setting out to implement any of these)
  - Quad-trees / Oct-trees / Kd-trees
  - BVH (Bounding Volume Hierarchy)
  - Spatial Hashing

___

## Do collision detection?

[Box2D](https://box2d.org/documentation/) integration is WIP.

For now, you'll have to roll your own collision detection. See the section "Get the Object I'm Clicking On" for links to resources about intersection testing.

Note: if you only need basic collision testing or old-school 2d platformer physics, a general-purpose 2d physics engine like Box2D is way overkill; you can get away with something much simpler. Here are some simple collision-only libraries (no collision resolution) written in  [Lua](https://www.lua.org/) for the [Love2D](https://love2d.org/) game engine. These are ripe for translating to ChucK and using in your own ChuGL app!

- <https://www.love2d.org/wiki/bump.lua>
  - collision detection for AABBs
- <https://www.love2d.org/wiki/HardonCollider>
  - collision detection for scalable and rotatable shapes: rectangles, polygons, circles, points

___

## (Advanced) Dispatch compute shaders?

### CKdoc <!-- omit in toc -->

- [ComputePass](https://chuck.stanford.edu/chugl/api/chugl-pass.html#ComputePass)

### Examples <!-- omit in toc -->

- [rendergraph/boids_compute.ck](https://chuck.stanford.edu/chugl/examples/rendergraph/boids_compute.ck)

### Further Learning Resources <!-- omit in toc -->

- <https://learnopengl.com/Guest-Articles/2022/Compute-Shaders/Introduction>
- <https://webgpufundamentals.org/webgpu/lessons/webgpu-compute-shaders.html>
- <https://math.hws.edu/graphicsbook/c9/s6.html>
- <https://anteru.net/blog/2018/intro-to-compute-shaders/>

___

## (Advanced) Make custom materials / custom vertex and fragment shaders?

This part of the API is unstable, going to hold off on writing documentation. Ask Andrew directly if you need help with this.

(Personal TODO)

- Copy the struct descriptions here.
- Add a `ShaderIncludes` singleton class

___
