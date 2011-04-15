fs = require 'fs'
CoffeeScript = require 'coffee-script'
log = console.log

source_directory = 'src/colorjs/'
index_source = 'colorjs'
sources = [
    'strutils', 'mathutils', 'underscore_mixins', 'matrix3'
    'cie', 'rgb', 'hsl_hsv', 'cielab', 'ciecam', 'gamut'
]

compile = (filename, opts) ->
    source_path = source_directory + filename + '.coffee'
    content = fs.readFileSync source_path, 'utf-8'
    output = CoffeeScript.compile content, opts
    log "compiled #{source_path}"
    return output

task 'build', 'build the main color js library', (options) ->
    output_filename = "./lib/color.js"
    
    output = [compile index_source, {bare: true}] # compile the first script "bare"
    output = output.concat (compile source for source in sources)
    
    output_script = """
        (function() {
        #{output.join '\n'}
        }).call(this);
        """
    
    fs.writeFileSync output_filename, output_script, 'utf-8'
    log "saved compiled source in #{output_filename}"
