/**
 * @file generic-helpers.scad
 * @brief Generic Helper Functions. Not gridfinity specific.
 */

function clp(x,a,b) = min(max(x,a),b);

function is_even(number) = (number%2)==0;

/**
 * @brief Create `square`, with rounded corners.
 * @param size Same as `square`.  See details for differences.
 * @param radius Radius of the corners. 0 is the same as just calling `square`
 * @param center Same as `square`.
 * @details "size" accepts both the standard number or a 2d vector the same as `square`.
 *          However, if passed a 3d vector, this will apply a `linear_extrude` to the resulting shape.
 */
module rounded_square(size, radius, center = false) {
    assert(is_num(size) ||
        (is_list(size) && (
            (len(size) == 2 && is_num(size.x) && is_num(size.y)) ||
            (len(size) == 3 && is_num(size.x) && is_num(size.y) && is_num(size.z))
        ))
    );
    assert(is_num(radius) && radius >= 0 && is_bool(center));

    // Make sure something is produced.
    if (is_num(size)) {
        assert((size/2) > radius);
    } else {
        assert((size.x/2) > radius && (size.y/2 > radius));
        if (len(size) == 3) {
            assert(size.z > 0);
        }
    }

    if (is_list(size) && len(size) == 3) {
        linear_extrude(size.z)
        _internal_rounded_square_2d(size, radius, center);
    } else {
        _internal_rounded_square_2d(size, radius, center);
    }
}

/**
 * @brief Internal module. Do not use. May be changed/removed at any time.
 */
module _internal_rounded_square_2d(size, radius, center) {
    diameter = 2*radius;
    if (is_list(size)) {
        offset(radius)
        square([size.x-diameter, size.y-diameter], center = center);
    } else {
        offset(radius)
        square(size-diameter, center = center);
    }
}

/**
 * @deprecated Use rounded_square(...)
 */
module rounded_rectangle(length, width, height, rad) {
    rounded_square([length, width, height], rad, center=true);
}

module copy_mirror(vec=[0,1,0]) {
    children();
    if (vec != [0,0,0])
    mirror(vec)
    children();
}

module pattern_linear(x = 1, y = 1, sx = 0, sy = 0) {
    yy = sy <= 0 ? sx : sy;
    translate([-(x-1)*sx/2,-(y-1)*yy/2,0])
    for (i = [1:ceil(x)])
    for (j = [1:ceil(y)])
    translate([(i-1)*sx,(j-1)*yy,0])
    children();
}

module pattern_circular(n=2) {
    for (i = [1:n])
    rotate(i*360/n)
    children();
}

/**
 * @brief Unity (no change) affine transformation matrix.
 * @details For use with multmatrix transforms.
 */
unity_matrix = [
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1]
];

/**
 * @brief Get the magnitude of a 2d or 3d vector
 * @param vector A 2d or 3d vectorm
 * @returns Magnitude of the vector.
 */
function vector_magnitude(vector) =
    sqrt(vector.x^2 + vector.y^2 + (len(vector) == 3 ? vector.z^2 : 0));

/**
 * @brief Convert a 2d or 3d vector into a unit vector
 * @returns The unit vector.  Where total magnitude is 1.
 */
function vector_as_unit(vector) = vector / vector_magnitude(vector);

/**
 * @brief Convert a 2d vector into an angle.
 * @details Just a wrapper around atan2.
 * @param A 2d vectorm
 * @returns Angle of the vector.
 */
function atanv(vector) = atan2(vector.y, vector.x);

function _affine_rotate_x(angle_x) = [
    [1,  0, 0, 0],
    [0, cos(angle_x), -sin(angle_x), 0],
    [0, sin(angle_x), cos(angle_x), 0],
    [0, 0, 0, 1]
];

function _affine_rotate_y(angle_y) = [
    [cos(angle_y),  0, sin(angle_y), 0],
    [0, 1, 0, 0],
    [-sin(angle_y), 0, cos(angle_y), 0],
    [0, 0, 0, 1]
];

function _affine_rotate_z(angle_z) = [
    [cos(angle_z), -sin(angle_z), 0, 0],
    [sin(angle_z), cos(angle_z), 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1]
];


/**
 * @brief Affine transformation matrix equivalent of `rotate`
 * @param angle_vector @see `rotate`
 * @details Equivalent to `rotate([0, angle, 0])`
 * @returns An affine transformation matrix for use with `multmatrix()`
 */
function affine_rotate(angle_vector) =
    _affine_rotate_z(angle_vector.z) * _affine_rotate_y(angle_vector.y) * _affine_rotate_x(angle_vector.x);

/**
 * @brief Affine transformation matrix equivalent of `translate`
 * @param vector @see `translate`
 * @returns An affine transformation matrix for use with `multmatrix()`
 */
function affine_translate(vector) = [
    [1, 0, 0, vector.x],
    [0, 1, 0, vector.y],
    [0, 0, 1, vector.z],
    [0, 0, 0, 1]
];

/**
 * @brief Affine transformation matrix equivalent of `scale`
 * @param vector @see `scale`
 * @returns An affine transformation matrix for use with `multmatrix()`
 */
function affine_scale(vector) = [
    [vector.x, 0, 0, 0],
    [0, vector.y, 0, 0],
    [0, 0, vector.z, 0],
    [0, 0, 0, 1]
];

/**
 * @brief Add something to each element in a list.
 * @param list The list whos elements will be modified.
 * @param to_add
 * @returns a list with `to_add` added to each element in the list.
 */
function foreach_add(list, to_add) =
    assert(is_list(list))
    assert(!is_undef(to_add))
    [for (item = list) item + to_add];

/**
 * @brief Create a rectangle with rounded corners by sweeping a 2d object along a path.
 * @Details Centered on origin.
 *          Result is on the X,Y plane.
 *          Expects children to be a 2D shape in Quardrant 1 of the X,Y plane.
 * @param size Dimensions of the resulting object.
 *             Either a single number or [width, length]
 */
module sweep_rounded(size) {
    assert((is_num(size) && size > 0) || (
        is_list(size) && len(size) == 2 &&
        is_num(size.x) && size.x > 0 && is_num(size.y) && size.y > 0
        )
    );

    width = is_num(size) ? size : size.x;
    length = is_num(size) ? size : size.y;
    half_width = width/2;
    half_length = length/2;
    path_points = [
        [-half_width, half_length],  //Start
        [half_width, half_length], // Over
        [half_width, -half_length], //Down
        [-half_width, -half_length], // Back over
        [-half_width, half_length]  // Up to start
    ];
    path_vectors = [
        path_points[1] - path_points[0],
        path_points[2] - path_points[1],
        path_points[3] - path_points[2],
        path_points[4] - path_points[3],
    ];
    // These contain the translations, but not the rotations
    // OpenSCAD requires this hacky for loop to get accumulate to work!
    first_translation = affine_translate([path_points[0].y, 0,path_points[0].x]);
    affine_translations = concat([first_translation], [
        for (i = 0, a = first_translation;
            i < len(path_vectors);
            a=a * affine_translate([path_vectors[i].y, 0, path_vectors[i].x]), i=i+1)
        a * affine_translate([path_vectors[i].y, 0, path_vectors[i].x])
    ]);

    // Bring extrusion to the xy plane
    affine_matrix = affine_rotate([90, 0, 90]);

    walls = [
        for (i = [0 : len(path_vectors) - 1])
        affine_matrix * affine_translations[i]
        * affine_rotate([0, atanv(path_vectors[i]), 0])
    ];

    union()
    {
        for (i = [0 : len(walls) - 1]){
            multmatrix(walls[i])
            linear_extrude(vector_magnitude(path_vectors[i]))
            children();

            // Rounded Corners
            multmatrix(walls[i] * affine_rotate([-90, 0, 0]))
            rotate_extrude(angle = 90, convexity = 4)
            children();
        }
    }
}


//--------------DVA LIST AND VALUE FUNCTIONS--------------------
/**
 *
 */
 // this function compactly allows you to take a numeric or vector of numeric values parameter
 // and then extract the value (as a scalar) if it was numeric or a numeric value in the vector.
 // which value is selected is based upon the specified index
 // if index exceeds the vector's length, then return the default value
 // also if other errors exist (like non-scalar and vector with non-scalar number values) return the specified default.
 
function valueOrListElementWithDefault(l, ix=0, def=0) =
    is_num(l) ? l : // If l is a scalar (number), return it
    is_list(l) && len(l) > ix ? l[ix] : // If l is a list and ix is in bounds, return l[ix]
    def; // Otherwise, return the default value

// this function is like the previous one, except that the case of exceeding the length of the specified vector input
// will repeat the value of the vector's last entry
function valueOrListElementWithRepeatLast(l, ix=0, def=0) =
    is_num(l) ? l : // If l is a scalar (number), return it
    is_list(l) ? 
        (len(l) > 0 ? (len(l) > ix ? l[ix] : l[len(l)-1]) : def) : // If l is a non-empty list, return l[ix] if in bounds, else last element; if empty, return def
    def; // Return def if l is neither a number nor a list

// this one will return sequentially the values of the vector and will wrap around and repeat the vector values as index increases

function valueOrListElementWithRepeatList(l, ix=0, def=0) =
    is_num(l) ? l : // If l is a scalar (number), return it
    is_list(l) ? 
        (len(l) > 0 ? l[ix % len(l)] : def) : // If l is a non-empty list, return l[ix % len(l)] to repeat cyclically; if empty, return def
    def; // Return def if l is neither a number nor a list

    
 // this funciton executes a summation of a list,  optional 'start' (which defaults ot 0) allows you to sum from a given index to the end 
 function sumOfList(l, start=0) =
    is_list(l) && len(l) > start ? // If l is a list and start is within bounds
        l[start] + sumOfList(l, start+1) : // Add current element and recurse
    0; // Return 0 for non-lists, empty lists, or when start reaches end
    
 // this function returns the sum of the first items of the passed list
 function sumOfFirstItemsOfList(l, ct) =
    is_num(l) ? (ct == 0 ? 0 : l) : // If scalar: return 0 if ct=0, l if ct>0
    is_list(l) && ct > 0 && len(l) > 0 ? // If list, ct>0, and non-empty
        l[0] + sumOfFirstItemsOfList(l, ct-1, 1) : // Add first element and recurse
    0; // Base case: empty list, ct<=0, or invalid input
    
// this function will sum from the specified 'start' index entry of the vector to the specified index (NOT COUNT)    
function sumOfFirstItemsOfList(l, ct, start=0) =
    start >= len(l) || ct <= 0 ? 0 : // Stop if past list end or ct<=0
    l[start] + sumOfFirstItemsOfList(l, ct-1, start+1); // Add element and recurse

// this function returns a list which consists of the first 'ct' items of the original list
function firstXItems(l, ct) = [ for (i = [0 : min(len(l) - 1, ct - 1)]) l[i] ];
    
// this function converts a string of comma-separated-values (numbers) into a list of numbers (vector)
function convertStringOfNumbersToList(str) = 
    let(
        // Remove spaces and split by commas
        cleaned = [for (c = str) if (c != " ") c],
        joined = [for (i = [0:len(cleaned)-1]) cleaned[i]],
        parts = split(joined, ","),
        // Convert strings to numbers
        numbers = [for (p = parts) _parseNumber(p)]
    ) numbers;

 function removeTrailingZerosFromList(l) =
    let(
        // Find the index of the last non-zero element
        last_non_zero = [for (i = [len(l)-1:-1:0]) if (l[i] != 0) i][0],
        // If no non-zero elements, return empty vector
        end_index = is_undef(last_non_zero) ? -1 : last_non_zero,
        // Slice vector up to last non-zero element
        result = [for (i = [0:end_index]) l[i]]
    ) result;   
    
//-------------------------------------------------------
// Helper function to split string by delimiter
function split(str, delim) = 
    let(
        result = _split(str, delim, [], 0)
    ) result;

// Internal split implementation
function _split(str, delim, current, start) =
    start >= len(str) ? 
        [if (len(current) > 0) str_join(current)] :
        str[start] == delim ?
            [if (len(current) > 0) str_join(current), 
             each _split(str, delim, [], start + 1)] :
            _split(str, delim, concat(current, [str[start]]), start + 1);
            
            // Parse string to list (e.g., "[1, 2, true, \"hello\"]" -> [1, 2, true, "hello"])
// Parse string to list (e.g., "[1, 2, true, \"hello\"]" -> [1, 2, true, "hello"])
function parseStringToList(s) = 
    let (
        trimmed = _trim(s)
    )
    len(trimmed) == 0 ? [] : _parseTokens(trimmed, 0, len(trimmed), [], 0)[0];

// Helper: Trim leading/trailing whitespace
function _trim(s) = 
    let (
        len = len(s),
        start = [for (i = [0:len-1]) if (s[i] != " ") i][0],
        end = [for (i = [len-1:-1:0]) if (s[i] != " ") i][0],
        result = len == 0 || start == undef || end == undef || start > end ? [] : 
                 [for (i = [start:end]) s[i]]
    )
    is_list(result) ? str_join(result) : "";

// Helper: Parse tokens recursively
function _parseTokens(s, pos, len, tokens, depth) = 
    pos >= len ? [tokens, pos] :
    let (
        c = s[pos]
    )
    // Handle whitespace
    c == " " ? _parseTokens(s, pos + 1, len, tokens, depth) :
    // Handle commas
    c == "," ? _parseTokens(s, pos + 1, len, tokens, depth) :
    // Handle opening bracket
    c == "[" ? 
        let (
            sublist = _parseTokens(s, pos + 1, len, [], depth + 1),
            newTokens = concat(tokens, [sublist[0]]),
            newPos = sublist[1]
        )
        newPos >= len || s[newPos] != "]" ? [tokens, pos] : 
        _parseTokens(s, newPos + 1, len, newTokens, depth) :
    // Handle closing bracket
    c == "]" ? 
        depth > 0 ? [tokens, pos + 1] : [tokens, pos] :
    // Handle quoted strings
    c == "\"" ? 
        let (
            strResult = _parseQuotedString(s, pos + 1, len),
            newTokens = concat(tokens, [str_join(strResult[0])]),
            newPos = strResult[1]
        )
        _parseTokens(s, newPos, len, newTokens, depth) :
    // Handle numbers, true/false, or other tokens
    let (
        tokenResult = _parseToken(s, pos, len),
        token = str_join(tokenResult[0]),
        newPos = tokenResult[1],
        normalizedToken = 
            let (
                lowerToken = _strLower(token)
            )
            lowerToken == "true" ? true :
            lowerToken == "false" ? false :
            _isNumber(token) ? _parseNumber(token) : token,
        newTokens = concat(tokens, [normalizedToken])
    )
    _parseTokens(s, newPos, len, newTokens, depth);

// Helper: Parse quoted string
function _parseQuotedString(s, pos, len) = 
    let (
        endPos = [for (i = [pos:len-1]) if (s[i] == "\"") i][0],
        str = endPos == undef ? [] : [for (i = [pos:endPos-1]) s[i]],
        newPos = endPos == undef ? len : endPos + 1
    )
    [str, newPos];

// Helper: Parse a single token (number, true/false, etc.)
function _parseToken(s, pos, len) = 
    let (
        endPos = [for (i = [pos:len-1]) if (s[i] == "," || s[i] == "]" || s[i] == " ") i][0],
        actualEnd = endPos == undef ? len : endPos,
        token = [for (i = [pos:actualEnd-1]) s[i]]
    )
    [token, actualEnd];

// Helper: Join characters into string
function str_join(chars) = 
    len(chars) == 0 ? "" : 
    chr([for (c = chars) ord(c)]);

// Helper: Convert string to lowercase
function _strLower(s) = 
    let (
        chars = is_string(s) ? [for (i = [0:len(s)-1]) s[i]] : s,
        lower = [for (c = chars) c >= "A" && c <= "Z" ? chr(ord(c) + 32) : c]
    )
    str_join(lower);

// Helper: Check if string is a valid number
function _isNumber(s) = 
    let (
        len = len(s),
        chars = [for (c = s) c],
        hasDigit = [for (c = chars) if (c >= "0" && c <= "9") true][0],
        validChars = [for (c = chars) c == "-" || c == "." || (c >= "0" && c <= "9") ? true : false],
        dotCount = len([for (c = chars) if (c == ".") true]),
        signCount = len([for (c = chars) if (c == "-") true])
    )
    len > 0 && hasDigit && !search(false, validChars) && dotCount <= 1 && signCount <= 1;

// Helper: Parse string to number
function _parseNumber(s) = 
    search(".", s) == [] ? _parseInt(s) : _parseDecimal(s);

// Helper: Parse integer
function _parseInt(s) = 
    let (
        sign = s[0] == "-" ? -1 : 1,
        start = s[0] == "-" ? 1 : 0,
        digits = [for (i = [start:len(s)-1]) ord(s[i]) - ord("0")],
        value = len(digits) == 0 ? 0 : 
                sum([for (i = [0:len(digits)-1]) digits[i] * pow(10, len(digits)-1-i)])
    )
    sign * value;

// Helper: Parse decimal
function _parseDecimal(s) = 
    let (
        sign = s[0] == "-" ? -1 : 1,
        start = s[0] == "-" ? 1 : 0,
        dotPos = search(".", s)[0],
        intPart = [for (i = [start:dotPos-1]) s[i]],
        fracPart = [for (i = [dotPos+1:len(s)-1]) s[i]],
        intValue = _parseInt(str_join(intPart)),
        fracValue = len(fracPart) == 0 ? 0 : 
                    sum([for (i = [0:len(fracPart)-1]) 
                         (ord(fracPart[i]) - ord("0")) * pow(10, -(i+1))])
    )
    sign * (intValue + fracValue);

// Helper: Sum of list elements
function sum(l) = 
    len(l) == 0 ? 0 : l[0] + sum([for (i = [1:len(l)-1]) l[i]]);
    
    
    
    
// cx, cy is the basic count of items on the first row (x-axis) and first column (y-axis)
// sx, sy is the basic spacing along the x-axis and y-axis, actual spacing can be modified by hexGrid
// stx = stagger X [-1,0,1] is the stagger of x location for even rows
// sty = stagger Y [-1,0,1] is the stagger of y location for even columns
// stxc = stagger X count [-1,0,1] is the adjustment to the X count applied to even rows
// styc = stagger Y count [-1,0,1] is the adjustment to the Y count applied to even columns
// hexGrid=-1 means adjust Y spacing to form Hex pattern with X spacing
// hexGrid=1 means adjust X spacein to form Hex pattern with Y spacing

module pattern_grid(cx,cy,sx,sy,stx=0,sty=0,stxc=0,styc=0,hexGrid=0)
{
assert(stx==0 || sty==0,"Stagger can only be in the X or Y axis, not both");
assert(stx>=-1 && stx<=1,"Stagger X can only be -1,0, or 1");
assert(sty>=-1 && sty<=1,"Stagger Y can only be -1,0, or 1");
assert(stxc>=-1 && stxc<=1,"Stagger X Count can only be -1,0, or 1");
assert(styc>=-1 && styc<=1,"Stagger Y Count can only be -1,0, or 1");
assert(!((stxc==-1 && stx<1)||(stxc==1 && stx>=0)),"This staggerX and staggerXCount is invalid");

    spaceX = (hexGrid==1?(sqrt(3)*sy/2):sx);
    spaceY = (hexGrid==-1?(sqrt(3)*sx/2):sy);

    widthDomain = (((((stx==-1 && stxc==-1)||(stx==-1 && stxc==0)||(stx==1 && stxc==0))?.5:0)+((stx==-1 && stxc==1)?1:0))+(cx-1))*spaceX;
    xNegativeLeft = ((stx==-1 && stxc>=0)?.5:0)*spaceX;

    heightDomain = (((((sty==-1&&styc>=0)||(sty==1&&styc<=0))?.5:0)+((sty*styc==1)?1:0))+(cy-1))*spaceY;
    yNegativeBot = ((sty==-1)?.5:0)*spaceY;
    //echo("SX, WD, NL",spaceX,widthDomain, xNegativeLeft);
    //echo("Sx,Sy,wD,HD,xn,yn ",spaceX,spaceY,widthDomain,heightDomain,xNegativeLeft,yNegativeBot);

    for(iy = [1:(cy+1)]) {
    yIsOdd = (((iy-1)%2==1)?1:0);

        for(ix = [1:cx+yIsOdd*stxc]) {
            xIsOdd = (((ix-1)%2==1)?1:0);
            
            xpos=((ix-1)*spaceX+stx*yIsOdd*spaceX/2);
            ypos=((iy-1)*spaceY+sty*xIsOdd*spaceY/2);
            
            if(iy<=cy || (sty==-1&&styc==-1&&xIsOdd==1)  || (sty==1&&styc==1&&xIsOdd==0)) {
                translate([xpos+xNegativeLeft-widthDomain/2,ypos+yNegativeBot-heightDomain/2,0])  children();
            }
        }
    }
}


// 3-D geometry Centered at X,Y=0,0 with the base at Z=0 and extending to the positive Z axis
// this cylinder can have rounded or chamfered top and bottom (chamfer and rounding can positive or negative values

module roundedCylinder(r=undef,h=undef,d=undef,chamfer=undef,chamfer1=undef,chamfer2=undef,rounding=undef,rounding1=undef,rounding2=undef) {
// assure that at least enought parameters are given,
assert(!(r==undef && d==undef),"Error: radius or diameter must be defined");
assert(h!=undef,"Error: height (h) must be defined");
// assure that the parameters don't over-define 
assert(!(r!=undef && d!=undef),"Error: do not define Radius and Diameter for same aspect");
// assure that the parameters have possible values for reality


rad = (r!=undef)?r:(d!=undef)?(d/2):undef;
//------------------
cham1=(chamfer1!=undef)?chamfer1:(chamfer!=undef)?chamfer:undef;
rnd1=(rounding1!=undef)?rounding1:(rounding!=undef)?rounding:undef;

cham2=(chamfer2!=undef)?chamfer2:(chamfer!=undef)?chamfer:undef;
rnd2=(rounding2!=undef)?rounding2:(rounding!=undef)?rounding:undef;

h1 = (cham1!=undef)?abs(cham1):(rnd1!=undef)?abs(rnd1):0;
h2 = h-((cham2!=undef)?abs(cham2):(rnd2!=undef)?abs(rnd2):0);

assert(h1<=h2,"Error: upper and lower chamfer/rounding can't overlap");
    
    rotate_extrude(angle=360) {
        difference() {
            union() {
                polygon(points=[[0,0],[rad,0],[rad,h],[0,h]], paths=[[0,1,2,3,0]]);
                if(cham1!=undef && cham1<0) {
                    polygon(points=[[rad,0],[rad+abs(cham1),0],[rad,abs(cham1)]],paths=[[0,1,2,0]]);
                } else {
                if(rnd1!=undef && rnd1<0) {
                    difference() {
                        translate([rad,0]) square(size=[abs(rnd1),abs(rnd1)]);
                        translate([rad+abs(rnd1),abs(rnd1)])circle(r=abs(rnd1));
                    }
                }}
                if(cham2!=undef && cham2<0) {
                    polygon(points=[[rad,h],[rad+abs(cham2),h],[rad,h-abs(cham2)]],paths=[[0,1,2,0]]);
                } else {
                if(rnd2!=undef && rnd2<0) {
                    difference() {
                        translate([rad,h-abs(rnd2)]) square(size=[abs(rnd2),abs(rnd2)]);
                        translate([rad+abs(rnd2),h-abs(rnd2)])circle(r=abs(rnd2));
                    }
                }}
            }
            if(cham1!=undef && cham1>0) {
                polygon(points=[[rad-abs(cham1),0],[rad,0],[rad,abs(cham1)]],paths=[[0,1,2,0]]);
            } else {
            if(rnd1!=undef && rnd1>0) {
                difference() {
                    translate([rad-abs(rnd1),0]) square(size=[abs(rnd1),abs(rnd1)]);
                    translate([rad-abs(rnd1),abs(rnd1)]) circle(r=abs(rnd1));
                }
            }}
            if(cham2!=undef && cham2>0) {
                polygon(points=[[rad-abs(cham2),h],[rad,h],[rad,h-abs(cham2)]],paths=[[0,1,2,0]]);
            } else {
            if(rnd2!=undef && rnd2>0) {
                difference() {
                    translate([rad-abs(rnd2),h-abs(rnd2)]) square(size=[abs(rnd2),abs(rnd2)]);
                    translate([rad-abs(rnd2),h-abs(rnd2)]) circle(r=abs(rnd2));
                }
            }}
        }
    }
}

// this roundedCube has is sized with X,Y,Z dimensions specified in 'size', centered at X,Y=0,0, bottom at Z=0 and extending to positive Z axis direction
// the 4 vertical edges can be rounded by edgeRadius
// the bottom edges can be rounded or chamfered (positive or negative values)
// the top edges can be rounded or chamfered (positive or negative values) 
module roundedCube(size=undef,edgeRadius=0,chamfer=undef,chamfer1=undef,chamfer2=undef,rounding=undef,rounding1=undef,rounding2=undef) {
// many other asserts should be added here


cham1=(chamfer1!=undef)?chamfer1:(chamfer!=undef)?chamfer:undef;
rnd1=(rounding1!=undef)?rounding1:(rounding!=undef)?rounding:undef;

cham2=(chamfer2!=undef)?chamfer2:(chamfer!=undef)?chamfer:undef;
rnd2=(rounding2!=undef)?rounding2:(rounding!=undef)?rounding:undef;

cr1 = (cham1!=undef)?cham1:(rnd1!=undef)?rnd1:0;
cr2 = (cham2!=undef)?cham2:(rnd2!=undef)?rnd2:0;

cr1Reduce = (cr1<0)?0:abs(cr1);
cr2Reduce = (cr2<0)?0:abs(cr2);

assert(edgeRadius>=abs(cr1),"Error: chamfer/rounding can't exceed edge radius");
assert(edgeRadius>=abs(cr2),"Error: chamfer/rounding can't exceed edge radius");

heightUpperBlock = (cr2>0)?abs(cr2):0;
heightLowerBlock = (cr1>0)?abs(cr1):0;
heightCenterBlock= size.z-heightUpperBlock-heightLowerBlock;

echo("CRS=",cr1,cr2);
echo("Block Heights=",heightLowerBlock,heightCenterBlock,heightUpperBlock);
    render() {
    union() {
        translate([(size.x/2-edgeRadius),(size.y/2-edgeRadius),0])roundedCylinder(r=edgeRadius,h=size.z,chamfer1=cham1,chamfer2=cham2,rounding1=rnd1,rounding2=rnd2);
        translate([(size.x/2-edgeRadius),-(size.y/2-edgeRadius),0])roundedCylinder(r=edgeRadius,h=size.z,chamfer1=cham1,chamfer2=cham2,rounding1=rnd1,rounding2=rnd2);
        translate([-(size.x/2-edgeRadius),(size.y/2-edgeRadius),0])roundedCylinder(r=edgeRadius,h=size.z,chamfer1=cham1,chamfer2=cham2,rounding1=rnd1,rounding2=rnd2);
        translate([-(size.x/2-edgeRadius),-(size.y/2-edgeRadius),0])roundedCylinder(r=edgeRadius,h=size.z,chamfer1=cham1,chamfer2=cham2,rounding1=rnd1,rounding2=rnd2);

        if(heightLowerBlock>0) {
            translate([0,0,heightLowerBlock/2]) cube(size=[size.x-2*abs(cr1),size.y-2*edgeRadius,heightLowerBlock],center=true);
            translate([0,0,heightLowerBlock/2]) cube(size=[size.x-2*edgeRadius,size.y-2*abs(cr1),heightLowerBlock],center=true);
        }
        if(heightCenterBlock>0) {
            translate([0,0,heightCenterBlock/2+heightLowerBlock]) cube(size=[size.x,size.y-2*edgeRadius,heightCenterBlock],center=true);
            translate([0,0,heightCenterBlock/2+heightLowerBlock]) cube(size=[size.x-2*edgeRadius,size.y,heightCenterBlock],center=true);
        }
        if(heightUpperBlock>0) {
            translate([0,0,heightUpperBlock/2+heightCenterBlock+heightLowerBlock]) cube(size=[size.x-2*abs(cr2),size.y-2*edgeRadius,heightUpperBlock],center=true);
            translate([0,0,heightUpperBlock/2+heightCenterBlock+heightLowerBlock]) cube(size=[size.x-2*edgeRadius,size.y-2*abs(cr2),heightUpperBlock],center=true);
        }
        if(cr1!=0) {
            translate([0,-(size.y/2-(cr1>0?abs(cr1):0)),0]) edgeRoundedOrChamfered(l=size.x-2*edgeRadius,chamfer=cham1,rounding=rnd1);
            translate([0,(size.y/2-(cr1>0?abs(cr1):0)),0]) rotate([0,0,180]) edgeRoundedOrChamfered(l=size.x-2*edgeRadius,chamfer=cham1,rounding=rnd1);
            translate([(size.x/2-(cr1>0?abs(cr1):0)),0,0]) rotate([0,0,90]) edgeRoundedOrChamfered(l=size.y-2*edgeRadius,chamfer=cham1,rounding=rnd1);
            translate([-(size.x/2-(cr1>0?abs(cr1):0)),0,0]) rotate([0,0,270]) edgeRoundedOrChamfered(l=size.y-2*edgeRadius,chamfer=cham1,rounding=rnd1);
        }
        if(cr2!=0) {
            translate([0,(size.y/2-(cr2>0?abs(cr2):0)),size.z]) rotate([180,0,0]) edgeRoundedOrChamfered(l=size.x-2*edgeRadius,chamfer=cham2,rounding=rnd2);
            translate([0,-(size.y/2-(cr2>0?abs(cr2):0)),size.z]) rotate([180,0,180]) edgeRoundedOrChamfered(l=size.x-2*edgeRadius,chamfer=cham2,rounding=rnd2);
            translate([-(size.x/2-(cr2>0?abs(cr2):0)),0,size.z]) rotate([180,0,90]) edgeRoundedOrChamfered(l=size.y-2*edgeRadius,chamfer=cham2,rounding=rnd2);
            translate([(size.x/2-(cr2>0?abs(cr2):0)),0,size.z]) rotate([180,0,270]) edgeRoundedOrChamfered(l=size.y-2*edgeRadius,chamfer=cham2,rounding=rnd2);
        }
    }}
}

// this is used to provide rounding or chamfering geometries for the roundedCube
module edgeRoundedOrChamfered(l,chamfer=undef,rounding=undef) {
// many other asserts should be added here

dim = (chamfer!=undef)?chamfer:(rounding!=undef)?rounding:undef;
assert(dim!=undef,"Error: Chamfer or Rounding must be specified");

    if(dim<0) {
        difference() {
            translate([0,-abs(dim)/2,abs(dim)/2]) cube(size=[l,abs(dim),abs(dim)],center=true);
            if(chamfer!=undef) {
                translate([0,-abs(dim),abs(dim)]) rotate([45,0,0]) cube(size=[l+.02,abs(dim)*sqrt(2),abs(dim)*sqrt(2)],center=true);
            } else {
                translate([0,-abs(dim),abs(dim)]) rotate([0,90,0]) cylinder(r=abs(dim),h=l+.02,center=true);
            }
        }
    } else {
        intersection() {
            translate([0,-abs(dim)/2,abs(dim)/2]) cube(size=[l,abs(dim),abs(dim)],center=true);
            if(chamfer!=undef) {
                translate([0,0,abs(dim)]) rotate([45,0,0]) cube(size=[l+.02,abs(dim)*sqrt(2),abs(dim)*sqrt(2)],center=true);
            } else {
                translate([0,0,abs(dim)]) rotate([0,90,0]) cylinder(r=abs(dim),h=l+.02,center=true);
            }
        }
    }
}

    

module roundedHex(f=undef, h=undef, edgeRadius=0, chamfer=undef, chamfer1=undef, chamfer2=undef, rounding=undef, rounding1=undef, rounding2=undef) {
    // Resolve chamfer and rounding for bottom and top
    cr1 = chamfer1 != undef ? chamfer1 : chamfer != undef ? chamfer : rounding1 != undef ? rounding1 : rounding != undef ? rounding : 0;
    cr2 = chamfer2 != undef ? chamfer2 : chamfer != undef ? chamfer : rounding2 != undef ? rounding2 : rounding != undef ? rounding : 0;

    c1 = (chamfer1 != undef)?chamfer1:chamfer;
    c2 = (chamfer2 != undef)?chamfer2:chamfer;
    r1 = (rounding1 != undef)?rounding1:rounding;
    r2 = (rounding2 != undef)?rounding2:rounding;

    // Calculate heights for blocks
    heightLowerBlock = cr1 > 0 ? abs(cr1) : 0;
    heightUpperBlock = cr2 > 0 ? abs(cr2) : 0;
    heightCenterBlock = h - heightLowerBlock - heightUpperBlock;

    // Radius for midsection
    rMid = (f - 2 * edgeRadius) / sqrt(3);

    render() {
        // Rounded cylinders at hexagon vertices
        if (edgeRadius > 0 || cr1 != 0 || cr2 != 0) {
            for (i = [0:5]) {
                rotate([0, 0, 30 + 60 * i]) translate([rMid, 0, 0])
                    roundedCylinder(r=edgeRadius, h=h, chamfer1=c1, chamfer2=c2, rounding1=r1, rounding2=r2);
            }
        }

        // Lower block (bottom chamfer/rounding)
        if (heightLowerBlock > 0) {
            for (i = [0:2]) {
                rotate([0, 0, 60 * i]) translate([0, 0, heightLowerBlock / 2])
                    cube(size=[f - 2 * cr1, rMid * (f - cr1) / f, heightLowerBlock], center=true);
            }
        }

        // Center block
        if (heightCenterBlock > 0) {
            for (i = [0, 120, -120]) {
                rotate([0, 0, i]) translate([0, 0, heightCenterBlock / 2 + heightLowerBlock])
                    cube(size=[f, rMid, heightCenterBlock], center=true);
            }
        }

        // Upper block (top chamfer/rounding)
        if (heightUpperBlock > 0) {
            for (i = [0:2]) {
                rotate([0, 0, 60 * i]) translate([0, 0, heightUpperBlock / 2 + heightLowerBlock + heightCenterBlock])
                    cube(size=[f - 2 * cr2, rMid * (f - cr2) / f, heightUpperBlock], center=true);
            }
        }

        // Bottom edge rounding/chamfering
        if (cr1 != 0) {
            for (i = [0:5]) {
                rotate([0, 0, 60 * i]) translate([-(f / 2 - (cr1 > 0 ? abs(cr1) : 0)), 0, 0]) rotate([0, 0, -90])
                    edgeRoundedOrChamfered(l=rMid * (f - cr1) / f, chamfer=c1, rounding=r1);
            }
        }

        // Top edge rounding/chamfering
        if (cr2 != 0) {
            for (i = [0:5]) {
                rotate([0, 0, 60 * i]) translate([(f / 2 - (cr2 > 0 ? abs(cr2) : 0)), 0, h]) rotate([180, 0, -90])
                    edgeRoundedOrChamfered(l=rMid * (f - cr2) / f, chamfer=c2, rounding=r2);
            }
        }
    }
}


