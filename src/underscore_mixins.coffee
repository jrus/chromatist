{mod} = chromatist.mathutils

_.mixin
    sum: (list) -> _.reduce(list, ((total, x) -> total + x), 0)
    
    # return an Array copy of the list cycled by n;
    # only creates 2 lists: efficient in time and space
    rotate: (list, n=1) ->
        n = mod(n, list.length)
        m = list.length - n
        (list0 = Array.prototype.slice.call(list, 0, m)).unshift(n, 0)
        (output = Array.prototype.slice.call(list, m)).splice(list0...)
        return output    
