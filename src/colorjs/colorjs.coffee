root = this

if typeof exports != 'undefined'
    # If we are in a commonJS context, make colorjs the exports.
    # Also, import underscore.js
    colorjs = module.exports
    _ = require 'underscore'
else
    # Otherwise, make a new object for it, and attach it to the root object.
    # Assume that underscore has already been attached to the root object.
    colorjs = root.colorjs = {}
    _ = root._

colorjs.VERSION = '0.1.0'
