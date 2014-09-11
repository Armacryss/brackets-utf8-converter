define (require, exports, module) ->
    "use strict"
    
    PREFERENCES_KEY     =   "utf8-converter"
    _                   =   brackets.getModule("thirdparty/lodash")
    PreferencesManager  =   brackets.getModule("preferences/PreferencesManager")
    utf_prefs           =   PreferencesManager.getExtensionPrefs(PREFERENCES_KEY)
    
    defaultPreferences = {
        "allowDigging": { "type": "boolean", "value": true },
        "allowAutoConvert": { "type" : "boolean", "value": false }
    }

    _.each(defaultPreferences, (definition, key) -> 
            if definition.os && definition.os[brackets.platform] 
                utf_prefs.definePreference key, definition.type, definition.os[brackets.platform].value
            else 
                utf_prefs.definePreference key, definition.type, definition.value
            return
    )

    do utf_prefs.save
    
    utf_prefs.getAll = ->
        obj = {}
        _.each(defaultPreferences (defintion, key) =>
            obj[key] = @get key
        )
        return obj
        
    utf_prefs.getDefaults = () ->
        obj = {}
        _.each(defaultPreferences, (definition, key) =>
            defaultValue = definition.os[brackets.platform].value if definition.os && definition.os[brackets.platform] 
            else defaultValue = definition.value
        )
        return obj

    utf_prefs.persist = (key, value) =>
        @set key, value
        do @save

    module.exports = utf_prefs