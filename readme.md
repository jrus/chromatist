Chromatist JavaScript Library
=============================

The Chromatist library aims to pull together implementations of useful color space math, for use both in the browser and in node-based servers. In particular, it currently has implementations of RGB ⇔ CIEXYZ conversions (in `chromatist.rgb`), CIECAM02 (in `chromatist.ciecam`), CIELAB (in `chromatist.cielab`), and HSL and HSV (in `chromatist.hsl` and `chromatist.hsv`). There is a simple gamut mapping tool in `chromatist.gamut` which finds a point of lower chroma but the same hue and lightness within the sRGB gamut using a bisection algorithm.

This is an early release: the API is likely to change somewhat going forward

Examples
--------

Imagine we want to convert an RGB color from a computer to CIECAM02 space, halve its chroma and increase its lightness by 30, and then convert that result back to RGB:

    >>> sRGB = chromatist.rgb.Converter('sRGB')
    >>> CIECAM02 = chromatist.ciecam.Converter({ adaptive_luminance: 200 })
    >>> rgb_j = chromatist.rgb.from_hex('#001C35')   // a nice dark blue
    [ 0, 0.1098, 0.2078 ]
    >>> xyz_j = sRGB.to_XYZ(rgb_j)
    [ 1.0576, 1.0874, 3.5216 ]
    >>> ciecam_j = CIECAM02.forward_model(xyz_j)
    { J: 7.919, C: 27.14, h: 245.3, Q: 55.44, M: 23.74, s: 65.43 }
    >>> ciecam_k = {J: ciecam_j.J + 30, C: ciecam_j.C / 2, h: ciecam_j.h}
    { J: 37.919, C: 13.57, h: 245.3 }
    >>> xyz_j = CIECAM02.reverse_model(ciecam_k).XYZ
    [ 16.122, 17.175, 23.101 ]
    >>> rgb_j = sRGB.from_XYZ(xyz_j)
    [ 0.4145, 0.4560, 0.5044 ]
    >>> hex_j = chromatist.rgb.to_hex(rgb_j)
    '#6a7481'
