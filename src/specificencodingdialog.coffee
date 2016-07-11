define (require, exports) ->
    CommandManager = brackets.getModule "command/CommandManager"
    Dialogs = brackets.getModule "widgets/Dialogs"
    dialogTemplate = require "text!templates/specific-encoding-dialog.html"
    NodeConnection = brackets.getModule 'utils/NodeConnection'
    
    @nodeConnection
    @dialog
    @$dialog
    @fileEncoding
    @file
    
    collectValues = () =>
        @fileEncoding = $("*[specificEncodingProperty]", _this.$dialog).val().trim()
        return

    init = () ->
        return

    ## Convert process
    convertFileFromEncoding = () =>
        convertPromise = @nodeConnection.domains.bracketsUtfConverter.convertFileFromEncoding @file,@fileEncoding
        
        convertPromise.fail (err) ->
            console.log '[UTF8-Converter] failed to convert the file : ' + err
            
        convertPromise.done (newFilePath) =>
            if newFilePath?
              console.log '[UTF8-Converter] converted a file : ' + newFilePath
            else
              console.log '[UTF8-Converter] couldn\'t convert file : ' + @file
            
    exports.show = (nodeConnection, file) =>
        compiledTemplate = Mustache.render dialogTemplate

        @dialog = Dialogs.showModalDialogUsingTemplate compiledTemplate
        @$dialog = do @dialog.getElement
        @file = file
        @nodeConnection = nodeConnection
        
        do init

        @dialog.done (buttonId) ->
            if buttonId is "ok"
                do collectValues
                do convertFileFromEncoding
            return
        return
    return
