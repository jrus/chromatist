print = console.log
repr = JSON.stringify

_ = require 'underscore'
chromatist = require '../lib/chromatist'

CIECAM = chromatist.ciecam

CIELAB = chromatist.cielab

CIELAB_c = CIELAB.Converter([95.05, 100, 108.88])

# TODO: make these into actual tests, and add some others. In particular
#       add tests for hue quad/hue comp functions.

fairchild_tests = ->
    output = 'Fairchild Examples:\n'
    output += '1:\n'
    converter = CIECAM.Converter(
        whitepoint: [95.05, 100, 108.88]
        adapting_luminance: 318.3)
    inputs = [19.01, 20.00, 21.78]
    correlates = converter.forward_model(inputs)
    _(correlates).extend(
        H: H = CIECAM.hue_quad(correlates.h)
        Hcomp: Hcomp = CIECAM.hue_comp(H)
        H2: CIECAM.parse_hue_comp(Hcomp))
    output += "JCh(#{repr(inputs)}) =\n"
    output += repr(correlates)

    output += '\n\n2:\n'
    converter = CIECAM.Converter(
        whitepoint: 'D65'
        adapting_luminance: 31.83)
    inputs = [57.06, 43.06, 31.96]
    print repr(CIELAB_c.from_XYZ(inputs))
    correlates = converter.forward_model(inputs)
    _(correlates).extend(
        H: H = CIECAM.hue_quad(correlates.h)
        Hcomp: Hcomp = CIECAM.hue_comp(H)
        H2: CIECAM.parse_hue_comp(Hcomp))
    output += "JCh(#{repr(inputs)}) =\n"
    output += repr(correlates)

    output += '\n\n3:\n'
    converter = CIECAM.Converter(
        whitepoint: 'A'
        adapting_luminance: 318.31)
    inputs = [3.53, 6.56, 2.14]
    correlates = converter.forward_model(inputs)
    _(correlates).extend(
        H: H = CIECAM.hue_quad(correlates.h)
        Hcomp: Hcomp = CIECAM.hue_comp(H)
        H2: CIECAM.parse_hue_comp(Hcomp))
    output += "JCh(#{repr(inputs)}) =\n"
    output += repr(correlates)

    output += '\n\n4:\n'
    converter = CIECAM.Converter(
        whitepoint: 'A'
        adapting_luminance: 31.83)
    inputs = [19.01, 20.00, 21.78]
    correlates = converter.forward_model(inputs)
    _(correlates).extend(
        H: H = CIECAM.hue_quad(correlates.h)
        Hcomp: Hcomp = CIECAM.hue_comp(H)
        H2: CIECAM.parse_hue_comp(Hcomp))
    output += "JCh(#{repr(inputs)}) =\n"
    output += repr(correlates)

print fairchild_tests()

hunt_test = ->
    output = 'Hunt example:\n'
    converter = CIECAM.Converter(
        whitepoint: [98.88, 90.00, 32.03]
        adapting_luminance: 200
        background_luminance: 18)
    correlates = converter.forward_model([19.31, 23.93, 10.14])
    _(correlates).extend(
        H: H = CIECAM.hue_quad(correlates.h)
        Hcomp: Hcomp = CIECAM.hue_comp(H)
        H2: CIECAM.parse_hue_comp(Hcomp))
    output += repr(correlates) + '\n'
    
    output += repr([19.31, 23.93, 10.14]) + '\n'
    output += repr(converter.reverse_model(
        J: correlates.J
        C: correlates.C
        h: correlates.h
    ))
    return output

