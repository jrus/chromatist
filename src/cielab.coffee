cielab = chromatist.cielab = {}

{normalize_whitepoint} = chromatist.cie
{pow} = Math

cielab.Converter = (white='D65') ->
    white = normalize_whitepoint(white) # always returns white with Y = 100
    [Xw, Yw, Zw] = white
    
    d = 6/29
    f = (t) -> if t > d*d*d then pow(t, 1/3) else t/3/d/d + 4/29
    g = (t) -> if t > d then t*t*t else 3*d*d * (t - 4/29) # inverse of f
    
    from_XYZ = ([X, Y, Z]) ->
        fY = f(Y/Yw)
        L_star = 116 * fY - 16
        a_star = 500 * (f(X/Xw) - fY)
        b_star = 200 * (fY - f(Z/Zw))
        return [L_star, a_star, b_star]
        
    to_XYZ = ([L_star, a_star, b_star]) ->
        temp = (L_star + 16)/116
        X = Xw * g(temp + a_star/500)
        Y = Yw * g(temp)
        Z = Zw * g(temp - b_star/200)
        return [X, Y, Z]
    
    return {from_XYZ, to_XYZ}
