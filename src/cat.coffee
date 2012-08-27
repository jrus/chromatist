print = -> console.log arguments
cat = chromatist.cat = {}

{Matrix3} = chromatist.matrix3
{normalize_whitepoint} = chromatist.cie




transforms =
    # 'von kries': [
    #      .4002,  .7076, -.0808,
    #     -.2263, 1.1653,  .0457,
    #      .0,    .0,      .9182]
    
    'von kries': [ # hunt–pointer–estevez cone fundamental space
         .38971,  .68898, -.07868,
        -.22981, 1.18340,  .04641,
         .00000,  .00000, 1.00000]
    'linear bradford': [
         .8951,  .2664, -.1614,
        -.7502, 1.7135,	 .0367,
         .0389, -.0686, 1.0296]
    cmccat2000: [
         .7982,  .3389, -.1371,
        -.5918, 1.5512,  .0406,
         .0008,  .0239,  .9753]
    cat02: [
         .7328,  .4296, -.1624,
        -.7036, 1.6975,  .0061,
         .0030,  .0136,  .9834]


cat.Converter = (from_white, to_white, transform='cat02') ->
    # make sure that 'transform' is a matrix
    if typeof transform is 'string' then transform = transforms[transform]
    transform = new Matrix3 transform
    
    # normalize whitepoints: converts standard illuminant names to arrays
    from_white = normalize_whitepoint(from_white)
    to_white = normalize_whitepoint(to_white)
    
    # calculate the 'gain matrix' that transforms one white point to another
    # in the transform space
    [from_L, from_M, from_S] = transform.dot(from_white)
    [to_L, to_M, to_S] = transform.dot(to_white)
    gain_matrix = new Matrix3 [
        to_L / from_L, 0, 0
        0, to_M / from_M, 0
        0, 0, to_S / from_S]
    
    # the final forward transform matrix. invert it for the reverse transform
    forward_matrix = transform.inverse().dot(gain_matrix).dot(transform)
    return {
        forward: forward_matrix.linear_transform(),
        backward: forward_matrix.inverse().linear_transform()}