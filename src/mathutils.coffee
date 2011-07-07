mathutils = chromatist.mathutils = {}

{sqrt, cos, sin, atan2, abs} = Math
tau = Math.PI * 2


mathutils.sgn = (x) ->
    (x > 0) - (x < 0)  # 1 for x > 0, -1 for x < 0, or 0 otherwise


# In JavaScript, the result of x % y always takes the sign of x. This can be
# undesirable. This function’s result always takes the sign of y, instead.
mathutils.mod = mod = (x, y) ->
    unless (js_mod = x % y) and (x > 0 ^ y > 0) then js_mod
    else js_mod + y


# convert degrees to radians
mathutils.radians = (x) -> x * tau / 360


# convert radians to degrees
mathutils.degrees = (x) -> x * 360 / tau


# convert polar coordinates to rectangular coordinates
mathutils.rectangular = ([r, a]) -> [r * cos(a), r * sin(a)]


# convert rectangular coordinates to polar coordinates
mathutils.polar = ([x, y]) -> [sqrt(x*x + y*y), atan2(y, x)]


# interpolate between numbers
mathutils.interpolate = interpolate = (x_0, x_1, fraction) ->
    (1 - fraction) * x_0 + fraction * x_1


# interpolate between angles
mathutils.circular_interpolate = (a_0, a_1, max_a, fraction) ->
    [a_0, a_1] = [mod(a_0, max_a), mod(a_1, max_a)]
    if abs(a_1 - a_0) <= max_a / 2
        interpolate(a_0, a_1, fraction)
    else
        (interpolate(a_0, a_1, fraction) + max_a / 2) % max_a
