assert = require 'assert'
{abs} = Math
tau = Math.PI * 2

exports.assert_matrix_equal = (matrix_1, matrix_2) ->
    assert.deepEqual(matrix_1.flat(), matrix_2.flat())

exports.assert_matrix_close = (matrix_1, matrix_2, max_diff=1e-5) ->
    for entry_1, i in matrix_1.matrix
        entry_2 = matrix_2.matrix[i]
        assert.ok(abs(entry_1 - entry_2) < max_diff)

exports.assert_close = assert_close = (number_1, number_2, max_diff=1e-5) ->
    assert.ok(abs(number_1 - number_2) < max_diff)

exports.assert_angle_close = assert_angle_close = (angle_1, angle_2, max_angle, max_diff=1e-5) ->
    angle_diff = abs((angle_1 - angle_2) % max_angle)
    angle_diff = max_angle - angle_diff if angle_diff > max_angle / 2
    assert.ok(angle_diff < max_diff)

exports.assert_array_close = (array_1, array_2, max_diff=1e-5) ->
    for elem_1, i in array_1
        elem_2 = array_2[i]
        assert_close(elem_1, elem_2, max_diff)

exports.assert_polar_coords_close = ([r_1, a_1], [r_2, a_2], max_diff=1e-5) ->
    assert_close(r_1, r_2)
    assert_angle_close(a_1, a_2, tau)

