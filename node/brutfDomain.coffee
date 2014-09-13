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
    cmdConvertFileEncoding = (filePath, fileDestination)  ->
        file = fs.readFileSync filePath
        str = iconv.decode file, jschardet.detect(file).encoding
        str_enc = iconv.encode str, 'utf8'
        
        fileName = filePath.substring filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.')
        fileExt = filePath.substring filePath.lastIndexOf('.')
            
        ## Build new file path
        if not fileDestination?
            fileDir = filePath.substring 0, filePath.lastIndexOf('/') + 1
            newFile = fileDir + fileName + '.utf8' + fileExt
        else
            newFile = fileDestination + fileName + fileExt
        
        fs.writeFileSync(newFile, str_enc);
        
        return newFile;
    
    ## Convert directory to UTF8
    cmdConvertDirectory = (dirPath, dig, isDigging) ->
        dig = false if not dig?
        isDigging = false if not isDigging?
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
                    lsDiggedFiles = cmdConvertDirectory filePath, dig, true
                    for diggedFile in lsDiggedFiles.files
                        listFiles.push diggedFile
                
        if not isDigging and listFiles.length > 0
            newDirectory = dirPath.substring 0, dirPath.lastIndexOf('/')
            newDirectory += '.utf8/'
            
            if not fs.existsSync newDirectory
                fs.mkdirSync newDirectory
                
            for file in listFiles
                subFile = file.path.replace dirPath, ""
                folderDestination = newDirectory
                
                ## We have to loop through subfolders in order to create the whole tree
                tabSubFile = subFile.split '/' 
                for subItem in tabSubFile
                    folderDestination += subItem + '/'
                    if not fs.existsSync folderDestination
                        fs.mkdirSync folderDestination
                
                cmdConvertFileEncoding file.path, folderDestination
        
        return { files: listFiles }
   
    
    ## Init - automatically called
    init = (DomainManager) ->
        domainName = 'bracketsUtfConverter'
        if not DomainManager.hasDomain domainName
            DomainManager.registerDomain(domainName, {major: 0, minor: 1});
        
        DomainManager.registerCommand domainName, 'getFilesEncoding', cmdGetFilesEncoding, false, 'Return list of files with encoding', [
            { name: 'path', type: 'string', description: 'File path' }
        ]

        DomainManager.registerCommand domainName, 'convertDirectory', cmdConvertDirectory, false, 'Convert whole directories', [
            { name: 'path', type: 'string', description: 'File path' },
            { name: 'dig', type: 'boolean', description: 'allow digging through subfolders'}
        ]

        DomainManager.registerCommand domainName, 'convertFileEncoding', cmdConvertFileEncoding, false, 'Create a UTF8 formated file', []
        return
    
    exports.init = init
    return