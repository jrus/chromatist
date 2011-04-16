matrix3 = chromatist.matrix3 = {}

# right justify a string, padding it on the left by the 'pad' character
rjust = (str, len, pad=' ') ->
    diff = len - str.length
    return if diff <= 0 then str else Array(diff).concat(str).join(pad)


class Matrix3
    constructor: (matrix) ->
        @matrix = _.flatten(matrix)
        unless @matrix.length == 9
            throw new Error('A 3 by 3 Matrix must have 9 entries') 
        @shape = [3, 3]
    
    determinant: ->
        if @_determinant? then return @_determinant # look-up cached value

        [M00, M01, M02
         M10, M11, M12
         M20, M21, M22] = @matrix
        
        return @_determinant = (
            M00 * (M22*M11 - M21*M12) +
            M10 * (M21*M02 - M22*M01) +
            M20 * (M12*M01 - M11*M02))
    
    inverse: ->
        c = 1 / @determinant()
        [M00, M01, M02
         M10, M11, M12
         M20, M21, M22] = @matrix
        
        return new Matrix3 [
            (M22*M11 - M21*M12)*c, (M21*M02 - M22*M01)*c, (M12*M01 - M11*M02)*c
            (M20*M12 - M22*M10)*c, (M22*M00 - M20*M02)*c, (M10*M02 - M12*M00)*c
            (M21*M10 - M20*M11)*c, (M20*M01 - M21*M00)*c, (M11*M00 - M10*M01)*c]
    
    rows: ->
        [@matrix[0...3], @matrix[3...6], @matrix[6...9]]

    flat: ->
        @matrix
    
    transpose: ->
        new Matrix3(_.zip(@rows()...))
    
    # return a function which left-multiplies a column vector by the matrix
    linear_transform: ->
        if @_lt? then return @_lt
        [M00, M01, M02
         M10, M11, M12
         M20, M21, M22] = @matrix
        return @_lt = ([v0, v1, v2]) ->
            [M00*v0 + M01*v1 + M02*v2
             M10*v0 + M11*v1 + M12*v2
             M20*v0 + M21*v1 + M22*v2]
    
    # multiply two 3x3 matrices
    _matrix_multiply: (other) ->
        [M00, M01, M02
         M10, M11, M12
         M20, M21, M22] = @matrix

        [N00, N01, N02
         N10, N11, N12
         N20, N21, N22] = other.matrix

        return new Matrix3 [
            M00*N00 + M01*N10 + M02*N20, M00*N01 + M01*N11 + M02*N21, M00*N02 + M01*N12 + M02*N22
            M10*N00 + M11*N10 + M12*N20, M10*N01 + M11*N11 + M12*N21, M10*N02 + M11*N12 + M12*N22
            M20*N00 + M21*N10 + M22*N20, M20*N01 + M21*N11 + M22*N21, M20*N02 + M21*N12 + M22*N22]

    dot: (other) ->
        if other.shape?[0] == 3 and other.shape?[1] == 3 and other.matrix?
            return @_matrix_multiply(other)
        else if other.length == 3
            return @linear_transform()(other)
        throw new Error("Don't know how to dot with this object.")
    
    
    # apply the 2-input operation to the entries of this and the other matrix,
    # and put the output in a new matrix
    elementwise: (other, operation) ->
        new Matrix3(operation(elem, other.matrix[i]) for elem, i in @matrix)
    
    multiply_elements: (other) ->
        @elementwise(other, (x, y) -> x * y)

    add: (other) ->
        @elementwise(other, (x, y) -> x + y)
    
    scalar_multiply: (a) ->
        new Matrix3 (x * a for x in @matrix)
        
    toString: (precision) ->
        precision ?= 3
        fixed = (x.toFixed(precision) for x in @matrix)
        entry_width = _.max(s.length for s in fixed)
        fixed = (rjust(x, entry_width) for x in fixed)
        rows = [fixed[0...3], fixed[3...6], fixed[6...9]]
        printed_rows = ('[' + row.join(', ') + ']' for row in rows)
        return "[#{printed_rows.join(',\n ')}]"
    
    @identity: ->
        new @ [
            1, 0, 0
            0, 1, 0
            0, 0, 1]
    
    @zeros: ->
        new @ [
            0, 0, 0
            0, 0, 0
            0, 0, 0]

    @ones: ->
        new @ [
            1, 1, 1
            1, 1, 1
            1, 1, 1]

matrix3.Matrix3 = Matrix3