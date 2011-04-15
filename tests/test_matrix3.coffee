colorjs = require '../lib/color.js'
{Matrix3} = colorjs.matrix3
assert = require 'assert'
{assert_matrix_equal, assert_matrix_close} = require('./testutils')



##################################################################

I = Matrix3.identity()
Z = Matrix3.zeros()

# Test that identity does what is expected
assert.deepEqual(I.flat(), [1, 0, 0
                            0, 1, 0
                            0, 0, 1])

# test that zeros does what is expected
assert.deepEqual(Z.flat(), [0, 0, 0
                            0, 0, 0
                            0, 0, 0])

M1 = new Matrix3 [
    1, 3, 3
    1, 4, 3
    1, 3, 4]
M2 = new Matrix3 [ # M1 inverse
     7, -3, -3
    -1,  1,  0
    -1,  0,  1]
M3 = new Matrix3 [ # M1 transpose
    1, 1, 1
    3, 4, 3
    3, 3, 4]

M4 = new Matrix3 [ # rotate 90 degrees in x-y plane
     0, 1, 0
    -1, 0, 0
     0, 0, 1]

# test that multiplying by I or adding zeros does as expected
assert_matrix_equal(M1, M1.dot(I))
assert_matrix_equal(M1, I.dot(M1))
assert_matrix_equal(M1, M1.add(Z))
assert_matrix_equal(M1, Z.add(M1))

# test that inverting M1 or M2 returns the other
assert_matrix_close(M1, M2.inverse())
assert_matrix_close(M1, M2.inverse())

# test that multiplying inverses results in identity
assert_matrix_close(M1.dot(M2), I)
assert_matrix_close(M2.dot(M1), I)

assert_matrix_close(M1.scalar_multiply(3), M2.scalar_multiply(1/3).inverse())

# test determinants
assert.equal(M1.determinant(), 1)
assert.equal(M1.scalar_multiply(4).determinant(), 4*4*4)
assert.equal(M1.scalar_multiply(4).inverse().determinant(), 1/4/4/4)

# test transpose
assert_matrix_equal(M1.transpose(), M3)
assert_matrix_equal(M1, M3.transpose())

assert_matrix_close(M1.transpose().inverse().transpose(), M2)
assert_matrix_close(M1.inverse().transpose().inverse(), M3)

# test that rotating 4 times by 90 degrees is the identity
assert_matrix_equal(M4.dot(M4).dot(M4).dot(M4), I)

# TODO test linear_transformation and dot with vectors.
