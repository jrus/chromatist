root = this

if typeof exports != 'undefined'
    # If we are in a commonJS context, make chromatist the exports.
    # Also, import underscore.js
    chromatist = module.exports
    _ = require 'underscore'
else
    # Otherwise, make a new object for it, and attach it to the root object.
    # Assume that underscore has already been attached to the root object.
    chromatist = root.chromatist = {}
    _ = root._

chromatist.VERSION = '0.1.0'
