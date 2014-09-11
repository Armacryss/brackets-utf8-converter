define (require, exports, module) -> 
    'use strict'
    
    ## Brackets Modules
    ProjectManager = brackets.getModule 'project/ProjectManager'
    PanelManager = brackets.getModule 'view/PanelManager'
    ExtensionUtils = brackets.getModule 'utils/ExtensionUtils'
    
    ## Mustache templates
    templatePanel = require 'text!templates/panel.html'
    templateRow = require 'text!templates/rows.html'
    
    ## Core engine
    core = require './core'
    
    ## Variables
    @bracketsBottomPanel
    @$utfBottomPanel
    
    ## Shortcut to add rows (not exposed)
    insertRows = (files) =>
        rowsHtml = Mustache.render templateRow, {'fileList': files}
        @$utfBottomPanel.find('.rows-container').empty().append rowsHtml
        
    ## initialize the default element for the UI
    init = () ->
        panelHtml = Mustache.render templatePanel, ''
        @bracketsBottomPanel = PanelManager.createBottomPanel 'brutf.encoding.listfiles', $(panelHtml), 200
        @$utfBottomPanel = $ '#brackets-utf8-converter-panel'
        @$utfBottomPanel.on 'click', '.close', ->
            do bracketsBottomPanel.hide
        .on 'click', '.btnConvert', core.convertFile
        $(ProjectManager).on "beforeProjectClose", -> do bracketsBottomPanel.hide
        return
    
    ## CSS to use
    initStylesheet = (cssname) ->
         ExtensionUtils.loadStyleSheet module, "../" + cssname
    
    ## Exposed method to display the panel
    showPanel = (files) =>
        do @bracketsBottomPanel.show
        insertRows files
    
    ## Exports
    exports.init = init
    exports.initStylesheet = initStylesheet
    exports.showPanel = showPanel
    return