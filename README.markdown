# Ronie's OpenSCAD files

Here are my models in OpenSCAD.

## Models

### headset-holder

A simple holder for my headset. 

It was my second project on the CNC (after a simple box). It made me relearn trigonometry 😅

- [Assembled](headset-holder/headset-holder-assembled.stl) version.
- [Flat pack](headset-holder/headset-holder-flat-pack.stl) ready for cutting on a 280x280mm sheet.

### sliced-cup

A cup made of horizontal slices.

Here I'm experimenting with double-side milling.

- [Assembled](sliced-cup/sliced-cup-assembled.stl) version.
- [Flat pack](sliced-cup/sliced-cup-flat-pack.stl) ready for cutting.

### stair-tray

A tray to put things upstairs that need to go to the main floor.

First real and very simple project with double-side milling. It's really specific for my house.

- [Assembled](stair-tray/stair-tray-assembled.stl) version.
- [Flat pack](stair-tray/stair-tray-flat-pack.stl) ready for cutting.


## Project structure

- extensions - Utility functions and modules I wrote.
- lib - Utility functions and modules others wrote.
    - Round Anything - https://github.com/Irev-Dev/Round-Anything
- \<model-name/> - Folder with everything related to that project.
- \<model-name/>/main.stl - The model itself.

Libraries are usually cloned from their original repositories. Check the [lib/README](lib/README.markdown) for their links.
