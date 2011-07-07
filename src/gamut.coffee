gamut = chromatist.gamut = {}

{pow, abs} = Math
{mod, polar, rectangular, interpolate} = chromatist.mathutils
tau = Math.PI * 2


# convert a string to a list of code points
codepoints = (str) ->
    (str.charCodeAt(i) for i in [0...str.length])


# create CIECAM and RGB converters. CIECAM based on some parameters relevant
# to computer displays.
sRGB = chromatist.rgb.Converter('sRGB')
disp_CIECAM = chromatist.ciecam.Converter(
    adapting_luminance: 50
    discounting: true)


gamut.bring_into_sRGB = (XYZ, iterations=30) ->
    # works for either XYZ or JCh colors
    if XYZ.J?
        {J, C, h} = XYZ
        XYZ = disp_CIECAM.reverse_model({J, C, h}).XYZ
    else
        {J, C, h} = disp_CIECAM.forward_model(XYZ)
    orig = {J, C, h}

    if sRGB.in_gamut(XYZ)
        return XYZ

    prev_test = 0
    for i in [1..iterations]
        this_test = prev_test + pow(1/2, i)
        test_XYZ = disp_CIECAM.reverse_model({J, C: C * this_test, h}).XYZ
        if sRGB.in_gamut(test_XYZ)
            prev_test = this_test
            XYZ = test_XYZ

    return XYZ


gamut.Boundary = (precision=32) ->
    encode_pt = (rgb) ->
        String.fromCharCode (x + 0x30 for x in rgb)...

    decode_pt = (pt_str) ->
        (x - 0x30 for x in codepoints(pt_str))

    # create a dictionary mapping vertex names to J, C, h, a_C, b_C
    vertices = do ->
        V = {}
        p = precision

        # takes in an integer between 0 and precision, and returns a number
        # between 0 and 1. The curve causes higher sampling near 0 and 1
        s_curve = (comp) ->
            2 * pow(comp, 3) - pow(comp, 5.5)

        add_vertex = (rgb) ->
            xyz = sRGB.to_XYZ_linear(s_curve(comp/p) for comp in rgb)
            {J, C, h} = disp_CIECAM.forward_model(xyz)
            h = tau/360 * h # convert to radians
            [a_C, b_C] = rectangular([C, h])
            point = encode_pt(rgb)
            V[point] = [J, C, h, a_C, b_C]

        # ends up making some duplicates, but they just overwrite each-other
        # in the vertices dictionary, so it's no problem.
        for i in [0..precision]
            for j in [0..precision]
                for n in [0...3]
                    add_vertex(_([i, j, 0]).rotate(n))
                    add_vertex(_([i, j, p]).rotate(n))
        return V

    [horiz_edges, vert_edges] = do ->
        E_h = {}
        E_v = {}
        p = precision

        add_edge = (edge_obj, rgb1, rgb2) ->
            if _.min(rgb1.concat(rgb2)) >= 0 and _.max(rgb1.concat(rgb2)) <= p
                [v1, v2] = [encode_pt(rgb1), encode_pt(rgb2)].sort()
                [J1, C1, h1] = vertices[v1]
                [J2, C2, h2] = vertices[v2]
                edge_obj[v1 + v2] = [v1, J1, h1, v2, J2, h2] # use object as set, not dictionary

        # add edges from v1 to the other three vertices
        add_edges = ([v1, v2, v3, v4]) ->
            add_edge(E_h, v1, v2)
            add_edge(E_h, v1, v3)
            add_edge(E_h, v1, v4)

            add_edge(E_v, v1, v2)
            add_edge(E_v, v1, v3)
            # for showing the vertical gamut boundary it works better to
            # do horizontal triangles:
            add_edge(E_v, v2, v4)

        for i in [0..precision]
            for j in [0..precision]
                lower_vertices = [[i, j, 0], [i-1, j, 0], [i, j-1, 0], [i-1, j-1, 0]]
                upper_vertices = [[i, j, p], [i-1, j, p], [i, j-1, p], [i-1, j-1, p]]
                for n in [0...3] # handle all 6 sides
                    add_edges(_(v).rotate(n) for v in upper_vertices)
                    add_edges(_(v).rotate(n) for v in lower_vertices)

        return [E_h, E_v]

    # helper function: computes how far the target point 'x' is from the
    # start and end points p0 and p1. Sort of the inverse of 'interpolate'
    distance = (p_0, p_1, x) ->
        return (x - p_0) / (p_1 - p_0)

    # the same idea as distance, but based on angle values
    circular_distance = (a_0, a_1, max_a, x) ->
        # print(a_0, a_1, max_a, x)
        [a_0, a_1] = [mod(a_0, max_a), mod(a_1, max_a)]
        shift_amount = - (a_1 + a_0) / 2
        if abs(a_1 - a_0) <= max_a / 2
            shift_amount += max_a / 2
        [a_0, a_1, x] = (mod(y + shift_amount, max_a) for y in [a_0, a_1, x])
        return distance(a_0, a_1, x)

    # output a list of points sorted by counterclockwise hue, for use in
    # drawing the sRGB gamut boundary at CIECAM lightness 'J'
    horizontal = (J=50) ->
        output = for edge, [v1, J1, h1, v2, J2, h2] of horiz_edges
            dist = distance(J1, J2, J)
            unless (0 <= dist <= 1)
                continue  # make sure edge crosses horizontal plane
            [J1, C1, h1, a_C1, b_C1] = vertices[v1]
            [J2, C2, h2, a_C2, b_C2] = vertices[v2]

            a_Cx = interpolate(a_C1, a_C2, dist)
            b_Cx = interpolate(b_C1, b_C2, dist)
            [Cx, hx] = polar([a_Cx, b_Cx])
            hx = mod(hx, tau)
            [a_Cx, b_Cx, hx]

        output.sort((a, b) -> a[2] - b[2]) # sort by angle
        return output

    # output a list of points sorted by counterclockwise hue, for use in
    # drawing the sRGB gamut boundary at CIECAM lightness 'J'
    vertical = (h=0) ->
        h = tau/360 * h
        output = for edge, [v1, J1, h1, v2, J2, h2] of vert_edges
            dist = circular_distance(h1, h2, tau, h)
            unless (0 <= dist <= 1)
                continue  # make sure edge crosses vertical plane
            [J1, C1, h1, a_C1, b_C1] = vertices[v1]
            [J2, C2, h2, a_C2, b_C2] = vertices[v2]
            [interpolate(J1, J2, dist), interpolate(C1, C2, dist)]

        output = output.concat([[0, 0], [100, 0]]) # add pure black & pure white
        output.sort((a, b) -> a[0] - b[0]) # sort by lightness
        return output

    return {horizontal, vertical}
