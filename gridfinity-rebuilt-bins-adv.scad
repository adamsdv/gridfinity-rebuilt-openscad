// ===== INFORMATION ===== //
/*
 IMPORTANT: rendering will be better in development builds and not the official release of OpenSCAD, but it makes rendering only take a couple seconds, even for comically large bins.
 the magnet holes can have an extra cut in them to make it easier to print without supports
 tabs will automatically be disabled when gridz is less than 3, as the tabs take up too much space
 base functions can be found in "gridfinity-rebuilt-utility.scad"
 comments like ' //.5' after variables are intentional and used by the customizer
 examples at end of file

 #BIN HEIGHT
 The original gridfinity bins had the overall height defined by 7mm increments.
 A bin would be 7*u millimeters tall with a stacking lip at the top of the bin (4.4mm) added onto this height.
 The stock bins have unit heights of 2, 3, and 6:
 * Z unit 2 -> 7*2 + 4.4 -> 18.4mm
 * Z unit 3 -> 7*3 + 4.4 -> 25.4mm
 * Z unit 6 -> 7*6 + 4.4 -> 46.4mm

 ## Note:
 The stacking lip provided here has a 0.6mm fillet instead of coming to a sharp point.
 Which has a height of 3.55147mm instead of the specified 4.4mm.
 This **has no impact on stacking height, and can be ignored.**

https://github.com/kennetek/gridfinity-rebuilt-openscad

*/

include <src/core/standard.scad>
use <src/core/gridfinity-rebuilt-utility.scad>
use <src/core/gridfinity-rebuilt-holes.scad>
use <src/helpers/generic-helpers.scad>

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25; // .01

/* [General Settings] */
// number of bases along x-axis
gridx = 3; //.5
// number of bases along y-axis
gridy = 2; //.5
// bin height. See bin height information and "gridz_define" below.
gridz = 6; //.1
/* [Base Minimum Divisions] */
div_base_x = 2;//[1,2,3,4]
div_base_y = 2;//[1,2,3,4]

/* [Wall Thickness & Divider Adjustments] */
// extra outer wall thickness in mm
extraOuterWallAll = 0; //.1
extraOuterWallIndividualSettings=false;
extraOuterWallFront = 0; //.1
extraOuterWallBack = 0; //.1
extraOuterWallLeft = 0; //.1
extraOuterWallRight = 0; //.1
// extra divider wall thickness in mm
extraDividerWall = 0; //.1
// cut dividers down by specified mm
//lowerDividers=0; //.1


/* [Linear Compartments] */
build_linear=true; //[false,true]
// number of X Divisions (set to zero to have solid bin)
divx = 1;
// number of Y Divisions (set to zero to have solid bin)
divy = 1;

/* [Cylindrical Compartments] */
build_cylindrical=false; //[false,true]

// number of cylindrical X Divisions (mutually exclusive to Linear Compartments)
cdivx = 0;
// number of cylindrical Y Divisions (mutually exclusive to Linear Compartments)
cdivy = 0;
// orientation
c_orientation = 2; // [0:x direction, 1:y direction, 2:z direction]
// diameter of cylindrical cut outs
cd = 10; // .1
// cylinder height
ch = 1;  //.1
// spacing to lid
c_depth = 1;
// chamfer around the top rim of the holes
c_chamfer = 0.5; // .1

/* [Variable Compartments] */
build_variable=false; //[false]
// relative sizes of the bin x divisions
divs_x = "2,3,4,2";
// relative size of the bin y divisions
divs_y = "1,1";

/* [Variable Compartments - alternate] */
build_variable_alternate=false; //[false]

/* [Variable Compartments - deluxe] */
build_variable_deluxe=false; //[false]

/* [Grid of Compartments] */
build_grid=false; //[false,true]
grid_count_x = 5;//[1:100]
grid_count_y = 5;//[1:100]
grid_space_x = 10;
grid_space_y = 10;
grid_stagger_x = 0; //[-1,0,1]
grid_stagger_y = 0; //[-1,0,1]
grid_stagger_x_count = 0; //[-1,0,1]
grid_stagger_y_count = 0; //[-1,0,1]
grid_space_adjust = 0; // [-1:Y-Axis Adjust, 0:none, 1:X-Axis Adjust]
grid_cut_depth = 20;
// how deep cut the 'base' into the bin
grid_depth=10;
// how deep to make each pocket


/* [the Grid Compartments] */
grid_element="cylinder"; //[cylinder, rectangular, hex]
// primary dimension for a pocket (x-axis or diameter)
grid_dimension_1=20;
// secondary dimension for a pocket (y-axis)
grid_dimension_2=10;
// tertiary dimension for a pocket (edgeRadius)
grid_dimension_3=3;
// z-axis rotation angle for a pocket
grid_rotation=0;
// bottom rounding (positive only)
grid_bottom_rounding=0;
// bottom chamfer (positive only)
grid_bottom_chamfer=0;
// top rounding (negative only)
grid_top_rounding=0;
//top chamfer (negative only)
grid_top_chamfer=0;


/* [Interior Cut Down] */
// cut the interior of the bin down to shorten the dividers
build_interior_cutdown = false; //[false,true]
interiorCutdownDepth = 10;
// extra outer wall thickness in mm
interiorCutdownOuterWall = 0; //.1


/* [Height] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0;
// snap gridz height to nearest 7mm increment
enable_zsnap = false;

/* [Tabs] */
// the type of tabs
style_tab = 1; //[0:Full,1:Auto,2:Left,3:Center,4:Right,5:None]
// optional, list of Comma-separated-values (0-5) to set tab style for each compartment individually, last value is used for all remaining compartments
style_tabs=""; 
// which divisions have tabs
place_tab = 0; // [0:Everywhere-Normal,1:Top-Left Division]
// how should the top lip act
// use -1 for default value, positive values to provide the desired override value
tab_width =-1;
tab_height=-1;

/* [Lip] */
style_lip = 0; //[0: Regular lip, 1:remove lip subtractively, 2: remove lip and retain height, 3: regular Lip with Notches]
div_notch_x=1; //[0,1,2,3,4]
div_notch_y=1; //[0,1,2,3,4]

/* [Scoop] */
// front scoop weight percentage. 0 disables scoop, 1 is regular scoop. Any real number will scale the scoop. (>1 are extreme scoops but may have use)
scoopF = 0; //[0:0.1:3]
// back (tab side of bin) scoop weight percentage. 0 disables scoop, 1 is regular scoop. Any real number will scale the scoop.
scoopB = 0; //[0:0.1:3]

/* [Base Hole Options] */
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;
//Use gridfinity refined hole style. Not compatible with magnet_holes!
refined_holes = false;
// Base will have holes for 6mm Diameter x 2mm high magnets.
magnet_holes = false;
// Base will have holes for M3 screws.
screw_holes = false;
// Magnet holes will have crush ribs to hold the magnet.
crush_ribs = true;
// Magnet/Screw holes will have a chamfer to ease insertion.
chamfer_holes = false;
// Magnet/Screw holes will be printed so supports are not needed.
printable_hole_top = true;
// Enable "gridfinity-refined" thumbscrew hole in the center of each base: https://www.printables.com/model/413761-gridfinity-refined
enable_thumbscrew = false;


/* [Visualization / Cross-section the Bin] */
cut_x=false;
cut_x_location = 0;//[-200:.01:200]
cut_y=false;
cut_y_location = 0;//[-200:.01:200]
cut_z=false;
cut_z_location = 0;//[-200:.01:200]
rotate_bin_z = 0;//[0:1:360]
stack2Bins = false;


//translate([63,0,37.25/2+4.75-1.2]) sphere(d=37.25);

// ===== IMPLEMENTATION ===== //
hole_options = bundle_hole_options(refined_holes, magnet_holes, screw_holes, crush_ribs, chamfer_holes, printable_hole_top);

scoop = [scoopF,scoopB];
notchDiv = [div_notch_x,div_notch_y];
extraOuterWall= extraOuterWallIndividualSettings?[extraOuterWallFront,extraOuterWallBack,extraOuterWallLeft,extraOuterWallRight]:extraOuterWallAll;

variableXDivs = convertStringOfNumbersToList(divs_x);
variableYDivs = convertStringOfNumbersToList(divs_y);

tabStyle = (style_tabs!="")?convertStringOfNumbersToList(style_tabs):style_tab;

gridPocket = [grid_element,grid_dimension_1,grid_dimension_2,grid_dimension_3,grid_rotation,grid_bottom_rounding,grid_bottom_chamfer,grid_top_rounding,grid_top_chamfer];


echo("VXDivs=",variableXDivs);
echo("VYDivs=",variableYDivs);

intersection() {

rotate([0,0,rotate_bin_z])
union() {
    //color("tomato") {
    gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, sl=style_lip, notchDiv = notchDiv) {

        if(build_linear) {
            cutEqual(n_divx = divx, n_divy = divy, style_tab = tabStyle, scoop_weight = scoop, place_tab = place_tab);
        }
        if(build_cylindrical) {
            cutCylinders(n_divx=cdivx, n_divy=cdivy, cylinder_diameter=cd, cylinder_height=ch, coutout_depth=c_depth, orientation=c_orientation, chamfer=c_chamfer);
        }
        if(build_variable) {
            cutVariableDVA(variableXDivs,variableYDivs, tabStyle, scoop, place_tab, extraWall=extraOuterWall,extraDividerWall,extraDepth=0,tab_width=tab_width, tab_height=tab_height);
        }
        if(build_grid) {
            cutGridDVA(grid_count_x,grid_count_y,grid_space_x,grid_space_y,grid_stagger_x,grid_stagger_y,grid_stagger_x_count,grid_stagger_y_count,grid_space_adjust,grid_depth,grid_cut_depth,gridPocket,extraWall=extraOuterWall);
        
        }
        if(build_interior_cutdown) {
            translate([0,0,$dh-STACKING_LIP_SUPPORT_HEIGHT-h_bot-interiorCutdownDepth])
            cut(interiorCutdownOuterWall/GRID_DIMENSIONS_MM.x,interiorCutdownOuterWall/GRID_DIMENSIONS_MM.y,$gxx-2*(interiorCutdownOuterWall/GRID_DIMENSIONS_MM.x),$gyy-2*(interiorCutdownOuterWall/GRID_DIMENSIONS_MM.y),t=5,s=0);
        }
    }
    gridfinityBase([gridx, gridy], hole_options=hole_options, only_corners=only_corners, thumbscrew=enable_thumbscrew,min_base_div=[div_base_x,div_base_y]);
    //}

    if(stack2Bins) { // a basic bin for visualization assistance of stacked bins
        translate([0,0,.5+STACKING_LIP_SIZE.y+height(gridz,gridz_define,style_lip,enable_zsnap)])
        color("gold") {
        gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, sl=style_lip, notchDiv = notchDiv) {

            if (divx > 0 && divy > 0) {
                cutEqual(n_divx = divx, n_divy = divy, style_tab = tabStyle, scoop_weight = scoop, place_tab = place_tab);
            } else if (cdivx > 0 && cdivy > 0) {
                cutCylinders(n_divx=cdivx, n_divy=cdivy, cylinder_diameter=cd, cylinder_height=ch, coutout_depth=c_depth, orientation=c_orientation, chamfer=c_chamfer);
            }
        }
        gridfinityBase([gridx, gridy], hole_options=hole_options, only_corners=only_corners, thumbscrew=enable_thumbscrew,min_base_div=[div_base_x,div_base_y]);
        }
    }
}
    zHeight = (height(gridz, gridz_define, style_lip, enable_zsnap)+STACKING_LIP_SIZE.y)*(stack2Bins?2:1)+BASE_HEIGHT;

    if(cut_x) {
        translate([-500+cut_x_location,0,zHeight/2])cube(size=[1000,1000,zHeight],center=true);
    }
    if(cut_y) {
        translate([0,-500+cut_y_location,zHeight/2])cube(size=[1000,1000,zHeight],center=true);
    }
    if(cut_z) {
        translate([0,0,zHeight/2+cut_z_location])cube(size=[1000,1000,zHeight],center=true);
    }

}

// ===== EXAMPLES ===== //

// 3x3 even spaced grid
/*
gridfinityInit(3, 3, height(6), 0, 42) {
	cutEqual(n_divx = 3, n_divy = 3, style_tab = 0, scoop_weight = 0);
}
gridfinityBase([3, 3]);
*/

// Compartments can be placed anywhere (this includes non-integer positions like 1/2 or 1/3). The grid is defined as (0,0) being the bottom left corner of the bin, with each unit being 1 base long. Each cut() module is a compartment, with the first four values defining the area that should be made into a compartment (X coord, Y coord, width, and height). These values should all be positive. t is the tab style of the compartment (0:full, 1:auto, 2:left, 3:center, 4:right, 5:none). s is a toggle for the bottom scoop.
/*
gridfinityInit(3, 3, height(6), 0, 42) {
    cut(x=0, y=0, w=1.5, h=0.5, t=5, s=0);
    cut(0, 0.5, 1.5, 0.5, 5, 0);
    cut(0, 1, 1.5, 0.5, 5, 0);

    cut(0,1.5,0.5,1.5,5,0);
    cut(0.5,1.5,0.5,1.5,5,0);
    cut(1,1.5,0.5,1.5,5,0);

    cut(1.5, 0, 1.5, 5/3, 2);
    cut(1.5, 5/3, 1.5, 4/3, 4);
}
gridfinityBase([3, 3]);
*/

// Compartments can overlap! This allows for weirdly shaped compartments, such as this "2" bin.
/*
gridfinityInit(3, 3, height(6), 0, 42)  {
    cut(0,2,2,1,5,0);
    cut(1,0,1,3,5);
    cut(1,0,2,1,5);
    cut(0,0,1,2);
    cut(2,1,1,2);
}
gridfinityBase(3, 3, 42, 0, 0, 1);
*/

// Areas without a compartment are solid material, where you can put your own cutout shapes. using the cut_move() function, you can select an area, and any child shapes will be moved from the origin to the center of that area, and subtracted from the block. For example, a pattern of three cylinderical holes.
/*
gridfinityInit(3, 3, height(6), 0, 42) {
    cut(x=0, y=0, w=2, h=3);
    cut(x=0, y=0, w=3, h=1, t=5);
    cut_move(x=2, y=1, w=1, h=2)
        pattern_linear(x=1, y=3, sx=42/2)
            cylinder(r=5, h=1000, center=true);
}
gridfinityBase([3, 3]);
*/

// You can use loops as well as the bin dimensions to make different parametric functions, such as this one, which divides the box into columns, with a small 1x1 top compartment and a long vertical compartment below
/*
gx = 3;
gy = 3;
gridfinityInit(gx, gy, height(6), 0, 42) {
    for(i=[0:gx-1]) {
        cut(i,0,1,gx-1);
        cut(i,gx-1,1,1);
    }
}
gridfinityBase([gx, gy]);
*/

// Pyramid scheme bin
/*
gx = 4;
gy = 4;
gridfinityInit(gx, gy, height(6), 0, 42) {
    for (i = [0:gx-1])
    for (j = [0:i])
    cut(j*gx/(i+1),gy-i-1,gx/(i+1),1,0);
}
gridfinityBase([gx, gy]);
*/
