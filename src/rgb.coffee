rgb = chromatist.rgb = {}
{max, pow, round} = Math
{standard_whitepoints, normalize_chromaticity, normalize_whitepoint} = chromatist.cie
{Matrix3} = chromatist.matrix3

##### XXX: This versions is somehow broken. The below one works though.
# RGB_matrix_from_primaries = ({r, g, b, white}) ->
#     # given chromaticity coordinates for the three primaries and the white
#     # point, output a matrix which transforms XYZ to RGB, where XYZ are scaled
#     # so that Y = 100 is the white point, (R, G, B) = (1, 1, 1)
#     primaries = (new Matrix3(
#         normalize_chromaticity(x) for x in [r, g, b])).transpose()
#     white = normalize_whitepoint(white)
#     c_rgb = primaries.inverse().dot(white)
#     c_rgb = new Matrix3([c_rgb, c_rgb, c_rgb]) # three identical rows
#     return c_rgb.dot(primaries).inverse()
# 

RGB_matrix_from_primaries = ({r, g, b, white}) ->
    # given chromaticity coordinates for the three primaries and the white
    # point, output a matrix which transforms XYZ to RGB, where XYZ are scaled
    # so that Y = 100 is the white point, (R, G, B) = (1, 1, 1)
    primaries = (new Matrix3(
        normalize_chromaticity(x) for x in [r, g, b])).transpose()
    [x_r, x_g, x_b
     y_r, y_g, y_b
     z_r, z_g, z_b] = primaries.flat()
    white = normalize_whitepoint(white)
    [c_r, c_g, c_b] = primaries.inverse().dot(white)
    return (new Matrix3 [
        c_r*x_r, c_g*x_g, c_b*x_b
        c_r*y_r, c_g*y_g, c_b*y_b
        c_r*z_r, c_g*z_g, c_b*z_b]).inverse()


sRGB_gamma = [
    (x) ->
        if x <= .0031308 then 12.92 * x
        else 1.055 * pow(x, 1/2.4) - .055
    (x_) ->
        if x_ <= .04045 then x_ / 12.92
        else pow((x_ + .055) / 1.055, 2.4) ]
ProPhoto_gamma = [
    (x) ->
        if x < .001953125 then 16 * x
        else pow(x, 1/1.8)
    (x_) ->
        if x_ < 16 * .001953125 then x_ / 16
        else pow(x_, 1.8) ]

RGB_spaces_parameters =
    'sRGB':
        r: [.64, .33]
        g: [.30, .60]
        b: [.15, .06]
        gamma: sRGB_gamma
    'Adobe RGB':
        r: [.64, .33]
        g: [.21, .71]
        b: [.15, .06]
        gamma: 2.2  
    'Apple RGB':
        r: [.625, .340]
        g: [.280, .595]
        b: [.155, .070]
        gamma: 1.8
    'ProPhoto RGB':
        r: [.7347, .2653]
        g: [.1596, .8404]
        b: [.0366, .0001]
        white: 'D50'
        gamma: ProPhoto_gamma
    'Wide Gamut RGB':
        r: [.7347, .2653]
        g: [.1152, .8264]
        b: [.1566, .0177]
        gamma: 563/256
    'ColorMatch RGB':
        r: [.630, .340]
        g: [.295, .605]
        b: [.150, .075]
        white: 'D50'
        gamma: 1.8


rgb.Converter = (params) ->
    # Note: assumes white point of X, Y, Z values is the same as the white
    # point for the RGB space. If that's untrue, use a chromatic adaptation
    # transform first.
    
    params ?= 'sRGB' # default to sRGB if no space specified
    
    if _.isString(params) # allow users to call with a color space name
        params = RGB_spaces_parameters[params]
        throw new Error('Unrecognized name for RGB space') unless params?
    
    # defaults = sRGB primaries, D65 white point, simple 2.2 gamma
    params = _(params).defaults
        r: [.64, .33]
        g: [.30, .60]
        b: [.15, .06]
        white: 'D65'
        gamma: 2.2
    
    g = params.gamma
    if _.isNumber(g) # for "simple gamma"
        [decoding_gamma, encoding_gamma] = [g, 1 / g]
        gamma_encode = (x) -> pow(x, encoding_gamma)
        gamma_decode = (x) -> pow(x, decoding_gamma)
    else if (g.length == 2 and _.isFunction(g[0]) and _.isFunction(g[1]))
        [gamma_encode, gamma_decode] = g
    else
        throw new Error('Unrecognized gamma')
    
    matrix = RGB_matrix_from_primaries(params) # needs `r`, `g`, `b`, `white`
    from_XYZ_linear = matrix.linear_transform()
    to_XYZ_linear = matrix.inverse().linear_transform()
    
    from_XYZ = (XYZ) ->
        # transform to linear RGB then apply gamma
        (gamma_encode(component) for component in from_XYZ_linear(XYZ))
    
    to_XYZ = (RGB) ->
        # apply reverse gamma then transform to XYZ
        to_XYZ_linear(gamma_decode(component) for component in RGB)
    
    in_gamut = (XYZ) ->
        (_.every(0 <= comp for comp in XYZ) and 
         _.every(0 <= comp <= 1 for comp in from_XYZ_linear(XYZ)))
    
    return {
        from_XYZ, to_XYZ
        from_XYZ_linear, to_XYZ_linear
        in_gamut }


zero_pad = (str, len) ->
    Array(max(len - str.length, 0) + 1).join('0') + str

rgb.to_hex = ([R, G, B]) ->
    unless 0 <= R <= 1 and 0 <= G <= 1 and 0 <= B <= 1
        throw new Error('Bad Input: R, G, and B must be in range [0, 1]')

    return '#' + zero_pad(
        ((round(0xff * R) << 16) +
         (round(0xff * G) << 8) +
         (round(0xff * B))).toString(16),
        6)

rgb.from_hex = (hex) ->
    unless /^#?[0-9a-fA-F]{6}$/.test(hex)
        throw new Error('Bad Input: Must be of form "666FAD" or "#DEFACE"')

    RGB = parseInt(hex.substr(-6), 16);
    return [
        (RGB >> 16)       / 0xff # first byte  -> R
        (RGB >> 8 & 0xff) / 0xff # second byte -> G
        (RGB & 0xff)      / 0xff # third byte  -> B
    ]