strutils = colorjs.strutils = {}

strutils.trim = (str) ->
    str.replace(/^\s+|\s+$/g, "")

strutils.codepoints = (str) ->
    (str.charCodeAt(i) for i in [0...str.length])
