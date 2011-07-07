ciecam = chromatist.ciecam = {}

{atan2, sin, cos, exp, abs, sqrt, pow, round, floor} = Math
tau = Math.PI * 2
{sgn, mod, interpolate} = chromatist.mathutils
{Matrix3} = chromatist.matrix3
{standard_whitepoints} = chromatist.cie


ciecam.Converter = (params) ->
    params = _(params or {}).defaults
        whitepoint: 'D65'
        adapting_luminance: 40    # L_A
        background_luminance: 20  # Y_b; relative to Y_w = 100
        surround: 'average'
        discounting: false

    M_CAT02 = new Matrix3 [
         .7328,  .4296, -.1624,
        -.7036, 1.6975,  .0061,
         .0030,  .0136,  .9834]
    M_HPE = new Matrix3 [
         .38971,  .68898, -.07868,
        -.22981, 1.18340,  .04641,
         .00000,  .00000, 1.00000]
	
    XYZ_to_CAT02 = M_CAT02.linear_transform()
    CAT02_to_XYZ = M_CAT02.inverse().linear_transform()
    CAT02_to_HPE = M_HPE.dot(M_CAT02.inverse()).linear_transform()
    HPE_to_CAT02 = M_CAT02.dot(M_HPE.inverse()).linear_transform()

    # require that the whitepoint is an array or else a recognized string
    XYZ_w = standard_whitepoints[params.whitepoint] or params.whitepoint
    throw new Error('Invalid whitepoint') unless _.isArray(XYZ_w)

    L_A = params.adapting_luminance
    Y_b = params.background_luminance
    Y_w = XYZ_w[1]

    surround =
        if _.isNumber(params.surround) then params.surround
        else switch params.surround
            when 'dark'    then 0
            when 'dim'     then 1
            when 'average' then 2
            else new Error('Invalid surround')

    if surround < 1
        c = interpolate(.525, .59, surround)
        N_c = F = interpolate(.8, .9, surround)
    else
        c = interpolate(.59, .69, surround - 1)
        N_c = F = interpolate(.9, 1.0, surround - 1)

    k = 1 / (5*L_A + 1)
    F_L = (.2 * pow(k, 4) * 5 * L_A +
           .1 * pow(1 - pow(k, 4), 2) * pow(5 * L_A, 1/3))
    n = Y_b / Y_w
    N_bb = N_cb = .725 * pow(1/n, .2)
    z = 1.48 + sqrt(n)
    D = 1 if params.discounting
    D ?= F * (1 - 1 / 3.6 * exp(-(L_A + 42) / 92))

    RGB_w = XYZ_to_CAT02(XYZ_w)
    [D_R, D_G, D_B] = (interpolate(1, 100/component, D) for component in RGB_w)

    corresponding_colors = (XYZ) ->
        # Find R_c, G_c, B_c: corresponding colors after chromatic adaptation,
        # in CAT02 space
        [R, G, B] = XYZ_to_CAT02(XYZ)
        return [D_R * R, D_G * G, D_B * B]

    reverse_corresponding_colors = ([R_c, G_c, B_c]) ->
        # Convert post-adpatation corresponding colors in CAT02 space to XYZ
        return CAT02_to_XYZ([R_c / D_R, G_c / D_G, B_c / D_B])

    adapted_response = (HPE_component) ->
        x = pow(F_L * abs(HPE_component) / 100, .42) # temp variable
        return sgn(HPE_component) * 400 * x / (27.13 + x) + .1

    adapted_responses = (RGB_c) ->
        # Convert corresponding colors R_c, G_c, B_c to HPE space, and apply
        # the proper nonlinearity to arrive at adapted cone responses.
        (adapted_response(component) for component in CAT02_to_HPE(RGB_c))

    reverse_adapted_response = (adapted_component) ->
        x = adapted_component - .1 # temp variable
        return sgn(x) * 100 / F_L * pow(27.13 * abs(x) / (400 - abs(x)), 1/.42)

    reverse_adapted_responses = (RGB_a) ->
        # Convert adapted cone responses R_a, G_a, B_a to corresponding colors
        # in CAT02 space, first applying the proper nonlinearity.
        HPE_to_CAT02(reverse_adapted_response(component) for component in RGB_a)

    achromatic_response = ([R_a, G_a, B_a]) ->
        # Find the achromatic response A, given the adapted cone responses.
        (R_a * 2 + G_a + B_a / 20 - .305) * N_bb

    RGB_cw = corresponding_colors(XYZ_w)
    RGB_aw = adapted_responses(RGB_cw)
    A_w = achromatic_response(RGB_aw)

    forward_model = (XYZ) ->
        # Return lightness, chroma, hue for a given color in XYZ space.

        RGB_c = corresponding_colors(XYZ)
        [R_a, G_a, B_a] = RGB_a = adapted_responses(RGB_c)

        a = R_a - G_a * 12 / 11 + B_a / 11
        b = (R_a + G_a - 2 * B_a) / 9
        h_rad = atan2(b, a)           # hue in radians
        h = mod(h_rad * 360/tau, 360) # hue in degrees
        e_t = 1/4 * (cos(h_rad + 2) + 3.8)
        A = achromatic_response(RGB_a)
        J = 100 * pow(A / A_w, c * z)
        t = (5e4 / 13 * N_c * N_cb * e_t * sqrt(a*a + b*b) /
             (R_a + G_a + 21 / 20 * B_a))
        C = pow(t, .9) * sqrt(J / 100) * pow(1.64 - pow(.29, n), .73)
        Q = 4 / c * sqrt(J / 100) * (A_w + 4) * pow(F_L, .25)
        M = C * pow(F_L, .25)
        s = 100 * sqrt(M / Q)

        return {J, C, h, Q, M, s}

    reverse_model = (inputs) ->
        {Q, M, J, C, s, h} = inputs
        unless ((J? + Q? == 1) and (M? + C? + s? == 1) and h?)
            # need exactly one of each of {J, Q}, {M, C, s}, {h}
            throw new Error('Need exactly three model inputs')

        h = mod(h, 360)
        h_rad = h * tau/360 # radians

        # fill in missing {Q, J, M, C, s} from the ones available
        J ?= 6.25 * pow(c * Q / ((A_w + 4) * pow(F_L, .25)), 2)
        Q ?= 4/c * sqrt(J/100) * (A_w + 4) * pow(F_L, .25)
        C ?= if M? then M / pow(F_L, .25) else pow(s / 100, 2) * Q / pow(F_L, .25)
        M ?= C * pow(F_L, .25)
        s ?= 100 * sqrt(M / Q)

        t = pow(C / (sqrt(J / 100) * pow(1.64 - pow(.29, n), .73)), 10 / 9)
        e_t = 1 / 4 * (cos(h_rad + 2) + 3.8)
        A = A_w * pow(J / 100, 1 / c / z)

        p_1 = 5e4 / 13 * N_c * N_cb * e_t / t
        p_2 = A / N_bb + .305
        q_1 = p_2 * 61/20 * 460/1403
        q_2 = 61/20 * 220/1403
        q_3 = 21/20 * 6300/1403 - 27/1403

        sin_h = sin(h_rad)
        cos_h = cos(h_rad)

        if t == 0
            a = b = 0
        else if abs(sin_h) >= abs(cos_h) # |b| > |a|
            b = q_1 / (p_1 / sin_h + q_2 * cos_h / sin_h + q_3)
            a = b * cos_h / sin_h
        else
            a = q_1 / (p_1 / cos_h + q_2 + q_3 * sin_h / cos_h)
            b = a * sin_h / cos_h

        RGB_a = [
             20/61 * p_2 + 451/1403 * a +  288/1403 * b
             20/61 * p_2 - 891/1403 * a -  261/1403 * b
             20/61 * p_2 - 220/1403 * a - 6300/1403 * b]
        RGB_c = reverse_adapted_responses(RGB_a)
        XYZ = reverse_corresponding_colors(RGB_c)

        return {J, C, h, Q, M, s, XYZ}

    return {forward_model, reverse_model}


# Table of unique hue data
unique_hues_s = [   'R',    'Y',    'G',    'B',    'R'] # symbol
unique_hues_h = [ 20.14,  90.00, 164.25, 237.53, 380.14] # unique hue
unique_hues_e = [    .8,     .7,    1.0,    1.2,     .8] # eccentricity
unique_hues_H = [     0,    100,    200,    300,    400] # hue quadrature


ciecam.hue_quad = (h) ->
    # Return the "hue quadrature" for a hue given in degrees.
    h = mod(h, 360)
    h += 360 if h < 20.14
    j = 0; j++ until unique_hues_h[j+1] >= h # set index j through looping test
    dist_j = (h - unique_hues_h[j]) / unique_hues_e[j]
    dist_k = (unique_hues_h[j+1] - h) / unique_hues_e[j+1]
    H_j = unique_hues_H[j]
    return H_j + 100 * dist_j / (dist_j + dist_k)


ciecam.inverse_hue_quad = (H) ->
    H = mod(H, 400)
    j = floor(H / 100) # which quadrant
    amt = H % 100
    [e_j, e_k] = unique_hues_e[j..j+1]
    [h_j, h_k] = unique_hues_h[j..j+1]
    h = ((amt * (e_k * h_j - e_j * h_k) - 100 * h_j * e_k) /
         (amt * (e_k - e_j) - 100 * e_k))
    return mod(h, 360)


ciecam.hue_comp = (H) ->
    # Return the "hue composition" given hue quadrature.
    H = mod(round(H), 400)
    j = floor(H / 100) # which quadrant
    amt = H % 100
    [s_j, s_k] = unique_hues_s[j..j+1]
    return if amt == 0 then "100#{s_j}" else "#{amt}#{s_k} #{100-amt}#{s_j}"


hue_comp_re = do ->
    # capturing groups: (1) symbol if a unique hue, or else...
    # (2) first amount, (3) first symbol, (4) second amount, (5) second symbol
    number = '([0-9]+(?:[.][0-9]*)?)'
    symbol = '([RYGB])'
    space = '[ ]*'
    num_and_sym = number + space + symbol
    cardinal_hue = '100(?:[.]0*)?' + space + symbol
    return new RegExp(cardinal_hue + '|' + num_and_sym + space + num_and_sym)


ciecam.parse_hue_comp = (comp) ->
    [whole_match, s_uniq, amt_j, s_j, amt_k, s_k] = comp.match(hue_comp_re)
    throw new Error('Unrecognized hue composition') unless whole_match?
    return unique_hues_s.indexOf(s_uniq) * 100 if s_uniq? # cardinal hue

    [j, k] = [unique_hues_s.indexOf(s_j), unique_hues_s.indexOf(s_k)]
    throw new Error('Hues must be neighbors') if abs(j - k) in [0, 2]

    # if k is smaller than j, swap j and k
    [j, k, amt_j, amt_k] = [k, j, amt_k, amt_j] if (k + 1) % 4 == j
    [amt_j, amt_k] = [parseFloat(amt_j), parseFloat(amt_k)]
    throw new Error('Hue comp must sum to 100') if abs(amt_j + amt_k - 100) > 1

    return 100 * j + amt_k
