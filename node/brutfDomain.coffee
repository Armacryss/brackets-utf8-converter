do () ->
    'use strict'
    
    ##Node modules
    fs = require 'fs'
    iconv = require 'iconv-lite'
    chardet = require 'node-chardet'
    jschardet = require 'jschardet'
    
    ## Method to get files encoding. Dig allows to dig through sub-directories.
    cmdGetFilesEncoding = (dirPath, dig) ->
        dig = false if not dig?
        lsFiles = fs.readdirSync(dirPath)
        listFiles = []
        
        for filename in lsFiles
            if filename? and filename isnt '.DS_Store' and filename isnt /~$/
                filePath = dirPath + filename
                if not do fs.lstatSync(filePath).isDirectory
                    file = jschardet.detect fs.readFileSync(filePath)
                    file.name = filename
                    file.path = filePath
                    file.confidence *= 100
                    listFiles.push file
                else if dig
                    filePath += '/' if filePath isnt /\/$/
                    lsDiggedFiles = cmdGetFilesEncoding filePath, dig
                    for diggedFile in lsDiggedFiles.files
                        listFiles.push diggedFile
                
        return {directory: dirPath, files: listFiles}
    
    ## Convert file to UTF8.
    cmdConvertFileEncoding = (filePath)  ->
        file = fs.readFileSync filePath
        str = iconv.decode file, jschardet.detect(file).encoding
        str_enc = iconv.encode str, 'utf8'
        fileDir = filePath.substring 0, filePath.lastIndexOf('/') + 1
        fileName = filePath.substring filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.')
        fileExt = filePath.substring filePath.lastIndexOf('.')
        newFile = fileDir + fileName + '.utf8' + fileExt;
        
        fs.writeFileSync(newFile, str_enc);
        
        return newFile;
    
    ## Init - automatically called
    init = (DomainManager) ->
        domainName = 'bracketsUtfConverter'
        if not DomainManager.hasDomain domainName
            DomainManager.registerDomain(domainName, {major: 0, minor: 1});
        
        DomainManager.registerCommand domainName, 'getFilesEncoding', cmdGetFilesEncoding, false, 'Return a test value', [
            { name: 'path', type: 'string', description: 'File path' }
        ]
        
        DomainManager.registerCommand domainName, 'convertFileEncoding', cmdConvertFileEncoding, false, 'Create a UTF8 formated file', []
        return
    
    exports.init = init
    return