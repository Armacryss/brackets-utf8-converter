define (require, exports, module) ->
    'use strict'
    
    ## Brackets Modules
    AppInit = brackets.getModule "utils/AppInit"
    FileSystem = brackets.getModule "filesystem/FileSystem"
    
    ## UTF Converter modules
    utfCore = require 'src/core'
    utfUI = require 'src/ui'

    ## Initialize UI
    do utfUI.init
        
    ## Init application
    AppInit.appReady () ->
        utfCore.init module
        utfUI.initStylesheet 'styles/main.css'
        return

    ## Exports handler
    exports.handleDetectEncoding = utfCore.handleDetectEncoding;