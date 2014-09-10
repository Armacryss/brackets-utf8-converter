/*jslint vars: true, plusplus: true, devel: true, nomen: true, regexp: true, indent: 4, maxerr: 50 */
/*global define, $, brackets */

define(function (require, exports, module) {
    'use strict';
    
    var AppInit = brackets.getModule('utils/AppInit'),
        Menus = brackets.getModule('command/Menus'),
        CommandManager = brackets.getModule('command/CommandManager'),
        ProjectManager = brackets.getModule('project/ProjectManager'),
        FileSystem = brackets.getModule('filesystem/FileSystem'),
        DocumentManager = brackets.getModule('document/DocumentManager'),
        ExtensionUtils = brackets.getModule('utils/ExtensionUtils'),
        NodeConnection = brackets.getModule('utils/NodeConnection'),
        PanelManager = brackets.getModule('view/PanelManager'),
        Dialogs = brackets.getModule("widgets/Dialogs");
        
    // Mustache templates
    var azEncPanelTemplate = require('text!html/panel.html'),
        azEncRowTemplate = require('text!html/rows.html');
    
    // Setting var for extension
    var files = [],
        $azPanel;
    
    var nodeConnection, azBkPanel;
    
    function chain() {
        var functions = Array.prototype.slice.call(arguments, 0);
        
        if (functions.length > 0) {
            var firstFunction = functions.shift();
            var firstPromise = firstFunction.call();
            
            firstPromise.done(function () {
                chain.apply(null, functions);
            });
        }
    }
    
    function convertFile() {
        var $this = $(this),
            convertPromise;
        
        //$this.html('Verifying...');
        
        // var readPromise = DocumentManager.getDocumentForPath($this.data('file'));
        
        // readPromise.fail(function() {
            convertPromise = nodeConnection.domains.azenc.convertFileEncoding($this.data('file'));
            
            convertPromise.fail(function () {
                console.log('[Az-Enc] failed to convert the file');
            });
            
            convertPromise.done(function(newFilePath) {
                console.log('[Az-Enc] converted');
                $this.html('Converted');
            });
        // });
        
        //readPromise.done(function() {
        //    $this.html('Is ready to use');
        //});
    }
    
    function showRows(files) {
        var rowsHtml = Mustache.render(azEncRowTemplate, {'arquivos': files});
        $azPanel.find('.rows-container').empty().append(rowsHtml);
    }
    
    function showPanel(files) {
        azBkPanel.show();
        showRows(files);
    }
    
    function detectEncoding() {
        var encodingPromise = nodeConnection.domains.azenc.getFilesEncoding(ProjectManager.getSelectedItem()._path.toString()),
            files = [],
            readPromise,
            i;
        
        encodingPromise.fail(function (err) {
            console.error('[Az-Enc] failed to detect encoding of files', err);
        });
        
        encodingPromise.done(function (data) {
            showPanel(data.files);
        });
        
        return encodingPromise;
    }
    
    // Function to run when the menu item is clicked
    function handleDetectEncoding() {
        console.log(ProjectManager.getSelectedItem());
        if (ProjectManager.getSelectedItem()._isDirectory) {
            chain(detectEncoding);
        } else {
            Dialogs.showModalDialog('', 'Az-Enc', 'You must select a <b>directory</b> for detect encodings.<br />This extension doesn\'t work with a single files.');
        }
    }
    
    AppInit.appReady(function() {
        nodeConnection = new NodeConnection();
        
        function connect() {
            var connectionPromise = nodeConnection.connect(true);
            
            connectionPromise.fail(function () {
                console.error('[Az-Enc] failed to connect to node');
            });
            
            return connectionPromise;
        }
        
        function loadAzEncDomain() {
            var path = ExtensionUtils.getModulePath(module, 'node/EncDomain');
            var loadPromise = nodeConnection.loadDomains([path], true);
            
            loadPromise.fail(function () {
                console.log('[Az-Enc] failed to load domain');
            });
            
            loadPromise.done(function () {
                console.log('[Az-Enc] loaded');
            });
            
            return loadPromise;
        }
        
        chain(connect, loadAzEncDomain);
        
        ExtensionUtils.loadStyleSheet(module, "css/az.css");
    });
    
    
    var panelHtml = Mustache.render(azEncPanelTemplate, '');
    azBkPanel = PanelManager.createBottomPanel('azenc.encoding.listfiles', $(panelHtml), 200);
    $azPanel = $('#brackets-azenc');
    
    $azPanel
        .on('click', '.close', function () {
            azBkPanel.hide();
        })
        .on('click', '.btnConvert', convertFile);
    
    $(ProjectManager).on("beforeProjectClose", function () {
        azBkPanel.hide();
    });
    
    
    // First, register a command - a UI-less object associating an id to a handler
    var MY_COMMAND_ID = 'azenc.detectEncoding';   // package-style naming to avoid collisions
    CommandManager.register('Detect Encoding', MY_COMMAND_ID, handleDetectEncoding);

    // Then create a menu item bound to the command
    // The label of the menu item is the name we gave the command (see above)
    var menu = Menus.getContextMenu(Menus.ContextMenuIds.PROJECT_MENU);
    menu.addMenuItem(MY_COMMAND_ID);

    exports.handleDetectEncoding = handleDetectEncoding;
});