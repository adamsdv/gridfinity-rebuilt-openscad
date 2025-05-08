# Gridfinity Rebuilt in OpenSCAD (adamsdv fork)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## This fork

This is {hopefully} a temporary fork of [gridfinity](https://www.youtube.com/watch?v=ra_9zU-mnl8)
It is home to solutions to numerous open issues & feature requests
Here are the hilights:
1. gridfinity-rebuilt-bins-adv.scad is added to provide access to all these customization features, some are available in gridfinity-rebuilt-bins.scad
2. Scoop can now be defined on the front and/or back of bins (independently)
3. The base can be sub-divided by 1,2,3 or 4, independently for X and Y axis.  Higher divisors are not realizable
4. The stacking lip has a new style which integrates 'notches'.  These can be spaced independently on each axis (with divisors 1,2,3 or 4), or eliminated.
5. Outer walls can be thickened, all 4 are independently adjustable
6. The interior divider wall between pockets can be thickened
7. A variable linear compartment mode allows X and Y divisions to be adjusted in the customizer by entering a list of relative sizes in a CSV string
8. A customizer setting to create a bin with a grid of cavities (cylindrical, rectangular or hexagonal) The grid can be a rectangular array or have staggered rows or columns
9. Tabs can be individually specified with a list of values entered as a CSV string
10. Tab width and heights can be adjusted
11. A single cavity can be sunk down into the bin with any wall offset (a single value currently), this is an easy way to cut dividers down to a lower level
12. A fix to properly form the bin wall when it is a at a grid-z height of 1 unit
13. A mechanism to easily explore the bin construction using slicing planes that are controlled in the customizer

Many of these changes are already placed as Pull-Requests in the origin project, but are moving slowly and with uncertain reception as implemented.  So I'm maintaining this Fork with the main branch being my latest revisions.  More documents and examples of what you can do with these features (using the customizer) will be added soon.

## The original repository [gridfinity](https://www.youtube.com/watch?v=ra_9zU-mnl8)

A ground-up port (with a few extra features) of the stock [gridfinity](https://www.youtube.com/watch?v=ra_9zU-mnl8) bins in OpenSCAD. Open to feedback, because I could not feasibly test all combinations of bins. I tried my best to exactly match the original gridfinity dimensions, but some of the geometry is slightly incorrect (mainly fillets). However, I think they are negligible differences, and will not appear in the printed model.

Full documentation can be found at the project's [website](https://kennetek.github.io/gridfinity-rebuilt-openscad/).

The project can also be found on [Printables](https://www.printables.com/model/274917-gridfinity-rebuilt-in-openscad) if you want to support the project.

[<img src="./images/base_dimension.gif" width="320">]()
[<img src="./images/compartment_dimension.gif" width="320">]()
[<img src="./images/height_dimension.gif" width="320">]()
[<img src="./images/tab_dimension.gif" width="320">]()
[<img src="./images/holes_dimension.gif" width="320">]()
[<img src="./images/custom_dimension.gif" width="320">]()

## Features
- any size of bin (width/length/height)
- height by units, internal depth, or overall size
- any number of compartments (along both X and Y axis)
- togglable scoop
- togglable tabs, split tabs, and tab alignment
- togglable holes (with togglable supportless printing hole structures)
- manual compartment construction (make the most wacky bins imaginable)
- togglable lip (if you don't care for stackability)
- dividing bases (if you want a 1.5 unit long bin, for instance)
- removed material from bases to save filament
- vase mode bins

### Printable Holes
The printable holes allow your slicer to bridge the gap inside the countersunk magnet hole (using the technique shown [here](https://www.youtube.com/watch?v=W8FbHTcB05w)) so that supports are not needed.

[<img src="./images/slicer_holes.png" height="200">]()
[<img src="./images/slicer_holes_top.png" height="200">]()

## Recommendations
For best results, use a [development snapshots](https://openscad.org/downloads.html#snapshots) version of OpenSCAD. This can speed up rendering from 10 minutes down to a couple of seconds, even for comically large bins. It is not a requirement to use development versions of OpenSCAD.

## External libraries

- `threads-scad` (https://github.com/rcolyer/threads-scad) is used for creating threaded holes, and is included in this project under `external/threads-scad/threads.scad`.

## Enjoy!

[<img src="./images/spin.gif" width="160">]()

[Gridfinity](https://www.youtube.com/watch?v=ra_9zU-mnl8) by [Zack Freedman](https://www.youtube.com/c/ZackFreedman/about)

This work is licensed under the same license as Gridfinity, being a
[MIT License](https://opensource.org/licenses/MIT).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
