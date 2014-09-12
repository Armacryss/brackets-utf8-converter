define (require, exports) ->
    CommandManager = brackets.getModule "command/CommandManager"
    Dialogs = brackets.getModule "widgets/Dialogs"
    Preferences = require "./preferences"
    dialogTemplate = require "text!templates/preferences-dialog.html"
    questionTemplate = require "text!templates/question-dialog.html"
    
    @dialog
    @$dialog
    
    setValues = (values) =>
        $("*[settingsProperty]", @$dialog).each ->
            $this = $ this
            type = $this.attr 'type'
            property = $this.attr "settingsProperty"
            if type is "checkbox" then $this.prop "checked", values[property] else $this.value values[property]
            return

    collectValues = () =>
        $("*[settingsProperty]", @$dialog).each ->
            $this = $ this
            type = $this.attr 'type'
            property = $this.attr "settingsProperty"
            if type is "checkbox" then Preferences.set property, $this.prop("checked") else Preferences.set(property, $this.val().trim() || null)
            do Preferences.save
            return

    assignActions = () =>
        $("button[data-button-id='defaults']", @$dialog).on "click", (e) ->
            do e.stopPropagation
            setValues Preferences.getDefaults()
            return
        return

    init = () ->
        setValues Preferences.getAll()
        do assignActions
        return

    showRestartDialog = () ->
        compiledTemplate = Mustache.render questionTemplate, {
            title: "Restart",
            question: "Do you wish to restart Brackets to apply new settings?"
        }
        Dialogs.showModalDialogUsingTemplate(compiledTemplate).done (buttonId) ->
            CommandManager.execute("debug.refreshWindow") if buttonId is "ok"
            return
        return

    exports.show = () =>
        compiledTemplate = Mustache.render dialogTemplate

        @dialog = Dialogs.showModalDialogUsingTemplate compiledTemplate
        @$dialog = do @dialog.getElement

        do init

        @dialog.done (buttonId) ->
            if buttonId is "ok"
                do collectValues
                do showRestartDialog
            return
        return
    return
