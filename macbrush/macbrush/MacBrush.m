//
//  MacBrush.m
//  macbrush
//
//  Created by Nils Tekampe on 01.08.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#import "MacBrush.h"
#import "PatternMatchingString.h"

@implementation MacBrush

- (id) initWithValue:(bool)_ignore_dot_underscore:(bool)_ignore_apdisk:(bool)_ignore_dsstore:(bool)_ignore_volumeicon:(bool)_simulate:(bool)_verbose:(NSArray*) _pathesToWatch {
    self = [self init];
    if (self) {
        ignore_dot_underscore = _ignore_dot_underscore;
        ignore_apdisk=_ignore_apdisk;
        ignore_dsstore=_ignore_dsstore;
        ignore_volumeicon=_ignore_volumeicon;
        simulate=_simulate;
        verbose=_verbose;
        pathsToWatch = (__bridge CFArrayRef)_pathesToWatch;
 
        //********************************************************
        //Building an array for match patterns
        //********************************************************
        
        
        patternAPDisk = [[PatternMatchingString alloc] init];
        patternAPDisk.pattern=@".apdisk";
        patternAPDisk.matchCount=0;
        patternAPDisk.ignore=ignore_apdisk;
        
        patternDSStore = [[PatternMatchingString alloc] init];
        patternDSStore.pattern=@".DS_Store";
        patternDSStore.matchCount=0;
        patternDSStore.ignore=ignore_dsstore;
        
        patternVolumeIcon = [[PatternMatchingString alloc] init];
        patternVolumeIcon.pattern=@".VolumeIcon.icns";
        patternVolumeIcon.matchCount=0;
        patternVolumeIcon.ignore=ignore_volumeicon;
        
        
        patternMatchingArray = [NSArray arrayWithObjects:patternAPDisk,patternDSStore,patternVolumeIcon,nil];
        
        sum_dotunderscore=0;

        
    }
    return self;
}

/**
 Function for logging/user interaction via commandline
 Will output text to stdout
 @param *message The message to print
 @param verbose_only If set to true, the message will only be printed if --verbose==true
 */
-(void) logger:(NSString*)message:(bool)verbose_only
{
    int a;
    a=5;
    
    
    if (!verbose_only){
        //These messages will have to be printed in any way. However, the way of printing depend on
        //--verbose
        
        if (verbose)
            NSLog(@"%@", message);
        else
            printf("%s\n", [message UTF8String]);
    }
    
    
    else if (verbose_only){
        //These messages will only be printed of --verbose=true
        if(verbose){
            NSLog(@"%@", message);
        }
        
    }
    
    
}

/**
 This function processes a complete directory. It lists all the files and subfolder of the dir and
 calls processFile(..) for each of the files/folders in the directory.
 @param *directory NSString pointing to the directory to be processesd.
 */
//Todo: function could use some error handling
-(void) cleanDirectory:(NSString*) directory
{
    logger([NSString stringWithFormat:@"%@%@", @"Starting to clean directory :" , directory],false);
    
    //reset statistics
    for(PatternMatchingString *pattern in patternMatchingArray)
    {
        pattern.matchCount=0;
    }
    
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:directory];
    
    
    for (NSString *file in directoryEnumerator) {
        NSString *filename=file;
        filename= [directory stringByAppendingPathComponent:file];
        processFile(filename);
    }
    
    
    logger([NSString stringWithFormat:@"%@%@", @"Finished cleaning directory :" , directory],false);
    
    
    for(PatternMatchingString *pattern in patternMatchingArray)
    {
        
        logger([NSString stringWithFormat:@"%d%@%@%@",(int)pattern.matchCount, @" " ,pattern.pattern, @" files have been removed"],false);
        
    }
}


/**
 This function processes a file/folder and determines whether it should be removed. If the file has been identified for removal, the function also tries to remove the file.
 @param file The file to be processed
 @returns true if the file has been removed sucesfully Returns false if the file has not been identified to be removed or could not be removed (e.g. due to a lack of permissions.
 */
-(bool) processFile:(NSString*) file
{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString* pattern=@"";
    
    
    ///First we look for ´._ files
    ///._ files will only be removed if a corresponding base file is existing
    //Example: _.test.txt will be removed if a file name test.txt is existing in the same folder.
    
    if ([file rangeOfString:pattern].location == NSNotFound) {
        
        //let's build the name of the potentially corresponding file
        NSString* theFileName = file.lastPathComponent;
        NSString *path = file.stringByDeletingLastPathComponent;
        NSString *potentialTmpFile=[NSString stringWithFormat:@"%@/%@%@", path,@"._",theFileName];
        
        
        if([[NSFileManager defaultManager] fileExistsAtPath:potentialTmpFile])
        {
            if (isFile(potentialTmpFile)){
                
                logger([NSString stringWithFormat:@"%@%@", @"Found the following ._ file:" , potentialTmpFile],true);
                
                if (!simulate && !ignore_dot_underscore){
                    
                    
                    if ([manager removeItemAtPath:potentialTmpFile error:&error])
                    {
                        logger(@"Sucesfully removed file",true);
                        sum_dotunderscore++;
                        
                        return true;
                    }
                    else  {
                        logger(@"Error removing file",true);
                        return false;
                    }
                }
            }
        }
    }
    
    ///Now looking for the other patterns in a loop
    
    for(PatternMatchingString *pattern in patternMatchingArray)
    {
        if ([file rangeOfString:pattern.pattern].location != NSNotFound) {
            
            logger([NSString stringWithFormat:@"%@%@", @"Found the following file:" , file],true);
            
            if (!simulate && !pattern.ignore){
                if ([manager removeItemAtPath:file error:&error])
                {
                    logger(@"Sucesfully removed file",true);
                    pattern.matchCount++;
                    return true;
                }
                else  {
                    logger(@"Error removing file",true);
                    return false;
                }
                
            }
            
        }
    }
    return false;
}



+(bool) isFile:(NSString*)file{
    BOOL isDir = NO;
    if([[NSFileManager defaultManager]fileExistsAtPath:file isDirectory:&isDir] && isDir)
        return false;
    else
        return true;
}



@end

/**
 Callback function that is called if a change to a files in one of the observed folders has been detected
 */
void mycallback2(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[])
{
    int i;
    char **paths = eventPaths;
    
    for (i=0; i<numEvents; i++) {
        if (!(eventFlags[i]&kFSEventStreamEventFlagItemRemoved)){
            NSString* file = [NSString stringWithCString:paths[i] encoding:NSASCIIStringEncoding];
            processFile(file);}
    }
    
}


