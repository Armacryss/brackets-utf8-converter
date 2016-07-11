define (require, exports, module) ->
    'use strict'
        
    ## Brackets Module
    ProjectManager = brackets.getModule 'project/ProjectManager'
    ExtensionUtils = brackets.getModule 'utils/ExtensionUtils'
    NodeConnection = brackets.getModule 'utils/NodeConnection'
    Dialogs = brackets.getModule "widgets/Dialogs"
    Menus = brackets.getModule 'command/Menus'
    CommandManager = brackets.getModule 'command/CommandManager'
    
    
    ## UI Module
    utfUI   =   require './ui' 
    preferencesDialog = require './preferencesdialog'
    specificEncodingDialog = require './specificencodingdialog'
    Preferences = require './preferences'
    
    ## Variables
    @currentItem
    @nodeConnection
    
    ## Not exposed
    chain = () ->
        functions = Array.prototype.slice.call(arguments, 0);
        if functions.length > 0
            firstFunction = do functions.shift
            firstPromise = do firstFunction.call
            firstPromise.done () -> chain.apply null, functions
    
    
    ## Init
    init = (mainModule) =>
        @nodeConnection = new NodeConnection
        connect = () =>
            connectionPromise = @nodeConnection.connect(true)
            connectionPromise.fail (err) -> console.error '[UTF8-Converter] failed to establish a connection with Node : ' + err
            connectionPromise
        loadUtfDomain = () =>
            ## We need the main module path
            path = ExtensionUtils.getModulePath(mainModule, 'node/brutfDomain')
            loadPromise = @nodeConnection.loadDomains [path], true
            loadPromise.fail (err) -> console.log '[UTF8-Converter] failed to load domain : ' + err
            loadPromise.done () -> console.log '[UTF8-Converter] successfully loaded'
            loadPromise
        chain connect, loadUtfDomain
        
        ## Waiting for sub menu implementation.
        MAIN_TOOL_COMMAND_ID = 'brutf_main_menu'
        DETECT_ENCODING_COMMAND_ID = 'brutf.detectEncoding'
        CONVERT_ENCODING_COMMAND_ID = 'brutf.goEncoding'
        PREFERENCES_ENCODING_COMMAND_ID = 'brutf.preferences'
        CONVERT_FROM_ENCODING_COMMAND_ID = 'brutf.encodeFrom'
        
        
        ## Add commands
        CommandManager.register 'Detect Encoding', DETECT_ENCODING_COMMAND_ID, @handleDetectEncoding
        CommandManager.register 'Encoding Preferences', PREFERENCES_ENCODING_COMMAND_ID, preferencesDialog.show
        CommandManager.register 'Convert to UTF8 with specified encoding', CONVERT_FROM_ENCODING_COMMAND_ID, @handleConvertFromEncodingMenu
        
        ## Add menu items
        menu = Menus.getContextMenu(Menus.ContextMenuIds.PROJECT_MENU)
        do menu.addMenuDivider
        
        menu.addMenuItem DETECT_ENCODING_COMMAND_ID
        
        ## Directory Convert enable only if auto convert is enabled
        if Preferences.get 'allowAutoConvert'
            CommandManager.register 'Convert to UTF8', CONVERT_ENCODING_COMMAND_ID, @handleConvertEncodingFromMenu        
            menu.addMenuItem CONVERT_ENCODING_COMMAND_ID
            
        menu.addMenuItem PREFERENCES_ENCODING_COMMAND_ID
        menu.addMenuItem CONVERT_FROM_ENCODING_COMMAND_ID
        
        return
    
    ## Convert process from panel
    convertFile = () =>
        @currentItem = $(event.target)
        convertPromise = @nodeConnection.domains.bracketsUtfConverter.convertFileEncoding @currentItem.data('file')
        
        convertPromise.fail (err) ->
            console.log '[UTF8-Converter] failed to convert the file : ' + err
            
        convertPromise.done (newFilePath) =>
            console.log '[UTF8-Converter] converted a file'
            @currentItem.html('Converted')
       
    ## Detection process for folders
    detectEncoding = () =>
        encodingPromise = @nodeConnection.domains.bracketsUtfConverter.getFilesEncoding(ProjectManager.getSelectedItem()._path.toString(), Preferences.get('allowDigging'))
        
        encodingPromise.fail (err) -> console.error '[UTF8-Converter] failed to detect encoding of files', err
        encodingPromise.done (data) -> utfUI.showPanel data.files
        encodingPromise
        
    ## Detection process for single file
    detectSingleFileEncoding = () =>
        currentFile = ProjectManager.getSelectedItem()._path.toString()
        encodingPromise = @nodeConnection.domains.bracketsUtfConverter.getFileEncoding currentFile
        encodingPromise.fail (err) -> console.error '[UTF8-Converter] failed to detect encoding of file', err
        encodingPromise.done (data) -> utfUI.showPanel data
        encodingPromise
        
    ## Convert directory from context menu
    convertDirectoryFromMenu = () =>
        currentDirectory = ProjectManager.getSelectedItem()._path.toString()
        convertPromise = @nodeConnection.domains.bracketsUtfConverter.convertDirectory currentDirectory, Preferences.get('allowDigging')
        convertPromise.fail (err) ->
            console.log '[UTF8-Converter] failed to convert the directory : ' + err
        convertPromise.done () =>
            console.log '[UTF8-Converter] converted a directory'
        convertPromise
            
    ## Convert a single file selected from context menu
    convertSelectedFileFromMenu = () =>
        currentFile = ProjectManager.getSelectedItem()._path.toString()
        convertPromise = @nodeConnection.domains.bracketsUtfConverter.convertFileEncoding currentFile
        convertPromise.fail (err) ->
            console.log '[UTF8-Converter] failed to convert the file : ' + err
        convertPromise.done () =>
            console.log '[UTF8-Converter] converted a file.'
        convertPromise
    
    ## Main handler
    handleDetectEncoding = () -> 
        if ProjectManager.getSelectedItem()._isDirectory
            chain detectEncoding 
        else
            chain detectSingleFileEncoding
        return
    
    ## Handle directory conversion
    handleConvertEncodingFromMenu = () ->
        if ProjectManager.getSelectedItem()._isDirectory
            chain convertDirectoryFromMenu 
        else
            chain convertSelectedFileFromMenu
        return
        
    ## Handle conversion from specified encoding
    handleConvertFromEncodingMenu = () =>
      if !ProjectManager.getSelectedItem()._isDirectory
            currentFile = ProjectManager.getSelectedItem()._path.toString()
            chain specificEncodingDialog.show @nodeConnection, currentFile
      else 
            console.log '[UTF8-Converter] cannot convert directory with specific encoding (yet)'
      return
    
    ## Exports
    exports.init = init
    exports.convertFile = convertFile
    exports.detectEncoding = detectEncoding
    exports.handleDetectEncoding = handleDetectEncoding
    exports.handleConvertEncodingFromMenu = handleConvertEncodingFromMenu
    exports.handleConvertFromEncodingMenu = handleConvertFromEncodingMenu
    return
