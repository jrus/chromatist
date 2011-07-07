hsl = chromatist.hsl = {} # hsl and hsv 2 separate "modules"
hsv = chromatist.hsv = {}

{abs, max, min} = Math
{mod} = chromatist.mathutils


hsl.converter = do ->
    from_RGB = ([R, G, B]) ->
        unless 0 <= R <= 1 and 0 <= G <= 1 and 0 <= B <= 1
            throw new Error('Bad Input: R, G, and B must be in range [0, 1]')

        [M, m] = [max(R, G, B), min(R, G, B)]
        C = M - m                                # "chroma"
        H =
            if      C == 0 then null             # use conditional for temporary
            else if M == R then (G - B) / C      # piecewise definition of H in
            else if M == G then (B - R) / C + 2  # range [0, 6)
            else                (R - G) / C + 4
        H = (H % 6) * 60                         # express H in degrees [0, 360)
        L = (M + m) / 2
        S = if C == 0 then 0 else C / (1 - abs(2 * L - 1))
        return [H, S, L]

    to_RGB = ([H, S, L]) ->
        unless 0 <= L <= 1 and 0 <= S <= 1
            throw new Error('Bad Input: L and S must be in range [0, 1]')
        if S == 0                                        # achromatic; short circuit
            return [L, L, L]
        unless typeof H is 'number'  # H can only be null if S = 0
            throw new Error('Bad Input: If S is non-zero, H must have a value.');

        H = mod(H, 360) / 60                        # scale H to range [0, 6)
        C = 2 * S * (if L < 1/2 then L else 1 - L)  # C = max - min, "chroma"
        X = C * (1 - abs(H % 2 - 1))                # X = mid - min
        R = G = B = L - C/2                         # set R = G = B = min, for now

        H = ~~H                                     # truncate H for use as index
        R += [C, X, 0, 0, X, C][H]  # define R, G, B piecewise:
        G += [X, C, C, X, 0, 0][H]  #   min = min + 0, mid = min + X,
        B += [0, 0, X, C, C, X][H]  #   max = min + C
        return [R, G, B]

    return {from_RGB, to_RGB}


hsv.converter = do ->
    from_RGB = ([R, G, B]) ->
        unless 0 <= R <= 1 and 0 <= G <= 1 and 0 <= B <= 1
            throw new Error('Bad Input: R, G, and B must be in range [0, 1]')

        V = max(R, G, B)
        C = V - min(R, G, B)                     # "chroma", max - min
        H =
            if      C == 0 then null             # use conditional for temporary
            else if M == R then (G - B) / C      # piecewise definition of H in
            else if M == G then (B - R) / C + 2  # range [0, 6)
            else                (R - G) / C + 4
        H = (H % 6) * 60                         # express H in degrees [0, 360)
        S = if C == 0 then 0 else C / V
        return [H, S, V]

    to_RGB = ([H, S, V]) ->
        unless 0 <= V <= 1 and 0 <= S <= 1
            throw new Error('Bad Input: V and S must be in range [0, 1]');
        if S == 0                    # achromatic; short circuit
            return [V, V, V]
        unless typeof H is 'number'  # H can only be null if S = 0
            throw new Error('Bad Input: If S is non-zero, H must have a value.');

        H = (H % 360) / 60           # scale H to range [0, 6)
        C = V * S                    # C = max - min, "chroma"
        X = C * (1 - abs(H % 2 - 1)) # X = mid - min
        R = G = B = V - C            # set R = G = B = min, temporarily

        H = ~~H                      # truncate H for use as index
        R += [C, X, 0, 0, X, C][H]   # define R, G, B piecewise:
        G += [X, C, C, X, 0, 0][H]   #   min = min + 0, mid = min + X,
        B += [0, 0, X, C, C, X][H]   #   max = min + C
        return [R, G, B]

    return {from_RGB, to_RGB}
