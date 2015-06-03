//
//  main.m
//  macbrush
//
//  Created by Nils Tekampe on 22.05.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//
#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>
#include <ncurses.h>
#import "GBCli.h"
#include "main.h"

// I know that global variables are not the best style but for some purposes they are just the easiest way :-)

//variables as representatives for command line options
bool simulate;
bool ignoreDotUnderscore;
bool ignoreDotAPDisk;
bool ignoreDSStore;
bool ignoreVolumeIcon;
bool verbose;
bool skipClean;
bool skipObservation;

//variables for some statistics
int sumDotUnderscore=0;
int sumDotAPDisk=0;
int sumDSStore=0;
int sumVolumeIcon=0;


int main(int argc, const char * argv[]) {
    
    //****************************************
    //Take care of options and arguments
    //****************************************
    
    // Create settings stack.
    GBSettings *factoryDefaults = [GBSettings settingsWithName:@"Factory" parent:nil];
    [factoryDefaults setBool:NO forKey:@"ignore-dot-underscore"];
    [factoryDefaults setBool:NO forKey:@"ignore-apdisk"];
    [factoryDefaults setBool:NO forKey:@"ignore-dsstore"];
    [factoryDefaults setBool:NO forKey:@"ignore-volumeicon"];
    [factoryDefaults setBool:NO forKey:@"simulate"];
    [factoryDefaults setBool:NO forKey:@"verbose"];
    [factoryDefaults setBool:NO forKey:@"skip-clean"];
    [factoryDefaults setBool:NO forKey:@"skip-observation"];
    
    [factoryDefaults setInteger:12 forKey:@"optionb"];
    GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:factoryDefaults];
    
    // Create parser and register all options.
    GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
    [parser registerOption:@"ignore-dot-underscore" shortcut:'d' requirement:GBValueNone];
    [parser registerOption:@"ignore-apdisk" shortcut:'a' requirement:GBValueNone];
    [parser registerOption:@"ignore-dsstore" shortcut:'o' requirement:GBValueNone];
    [parser registerOption:@"ignore-volumeicon" shortcut:'i' requirement:GBValueNone];
    [parser registerOption:@"simulate" shortcut:'s' requirement:GBValueNone];
    [parser registerOption:@"verbose" shortcut:'v' requirement:GBValueNone];
    [parser registerOption:@"skip-clean" shortcut:'c' requirement:GBValueNone];
    [parser registerOption:@"skip-observation" shortcut:'o' requirement:GBValueNone];
    [parser registerOption:@"help" shortcut:'h' requirement:GBValueNone];
    
    // Register settings and then parse command line
    [parser registerSettings:settings];
    [parser parseOptionsWithArguments:argv count:argc];
    
    
    // From here on, just use settings...
    ignoreDotUnderscore=[settings boolForKey:@"ignore-dot-underscore"];
    ignoreDotAPDisk=[settings boolForKey:@"ignore-apdisk"];
    ignoreDSStore=[settings boolForKey:@"ignore-dsstore"];
    ignoreVolumeIcon=[settings boolForKey:@"ignore-volumeicon"];
    simulate=[settings boolForKey:@"ignore-dot-underscore"];
    verbose=[settings boolForKey:@"verbose"];
    skipClean=[settings boolForKey:@"skip-clean"];
    skipObservation=[settings boolForKey:@"skip-observation"];
    
    //***********************************************
    //Do some basic checks with arguments and options
    //***********************************************
    
    if ([settings boolForKey:@"help"]){
        
        logger(USAGE, false);
        return 0;
    }
    
    if ([settings boolForKey:@"version"]){
        
        logger(@"macbrush, Version 0.6", false);
        return 0;
    }

    
    
    NSArray *arguments = parser.arguments;
    
    CFArrayRef pathsToWatch = (__bridge CFArrayRef)arguments;
    
    if (arguments.count==0)
    {
        logger(USAGE,false);
        return 1;
        
    }
    
    //Check for each argument that the folder is really existing
    
    @try {
        for (NSString *entry in arguments) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:entry])
            {
                logger([NSString stringWithFormat:@"%@%@" , entry,@" cannot be found. Please only specify folders that are existing."],false);
                return 1;
            }
        }
        
    }
    @catch(NSException *e){
        logger(@"Error while checking the arguments. May be due to a lack of permissions? Will exit now",false);
        return 1;
        
    }
    
    //********************************************************
    //Starting main functionality. 1st step: Clean directories
    //********************************************************
    
    if (!skipClean){
        for (NSString *entry in arguments) {
            cleanDirectory(entry);
        }
    }
    else
    {
        logger(@"Skipping to clean directories. Will continue with observation mode",false);
    }
    
    //**********************************************************
    //Starting main functionality. 2nd step: observe directories
    //**********************************************************
    if (!skipObservation){
        
        @try{
            void *callbackInfo = NULL; // could put stream-specific data here.
            FSEventStreamRef stream;
            CFAbsoluteTime latency = 1.0; /* Latency in seconds */
            
            /* Create the stream, passing in a callback */
            stream = FSEventStreamCreate(NULL,
                                         &mycallback,
                                         callbackInfo,
                                         pathsToWatch,
                                         kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                         latency,
                                         kFSEventStreamCreateFlagFileEvents//kFSEventStreamCreateFlagNone /* Flags explained in reference */
                                         );
            
            /* Create the stream before calling this. */
            FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(),kCFRunLoopDefaultMode);
            FSEventStreamStart(stream);
            
            logger(@"Starting observation mode for the following directories:",false);
            
            for (NSString *entry in arguments) {
                logger(entry,false);
            }
            
            //When the loop runs, the program can only be exited via Ctrl+C
            logger(@"Please press Ctrl+C to end program",false);
            CFRunLoopRun();
        }
        @catch(NSException *e){
            logger(@"Error during observation mode. Will now exit",false);
            return 1;
        }
        return 0;
    }
    else{
        
        logger(@"Skipping observation mode.",false);
    }
    
}

/**
 Function for logging/user interaction via commandline
 Will output text to stdout
 @param *message The message to print
 @param verbose_only If set to true, the message will only be printed if --verbose==true
 */
void logger(NSString *message, bool verbose_only){
    
    
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
 Callback function that is called if a change to a files in one of the observed folders has been detected
 */
void mycallback(
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

/**
 This function processes a file/folder and determines whether it should be removed. If the file has been identified for removal, the function also tries to remove the file.
 @param file The file to be processed
 @returns true if the file has been removed sucesfully Returns false if the file has not been identified to be removed or could not be removed (e.g. due to a lack of permissions.
 */
bool processFile(NSString* file){
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString* pattern=@"";
    
    ///First we look for ´._ files
    ///._ files will only be removed if a corresponding base file is existing
    //Example: _.test.txt will be removed if a file name test.txt is existing in the same folder.
    
    if (!ignoreDotAPDisk){
        
        pattern=@"._";
        
        if ([file rangeOfString:pattern].location != NSNotFound) {
            
            //let's build the name of the potentially corresponding file
            NSString* theFileName = file.lastPathComponent;
            NSString *firstThreeChar = [theFileName substringToIndex:2];
            NSString *cuttedFileName = [theFileName substringFromIndex:2];
            NSString *path = file.stringByDeletingLastPathComponent;
            NSString *potentialBaseFile=[NSString stringWithFormat:@"%@/%@", path,cuttedFileName];
            
            //check that it really starts with ._
            if ([firstThreeChar isEqualToString:pattern])
            {
                
                if([[NSFileManager defaultManager] fileExistsAtPath:potentialBaseFile])
                {
                    
                    logger([NSString stringWithFormat:@"%@%@", @"Found the following ._ file:" , file],true);
                    
                    
                    if (!simulate){
                        
                        if ([manager removeItemAtPath:file error:&error])
                        {
                            logger(@"Sucesfully removed file",true);
                            sumDotUnderscore++;
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
        
    }
    
    ///Now looking for .APDisk files. They should be removed as long as the user did not choose the option
    ///to ignore these files
    
    if (!ignoreDotAPDisk){
        
        pattern=@".apdisk";
        
        if ([file rangeOfString:pattern].location != NSNotFound) {
            
            logger([NSString stringWithFormat:@"%@%@", @"Found the following .apdisk file:" , file],true);
            
            if (!simulate){
                
                if ([manager removeItemAtPath:file error:&error])
                {
                    logger(@"Sucesfully removed file",true);
                    sumDotAPDisk++;
                    return true;
                }
                else  {
                    logger(@"Error removing file",true);
                    return false;
                }
                
            }
        }
    }
    
    ///Now looking for .DS_Store files. They should be removed as long as the user did not choose the option
    ///to ignore these files
    
    if (!ignoreDSStore){
        
        pattern=@".DS_Store";
        
        if ([file rangeOfString:pattern].location != NSNotFound) {
            
            logger([NSString stringWithFormat:@"%@%@", @"Found the following .DS_Store file:" , file],true);
            
            if (!simulate){
                
                if ([manager removeItemAtPath:file error:&error])
                {
                    logger(@"Sucesfully removed file",true);
                    sumDSStore++;
                    return true;
                    return true;
                }
                else  {
                    logger(@"Error removing file",true);
                    return false;
                }
                
            }
        }
    }
    
    ///Now looking for .VolumeIcon.icns files. They should be removed as long as the user did not choose the
    ///otpion to ignore these files
    
    if (!ignoreDSStore){
        
        pattern=@".VolumeIcon.icns";
        
        if ([file rangeOfString:pattern].location != NSNotFound) {
            
            logger([NSString stringWithFormat:@"%@%@", @"Found the following .VolumeIcon.icns file:" , file],true);
            
            if (!simulate){
                
                if ([manager removeItemAtPath:file error:&error])
                {
                    logger(@"Sucesfully removed file",true);
                    sumVolumeIcon++;
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


/**
 This function processes a complete directory. It lists all the files and subfolder of the dir and
 calls processFile(..) for each of the files/folders in the directory.
 @param *directory NSString pointing to the directory to be processesd.
 */
//Todo: function could use some error handling
void cleanDirectory(NSString *directory)
{
    logger([NSString stringWithFormat:@"%@%@", @"Starting to clean directory :" , directory],false);
  
    //reset statistics
    sumDotAPDisk=0;
    sumDotUnderscore=0;
    sumDSStore=0;
    sumVolumeIcon=0;
    
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:directory];
    
    
    for (NSString *file in directoryEnumerator) {
        NSString *filename;
        filename=file;
        filename= [directory stringByAppendingPathComponent:file];
        processFile(filename);
    }
    logger([NSString stringWithFormat:@"%@%@", @"Finished cleaning directory :" , directory],false);
    logger([NSString stringWithFormat:@"%d%@",sumDotAPDisk, @" .AP_Disk files have been removed"],false);
    logger([NSString stringWithFormat:@"%d%@",sumDotUnderscore, @" ._ files have been removed"],false);
    logger([NSString stringWithFormat:@"%d%@",sumDSStore, @" .DS_Store files have been removed"],false);
    logger([NSString stringWithFormat:@"%d%@",sumVolumeIcon, @" .VolumeIcon.icns files have been removed"],false);
}




