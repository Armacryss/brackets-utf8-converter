// Generated by CoffeeScript 1.8.0
(function() {
  (function() {
    'use strict';
    var cmdConvertDirectory, cmdConvertFileEncoding, cmdGetFileEncoding, cmdGetFilesEncoding, fs, iconv, init, jschardet, path;
    fs = require('fs');
    iconv = require('iconv-lite');
    jschardet = require('jschardet');
    path = require('path');
    cmdGetFileEncoding = function(filePath) {
      var fileInfo;
      fileInfo = {};
      if (fs.existsSync(filePath)) {
        fileInfo = jschardet.detect(fs.readFileSync(filePath));
        fileInfo.name = path.basename(filePath);
        fileInfo.path = filePath;
        fileInfo.confidence *= 100;
        return fileInfo;
      }
      throw new Error('Error while getting file info. Invalid file path : ' + filePath);
    };
    cmdGetFilesEncoding = function(dirPath, dig) {
      var diggedFile, file, filePath, filename, listFiles, lsDiggedFiles, lsFiles, _i, _j, _len, _len1, _ref;
      if (dig == null) {
        dig = false;
      }
      lsFiles = fs.readdirSync(dirPath);
      listFiles = [];
      if (dirPath !== /\/$/) {
        dirPath += '/';
      }
      for (_i = 0, _len = lsFiles.length; _i < _len; _i++) {
        filename = lsFiles[_i];
        if ((filename != null) && filename !== '.DS_Store' && filename !== /~$/ && filename !== '.svn') {
          filePath = dirPath + filename;
          if (!fs.lstatSync(filePath).isDirectory()) {
            file = cmdGetFileEncoding(filePath);
            listFiles.push(file);
          } else if (dig) {
            if (filePath !== /\/$/) {
              filePath += '/';
            }
            lsDiggedFiles = cmdGetFilesEncoding(filePath, dig);
            _ref = lsDiggedFiles.files;
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              diggedFile = _ref[_j];
              listFiles.push(diggedFile);
            }
          }
        }
      }
      return {
        directory: dirPath,
        files: listFiles
      };
    };
    cmdConvertFileEncoding = function(filePath, fileDestination) {
      var file, fileDir, fileEncoding, fileExt, fileName, newFile, str, str_enc;
      file = fs.readFileSync(filePath);
      fileEncoding = jschardet.detect(file).encoding;
      if (fileEncoding == null) {
        return;
      }
      str = iconv.decode(file, jschardet.detect(file).encoding);
      str_enc = iconv.encode(str, 'utf8');
      fileExt = path.extname(filePath);
      fileName = path.basename(filePath, fileExt);
      if (fileDestination == null) {
        fileDir = path.dirname(filePath);
        if (fileDir !== /\/$/) {
          fileDir += '/';
        }
        newFile = fileDir + fileName + '.utf8' + fileExt;
      } else {
        newFile = fileDestination + fileName + fileExt;
      }
      fs.writeFileSync(newFile, str_enc);
      return newFile;
    };
    cmdConvertDirectory = function(dirPath, dig, isDigging) {
      var diggedFile, file, filePath, filename, folderDestination, listFiles, lsDiggedFiles, lsFiles, newDirectory, subFile, subItem, tabSubFile, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref;
      if (dig == null) {
        dig = false;
      }
      if (isDigging == null) {
        isDigging = false;
      }
      lsFiles = fs.readdirSync(dirPath);
      listFiles = [];
      for (_i = 0, _len = lsFiles.length; _i < _len; _i++) {
        filename = lsFiles[_i];
        if ((filename != null) && filename !== '.DS_Store' && filename !== /~$/ && filename !== '.svn') {
          filePath = dirPath + filename;
          if (!fs.lstatSync(filePath).isDirectory()) {
            file = cmdGetFileEncoding(filePath);
            listFiles.push(file);
          } else if (dig) {
            if (filePath !== /\/$/) {
              filePath += '/';
            }
            lsDiggedFiles = cmdConvertDirectory(filePath, dig, true);
            _ref = lsDiggedFiles.files;
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              diggedFile = _ref[_j];
              listFiles.push(diggedFile);
            }
          }
        }
      }
      if (!isDigging && listFiles.length > 0) {
        newDirectory = dirPath.substring(0, dirPath.lastIndexOf('/'));
        newDirectory += '.utf8/';
        if (!fs.existsSync(newDirectory)) {
          fs.mkdirSync(newDirectory);
        }
        for (_k = 0, _len2 = listFiles.length; _k < _len2; _k++) {
          file = listFiles[_k];
          subFile = file.path.replace(dirPath, "");
          folderDestination = newDirectory;
          tabSubFile = path.dirname(subFile).split('/');
          for (_l = 0, _len3 = tabSubFile.length; _l < _len3; _l++) {
            subItem = tabSubFile[_l];
            folderDestination += subItem + '/';
            if (!fs.existsSync(folderDestination)) {
              fs.mkdirSync(folderDestination);
            }
          }
          cmdConvertFileEncoding(file.path, folderDestination);
        }
      }
      return {
        files: listFiles
      };
    };
    init = function(DomainManager) {
      var domainName;
      domainName = 'bracketsUtfConverter';
      if (!DomainManager.hasDomain(domainName)) {
        DomainManager.registerDomain(domainName, {
          major: 0,
          minor: 1
        });
      }
      DomainManager.registerCommand(domainName, 'getFileEncoding', cmdGetFileEncoding, false, 'Return encoding file info', []);
      DomainManager.registerCommand(domainName, 'getFilesEncoding', cmdGetFilesEncoding, false, 'Return list of files with encoding', [
        {
          name: 'path',
          type: 'string',
          description: 'File path'
        }, {
          name: 'dig',
          type: 'boolean',
          description: 'allow digging through subfolders'
        }
      ]);
      DomainManager.registerCommand(domainName, 'convertDirectory', cmdConvertDirectory, false, 'Convert whole directories', [
        {
          name: 'path',
          type: 'string',
          description: 'File path'
        }, {
          name: 'dig',
          type: 'boolean',
          description: 'allow digging through subfolders'
        }
      ]);
      DomainManager.registerCommand(domainName, 'convertFileEncoding', cmdConvertFileEncoding, false, 'Create a UTF8 formated file', []);
    };
    exports.init = init;
  })();

}).call(this);
