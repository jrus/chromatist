cie = chromatist.cie = {}

{reduce, isArray} = _
sum = (list) ->
    plus = (total, x) -> total + x
    reduce(list, plus, 0)

standard_whitepoints = cie.standard_whitepoints =
    A:   [109.850, 100,  35.585]
    B:   [ 99.090, 100,  85.324]
    C:   [ 98.074, 100, 118.232]
    E:   [100    , 100, 100    ] # equal-energy illuminant
    D50: [ 96.422, 100,  82.521]
    D55: [ 95.682, 100,  92.149]
    D65: [ 95.047, 100, 108.883]
    D75: [ 94.972, 100, 122.638]
    F2:  [ 99.186, 100,  67.393]
    F7:  [ 95.041, 100, 108.747]
    F11: [100.962, 100,  64.350]


cie.normalize_chromaticity = (c) ->
    # normalize so x + y + z = 1. Assume input is either the chromaticity
    # coordinates (x, y), or else a triple (x, y, z) or (X, Y, Z).
    unless isArray(c) and c.length in [2, 3]
        throw new Error('Unrecognized chromaticity')
    if c.length == 2
        [c_x, c_y] = c
        unless 0 <= c_x <= 1 and 0 <= c_y <= 1 and c_x + c_y <= 1
            throw new Error('Invalid (x, y) chromaticity coordinates')
        return [c_x, c_y, 1 - c_x - c_y]
    else if c.length == 3
        return (x / sum(c) for x in c) # x + y + z = 1


cie.normalize_whitepoint = (white) ->
    # normalize so Y component is 100. Assume input is either a string (one of
    # the known standard illuminants), or the chromaticity coordinates (x, y),
    # or else a triple (x, y, z) or (X, Y, Z).
    if not white?
        white = standard_whitepoints.D65 # if white is undefined, assume D65
    else if white of standard_whitepoints
        white = standard_whitepoints[white]
    else if isArray(white)
        if white.length not in [2, 3]
            throw new Error('Unrecognized whitepoint')
        if white.length == 2
            [w_x, w_y] = white
            unless 0 <= w_x <= 1 and 0 <= w_y <= 1 and w_x + w_y <= 1
                throw new Error('Invalid (x, y) chromaticity coords for whitepoint')
            white = [w_x, w_y, 1 - w_x - w_y]
    else
        throw new Error('Unrecognized whitepoint')

    [w_x, w_y, w_z] = white
    return (comp * 100 / w_y for comp in white) # normalize Y component to 100
