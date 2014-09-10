define (require, exports, module) ->
    'use strict'
    
    ## Project name
    extensionName = 'Brackets Extension - UTF8 Converter'
    
    ## Modules
    AppInit = brackets.getModule 'utils/AppInit'
    Menus = brackets.getModule 'command/Menus'
    CommandManager = brackets.getModule 'command/CommandManager'
    ProjectManager = brackets.getModule 'project/ProjectManager'
    FileSystem = brackets.getModule 'filesystem/FileSystem'
    DocumentManager = brackets.getModule 'document/DocumentManager'
    ExtensionUtils = brackets.getModule 'utils/ExtensionUtils'
    NodeConnection = brackets.getModule 'utils/NodeConnection'
    PanelManager = brackets.getModule 'view/PanelManager'
    Dialogs = brackets.getModule "widgets/Dialogs"
    
    ## Templates
    azEncPanelTemplate = require 'text!html/panel.html'
    azEncRowTemplate = require 'text!html/rows.html'
    
    ## Extension variables
    files = []
    $azPanel
    nodeConnection
    azBkPanel
    
    