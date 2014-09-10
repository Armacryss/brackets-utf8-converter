/* jslint vars: true, plusplus: true, devel: true, nomen: true, regexp: true, indent: 4, maxerr: 50 */
/* global define, $, brackets */

(function () {
    'use strict';
    
    var fs = require('fs'),
        iconv = require('iconv-lite'),
        chardet = require('node-chardet'),
        jschardet = require('jschardet');
    
    function cmdGetFilesEncoding(dirPath) {
        var afiles = fs.readdirSync(dirPath),
            listFiles = [],
            filePath,
            file,
            i;
        
        for (i = 0; i < afiles.length; i++) {
            if (afiles[i] !== '.DS_Store') {
                filePath = dirPath + afiles[i];
                if (!fs.lstatSync(filePath).isDirectory()) {
                    file = jschardet.detect(fs.readFileSync(filePath));
                
                    file.name = afiles[i];
                    file.path = filePath;
                    file.confidence = file.confidence * 100;
                    
                    listFiles.push(file);
                }
            }
        }
        
        console.log(listFiles);
        return {files: listFiles};
    }
    
    function cmdConvertFileEncoding(filePath) {
        var file = fs.readFileSync(filePath),
            str = iconv.decode(file, jschardet.detect(file).encoding),
            str_enc = iconv.encode(str, 'utf8'),
            fileDir = filePath.substring(0, filePath.lastIndexOf('/') + 1),
            fileName = filePath.substring(filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.')),
            fileExt = filePath.substring(filePath.lastIndexOf('.')),
            newFile = fileDir + fileName + '-AzEnc' + fileExt;
        
        fs.writeFileSync(newFile, str_enc);
        
        return newFile;
    }
    
    function init(DomainManager) {
        if (!DomainManager.hasDomain('azenc')) {
            DomainManager.registerDomain('azenc', {major: 0, minor: 1});
        }
        
        DomainManager.registerCommand(
            'azenc', // domain name
            'getFilesEncoding', // command name
            cmdGetFilesEncoding, // command handler
            false, // this command is synchronous
            'Retorna um valor de teste',
            [{ // parameters
                name: 'path',
                type: 'string',
                description: 'File path'
            }]
        );
        
        DomainManager.registerCommand(
            'azenc',
            'convertFileEncoding',
            cmdConvertFileEncoding,
            false,
            'Cria um novo arquivo em utf-8',
            []
        );
    }
    
    exports.init = init;
}());