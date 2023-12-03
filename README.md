# WFC 3D Tool
A procedural 3D game world generation tool based on Wave Function Collapse algorithm made in Godot 4. 

![gif_unoptimized](https://github.com/DEV742/World-Generation-Tool/assets/32599868/64ca6885-e740-45d8-a3d7-ee5c1bf0b2ef)

## Description
A rather lightweight tool build to provide a platform to play around with Wave Function Collapse. The tool allows to import a custom-made set of 3D segments, edit WFC connection rules (sockets, in this case), generate a model out of imported 3D segments and export it (for now, only to .glb/.gltf).
## Installation
Download and unpack a .zip file from the Releases section.

### For Windows
Run the wfc3d.exe in the unzipped folder. If the Windows Defender window comes up, proceed to run the application by pressing "Run anyways". This happens to any Godot build lacking code signature.
### For Linux
Run either wfc3d.sh or wfc3d.x86_64 from the unzipped folder. On some systems, the executable flags may be stripped during download. If that happens - reapply them.
### Alternative way
To skip the download-unzip-execute part altogether, you can access a fully functional version at the project page.

## Usage
The starting tab of the application contains all information necessary to start using the program and to design a custom set of 3D segments for it.

![231203_14h08m13s_screenshot](https://github.com/DEV742/World-Generation-Tool/assets/32599868/712b168c-40f9-43e3-bc62-d0c374dd07e5)

## Developer's note & Known issues
This project was made for a bachelors thesis in engineering, keep that in mind. There are **many** ways to break it or otherwise achieve results that may look like incorrect program functioning.
Many of the design choices that are in place had to be made with intent to save time and work, and will be re-evaluated in the future. At the time of writing this, I have not a lot of free time to work on the project, so it may rest unchanged for a while. The project is just getting out of the proof-of-concept phase, meaning that many things will probably change.

### Known issues
- No functionality to set grid unit size, meaning that for now only models that fit into a 1x1x1m cube will connect correctly.
- Multiple ways to crash the program by submitting empty fields.
- Biomes can cause incomplete generation results if not every biome-themed piece has a counterpart for other biomes.

## Roadmap
- [X] Basic interface design
- [X] File import
- [X] Data structures needed for WFC
- [X] Wave Function Collapse
- [X] Voronoi algorithm - biome generation
- [X] Debug/Inspect tools
- [X] Export to .gltf
- [ ] HTML5 Build
- [ ] Windows Build
- [ ] Linux Build
- [ ] .obj file support
- [ ] Socket Creator redesign

Made for the engineer's thesis at Wrocław University of Science and Technology by dev742
