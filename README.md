# McBrush
This programm cleans a directory and all its subdirectories from a set of hidden files that OS X creates and enters an observation mode afterwards. Within the observation mode, each hidden file that is created by OS X is directly deleted after it has been create by the OS.
The programm is of specific use for folders which are shared between OS X and other Operating Systems (e.g. via Dropbox).

**This program is currently in alpha state. Please use it with care!**

**It should be noted that OSX usually creates the temporary files that are removed by the program for a certain reason. Please only use this program if you know what you are doing and if you are sure that no important information will get lost.**

#Installation
Installation is pretty simple and straightforward. Clone this repository or download as an archive. Open the XCode project and compile. As an alternative you may use
```bash
xcodebuild
```
from the command line tools to compile (Should work without any furhter options. 
**A brew formula is planned to be distributed soon.**

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
| ------------- | ------------------------- |-----------------|
| -d|--ignore-dot-underscore  | Do not remove ._ files |
| -a | --ignore-apdisk|Do not remove .APDisk files|
| -o | --ignore-dsstore|Do not remove .DS_Store files|
| -i | --ignore-volumeicon|Do not remove VolumeIcon.icns files|
| -s | --simluate|Do not remove any files at all. Should be used togehter with --verbose for reporting of identified files|
| -v | --verbose|Verbose reporting|
| -c | --skip-clean|Do not clean folders. Directly enter observation mode|
| -o | --skip-observation|Do not enter observation mode. Only clean folders once.|
| -h | --help|Print help message|


##BUGS
nothing known 

##Examples
Clean /home/Users/user1/test and enter observation mode afterwards.
```bash
macbrush /home/Users/user1/test
```
Clean /home/Users/user1/test and /home/Users/user1/test2 and enter observation mode afterwards.
```bash
macbrush /home/Users/user1/test /home/Users/user1/test2
```
Clean /home/Users/user1/test only. No observation mode.
```bash
macbrush --skip-observation /home/Users/user1/test
```
Simulate cleaning /home/Users/user1/test and use verbose reporting. 
```bash
macbrush --verbose --simulate /home/Users/user1/test
```

##AUTHOR
nils@tekampe.org

SEE ALSO
-

