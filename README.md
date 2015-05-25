# McBrush
This programm cleans a directory and all its subdirectories from a set of hidden files that OS X creates and enters an observation mode afterwards. Within the observation mode, each hidden file that is created by OS X is directly deleted after it has been create by the OS.
The programm is of specific use for folders which are shared between OS X and other Operating Systems (e.g. via Dropbox).

#Installation
Installation is pretty simple and straightforward. Clone this repository or download as an archive. Then copy the file McBrush from the folder /binary to /usr/local/bin on your Mac; afterwards you need to set the execute permission on that file. As an alternative you can use the simple install.sh in the binary folder.
As an alternative you can use the following set of commands for installation:
```bash
wget https://github.com/nils-tekampe/MacBrush/blob/master/binary/MacBrush
cp ./MacBrush /usr/local/bin
chmod +x /usr/local/bin/MacBrush
```

#Manpage 
##NAME
MCBrush 

#SYNOPSIS
McBrush [options] [folder to watch|

##DESCRIPTION
This programm cleans a directory and all its subdirectories from a set of hidden files that OS X creates and enters an observation mode afterwards. Within the observation mode, each hidden file that is created by OS X is directly deleted after it has been create by the OS.
The programm is of specific use for folders which are shared between OS X and other Operating Systems (e.g. via Dropbox).

##OPTIONS
| Option | Long option |Description|
| ------------- | ------------- |-----------------|
| -d|--ignore-dot-underscore  | Do not remove ._ files |
| -a | --ignore-apdisk|Do not remove .APDisk files|
| -o | --ignore-dsstore|Do not remove .DS_Store files|
| -i | --ignore-volumeicon|Do not remove VolumeIcon.icns files|
| -s | --simluate|Do not remove any files at all. Should be used togehter with --verbose for reporting of identified files|
| -v | --verbose|Verbose reporting|
| -c | --skip-clean|Do not clean folders. Directly enter observation mode|
| -o | --skip-observation|Do not enter observation mode. Only clean folders once.|
| -h | --ehlp|Print help message|


##BUGS
nothing known 

##Examples

##AUTHOR
nils@tekampe.org

SEE ALSO
-

