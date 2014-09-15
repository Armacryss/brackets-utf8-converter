UTF8 Converter
=========

Brackets extension for encoding files to UTF8 format

(Short) Introduction
-----------------
First and foremost, this project is a fork of [Az-Encode](https://github.com/Azakur4/Az-Encode) written by [Jimmy Brian Anamaria Torres](https://github.com/Azakur4), so, many thanks to him !  
At first, I just wanted to update one of the node package, but I need more features, so I decided to extend the original project in order to add what I need, and maybe what others need.  
It'll be deprecated once the Brackets' team add support to other file format than UTF8 but... well, who cares ? and since [Brackets](https://github.com/adobe/brackets) is a great open-source text editor, it would be too bad to not use it because it can't open (*yet*) files that aren't encoded using UTF8.

HOW-TO
------------------
To install this extension (still under development, you'll have to bear with me), just copy the whole project folder to Brackets extension folder.  
You can access this folder from Brackets (Help > Show Extensions Folder).  
Next, you'll have to Restart Node from Brackets (Debug > Restart Node) and reload Brackets with extensions (Debug > Reload With Extensions ... or F5).

Once installed, you can right-click on a folder and :
- click "Detect Encoding".  
It'll navigate through the files (and subfolders - see "Missing features") and display a bottom panel with a list of files and a button to "Convert" each file to UTF8.  
Don't be afraid of losing any of your files, this extension creates a copy of the converted file with a ".utf8" tag added to it (before the extension name, of course).

- click "Convert to UTF8".
It'll convert a whole folder to UTF8 but creating a copy of it and converting everything in it (even subfolders if the settings allow it)

- click "Encoding Settings"
It'll give you a bit of control over the module, you can disable the ability to detect/convert subfolders, or remove the action "Convert to UTF8" if you don't want to do it by mistake.

Used packages
--------------------
Since this project uses some NodeJS packages, let's introduce them !
- The core of this extension is [iconv-lite](https://github.com/ashtuchkin/iconv-lite) which handles the conversion.
- [jschardet](https://github.com/aadsm/jschardet) is also used to provide some information about the encoding.
- [path](https://github.com/joyent/node) from nodejs main package

And... that's it !

Missing features
---------------
- [x] Split functions and modules to separate files
- [x] Switch to coffeescript (warning : Brackets will work with Javascript only)
- [x] Ability to dig through files
- [x] Add preference UI (option to dig [or not] into sub-folders, convert on the fly, ...)
- [ ] Change bottom panel interface (ie : group files by folders, ...)
- [x] Ability to convert whole folders (create a copy of that folder with an extension to the name)
- [x] Ability to detect encoding/convert a single file _(Brackets' error message prevent the use of such functionality on unreadable files... still exists just in case)_
- [ ] Add more comments to coffeescripts !

Other features that MAY be added (one day)
---------------------
- [ ] React to "UNSUPPORTED_ENCODING_ERR" to provide a way to suggest a conversion (I don't know if it's possible ... gotta check the API)
- [ ] Work ASYNC 
