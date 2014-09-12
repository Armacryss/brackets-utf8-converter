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
            connectionPromise.fail -> console.error '[UTF8-Converter] failed to establish a connection with Node'
            connectionPromise
        loadUtfDomain = () =>
            ## We need the main module path
            path = ExtensionUtils.getModulePath(mainModule, 'node/brutfDomain')
            loadPromise = @nodeConnection.loadDomains [path], true
            loadPromise.fail () -> console.log '[UTF8-Converter] failed to load domain'
            loadPromise.done () -> console.log '[UTF8-Converter] successfully loaded'
            loadPromise
        chain connect, loadUtfDomain
        
        MY_COMMAND_ID = 'brutf.detectEncoding'
        CommandManager.register 'Detect Encoding', MY_COMMAND_ID, @handleDetectEncoding
        Menus.getContextMenu(Menus.ContextMenuIds.PROJECT_MENU).addMenuItem MY_COMMAND_ID
    
    ## Convert process
    convertFile = () =>
        @currentItem = $(event.target)
        convertPromise = @nodeConnection.domains.bracketsUtfConverter.convertFileEncoding @currentItem.data('file')
        
        convertPromise.fail (err) ->
            console.log '[UTF8-Converter] failed to convert the file : ' + err
            
        convertPromise.done (newFilePath) =>
            console.log '[UTF8-Converter] converted a file'
            @currentItem.html('Converted')
       
    ## Detection process
    detectEncoding = () =>
        encodingPromise = @nodeConnection.domains.bracketsUtfConverter.getFilesEncoding(ProjectManager.getSelectedItem()._path.toString(), true)
        
        encodingPromise.fail (err) -> console.error '[UTF8-Converter] failed to detect encoding of files', err
        encodingPromise.done (data) -> utfUI.showPanel data.files
        encodingPromise
    
    ## Main handler
    handleDetectEncoding = () -> 
        if ProjectManager.getSelectedItem()._isDirectory
            chain detectEncoding 
        else
            Dialogs.showModalDialog '', 'UTF8-Converter', 'You must select a <b>directory</b> to detect encodings.<br />This extension doesn\'t work with a single files.'
        return
    
    ## Exports
    exports.init = init
    exports.convertFile = convertFile
    exports.detectEncoding = detectEncoding
    exports.handleDetectEncoding = handleDetectEncoding
    return