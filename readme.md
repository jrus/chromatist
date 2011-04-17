Chromatist JavaScript Library
=============================

The Chromatist library aims to pull together implementations of useful color space math, for use both in the browser and in node-based servers. In particular, it currently has implementations of RGB ⇔ CIEXYZ conversions (in `chromatist.rgb`), CIECAM02 (in `chromatist.ciecam`), CIELAB (in `chromatist.cielab`), and HSL and HSV (in `chromatist.hsl` and `chromatist.hsv`). There is a simple gamut mapping tool in `chromatist.gamut` which finds a point of lower chroma but the same hue and lightness within the sRGB gamut using a bisection algorithm. `chromatist.matrix3` includes a class for 3 by 3 matrices, and `chromatist.mathutils` includes a few useful math routines.

This is an early release: the API is likely to change somewhat going forward

Examples
--------

Imagine we want to convert a blue color taken from a website from RGB to CIECAM02 space, take the color with complementary hue, 1.5 times the chroma, and lightness 80, and then convert that result back to RGB.

First we need to set up converters for RGB and CIECAM02. By default, the CIECAM02 converter uses a 'D65' white point, just as sRGB does, so we can leave that parameter implicit.

    >>> sRGB = chromatist.rgb.Converter('sRGB')
    >>> CIECAM02 = chromatist.ciecam.Converter({
    ...   adaptive_luminance: 50,
    ...   discounting: true })

Next we can define our color from hex, and convert it to XYZ space.

    >>> rgb_j = chromatist.rgb.from_hex('#14214D')    // a nice dark blue
    [ 0.0784, 0.1294, 0.3020 ]
    >>> xyz_j = sRGB.to_XYZ(rgb_j)
    [ 2.171, 1.772, 7.247 ]

Now we convert our color to CIECAM02 space, and perform our manipulations:

    >>> ccam_j = CIECAM02.forward_model(xyz_j)
    { J: 10.51, C: 33.92, h: 262.5, Q: 63.91, M: 29.66, s: 68.12 }
    >>> ccam_k = {J: 80, C: ccam_j.C * 1.5, h: ccam_j.h - 180}
    { J: 80, C: 50.88, h: 82.5 }

Finally we can convert our new color back to RGB and print it out in 8-bit hexadecimal:

    >>> xyz_k = CIECAM02.reverse_model(ccam_k).XYZ
    [ 63.85, 64.63, 18.37 ]
    >>> rgb_k = sRGB.from_XYZ(xyz_k)
    [ 0.9929, 0.7985, 0.3455 ]
    >>> hex_k = chromatist.rgb.to_hex(rgb_k)
    '#fdcc58'    // a nice bright yellow

