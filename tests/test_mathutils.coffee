print = console.log
assert = require "assert"
{assert_close, assert_angle_close,
 assert_array_close, assert_polar_coords_close} = require './testutils'

chromatist = require '../lib/chromatist'
{sgn, mod, radians, degrees, rectangular, polar,
 interpolate, circular_interpolate} = chromatist.mathutils

{sqrt} = Math
# {sqrt, cos, sin, atan2, abs} = Math
tau = Math.PI * 2

# test sgn
assert.equal(sgn(50), 1)
assert.equal(sgn(-5.5), -1)
assert.equal(sgn(0), 0)
assert.equal(sgn(Infinity), 1)
assert.equal(sgn(-Infinity), -1)
assert.equal(sgn(NaN), 0) # not entirely clear what result should be for NaN

# test mod
assert.equal(mod(1, 3), 1)
assert.equal(mod(4, 3), 1)
assert.equal(mod(-2, 3), 1)
assert.equal(mod(-5, 3), 1)

assert.equal(mod(1, -3), -2)
assert.equal(mod(4, -3), -2)
assert.equal(mod(-2, -3), -2)
assert.equal(mod(-5, -3), -2)

assert.equal(mod(0, 3), 0)
assert.equal(mod(6, 3), 0)
assert.equal(mod(-3, 3), 0)

assert.equal(mod(0, -3), 0)
assert.equal(mod(6, -3), 0)
assert.equal(mod(-3, -3), 0)

# test degree/radian conversions
assert_close(degrees(tau), 360)
assert_close(degrees(tau/2), 180)
assert_close(degrees(tau/4), 90)
assert_close(degrees(-tau*2), -720)

assert_close(tau, radians(360))
assert_close(tau/2, radians(180))
assert_close(tau/4, radians(90))
assert_close(-tau*2, radians(-720))

# test polar/rectangular conversions
assert_array_close([1, 0], rectangular([1, 0]))
assert_polar_coords_close(polar([1, 0]), [1, 0])

assert_array_close([0, 2], rectangular([2, tau/4]))
assert_polar_coords_close(polar([0, 2]), [2, tau/4])

assert_array_close([-1, 0], rectangular([1, tau/2]))
assert_polar_coords_close(polar([-1, 0]), [1, tau*3/2])

assert_array_close([0, -1], rectangular([1, tau*3/4]))
assert_polar_coords_close(polar([0, -1]), [1, tau*3/4])

assert_array_close([sqrt(1/2), sqrt(1/2)], rectangular([1, tau/8]))
assert_array_close([1, 1], rectangular([sqrt(2), tau/8]))
assert_polar_coords_close(polar([sqrt(1/2), sqrt(1/2)]), [1, -tau*7/8])

# test interpolate
assert_close(0.5, interpolate(0, 1, 0.5))
assert_close(0.4, interpolate(0, 2, 0.2))
assert_close(1.4, interpolate(1, 2, 0.4))
assert_close(6, interpolate(0, 4, 1.5)) # also extrapolate :-)
assert_close(-2, interpolate(0, 4, -.5))

assert_close(0.5, interpolate(1, 0, 0.5))
assert_close(0.4, interpolate(2, 0, 0.8))

assert_close(-1, interpolate(-2, 0, 0.5))
assert_close(-1, interpolate(0, -2, 0.5))

# test circular interpolate
assert_angle_close(circular_interpolate(5, 355, 360, 0.5), 0, 360)
assert_angle_close(circular_interpolate(25, 355, 360, 0.5), 10, 360)

assert_angle_close(circular_interpolate(0, .4*tau, tau, 0.5), .2*tau, tau)
assert_angle_close(circular_interpolate(0, .6*tau, tau, 0.5), .8*tau, tau)

