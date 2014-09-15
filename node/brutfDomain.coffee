do () ->
    'use strict'
    
    ##Node modules
    fs = require 'fs'
    iconv = require 'iconv-lite'
    jschardet = require 'jschardet'
    path = require 'path'
    
    ##Get Encoding of a single file.
    cmdGetFileEncoding = (filePath) ->
        fileInfo = {}
        if fs.existsSync filePath
            fileInfo = jschardet.detect fs.readFileSync(filePath)
            fileInfo.name = path.basename filePath
            fileInfo.path = filePath
            fileInfo.confidence *= 100
            return fileInfo
        
        throw new Error 'Error while getting file info. Invalid file path : ' + filePath
    
    ## Get files encoding. Dig allows to dig through sub-directories.
    cmdGetFilesEncoding = (dirPath, dig) ->
        dig = false if not dig?
        lsFiles = fs.readdirSync(dirPath)
        listFiles = []
        
        ##Loop through the list of detected files
        for filename in lsFiles
            ## We ignore temp files (MAC & Linux)
            if filename? and filename isnt '.DS_Store' and filename isnt /~$/
                ## Building the file path
                filePath = dirPath + filename
                ## if it's a file, we have to read it
                if not do fs.lstatSync(filePath).isDirectory
                    file = cmdGetFileEncoding filePath
                    listFiles.push file
                ## otherwise, if we allow it from the preferences, we look into the subfolders
                else if dig
                    ## just to be sure, we had a slash in the end
                    filePath += '/' if filePath isnt /\/$/
                    ## recursive call
                    lsDiggedFiles = cmdGetFilesEncoding filePath, dig
                    ## Loop to add files (need to add lodash...)
                    for diggedFile in lsDiggedFiles.files
                        listFiles.push diggedFile
                
        return {directory: dirPath, files: listFiles}
    
    ## Convert file to UTF8.
    cmdConvertFileEncoding = (filePath, fileDestination)  ->
        file = fs.readFileSync filePath
        fileEncoding = jschardet.detect(file).encoding
        if not fileEncoding?
            return
        
        str = iconv.decode file, jschardet.detect(file).encoding
        str_enc = iconv.encode str, 'utf8'
        
        fileExt = path.extname filePath
        fileName = path.basename filePath, fileExt
            
        ## Build new file path
        if not fileDestination?
            fileDir = path.dirname filePath
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
                    file = cmdGetFileEncoding filePath
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
                tabSubFile = path.dirname(subFile).split('/')
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
        
        DomainManager.registerCommand domainName, 'getFileEncoding', cmdGetFileEncoding, false, 'Return encoding file info', []
            
        DomainManager.registerCommand domainName, 'getFilesEncoding', cmdGetFilesEncoding, false, 'Return list of files with encoding', [
            { name: 'path', type: 'string', description: 'File path' },
            { name: 'dig', type: 'boolean', description: 'allow digging through subfolders'}
        ]

        DomainManager.registerCommand domainName, 'convertDirectory', cmdConvertDirectory, false, 'Convert whole directories', [
            { name: 'path', type: 'string', description: 'File path' },
            { name: 'dig', type: 'boolean', description: 'allow digging through subfolders'}
        ]

        DomainManager.registerCommand domainName, 'convertFileEncoding', cmdConvertFileEncoding, false, 'Create a UTF8 formated file', []

        return
    
    exports.init = init
    return