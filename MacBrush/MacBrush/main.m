//
//  main.m
//  MacBrush
//
//  Created by Nils Tekampe on 22.05.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//
#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>
#include <ncurses.h>
#import "GBCli.h"
#include "main.h"


bool simulate;
bool ignoreDotUnderscore;
bool ignoreDotAPDisk;
bool ignoreDSStore;
bool ignoreVolumeIcon;
bool verbose;
bool skipClean;
bool skipObservation;

int sumDotUnderscore=0;
int sumDotAPDisk=0;
int sumDSStore=0;
int sumVolumeIcon=0;

int DotUnderScoreX=0;
int DotUnderScoreY=0;
int DotAPDiskX=0;
int DotAPDiskY=0;
int DotDSStoreX=0;
int DotDSStoreY=0;
int DotVolumeIconX=0;
int DotVolumeIconY=0;




int main(int argc, const char * argv[]) {
    
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
    [factoryDefaults setBool:NO forKey:@"help"];
    
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
    
    
    if ([settings boolForKey:@"skip-observation"]){
        
        logger(@"usage: MacBrush [-f] [-v] targetDirectory", false);
        return 0;
    }
    
    
    NSArray *arguments = parser.arguments;
    
    CFArrayRef pathsToWatch = (__bridge CFArrayRef)arguments;
    
    if (arguments.count==0)
    {
        logger(@"Please provide at least one directory as an argument",false);
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
    
    if (!skipClean){
        for (NSString *entry in arguments) {
            cleanDirectory(entry);
        }
    }
    else
    {
        logger(@"Skipping to clean directories. Will continue with observation mode",false);
    }
    
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
            
            //printStatus(arguments);
            logger(@"Starting observation mode for the following directories:",false);
            
            for (NSString *entry in arguments) {
                logger(entry,false);
                
            }
            
            updateStat(true);
            
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


void updateStat(BOOL firstRun){
    
    if (firstRun){
        initscr();
        cbreak();
        noecho();
        nonl();
        
        logger(@"._ files removed so far",false );
        logger(@".APDisk files removed so far",false );
        logger(@".DS_Store removed so far",false );
        logger(@".VolumeIcon.icns removed so far",false );
        
        
        
    }
    else{
        
        
        
        
    }
}

void logger(NSString *message, bool verbose_only){
    
    if (!verbose_only){
        printf("%s\n", [message UTF8String]);
       // printf("%s", @"\n");

    }
    
    
    else if (verbose_only){
        if(verbose){
            NSLog(@"%@", message);
        }
        
    }
    
}

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


int processFile(NSString* file){
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString* pattern=@"";
    
    //First we look for ´._ files
    
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
                        }
                        else  {
                            logger(@"Error removing file",true);
                        }
                        return 1;
                    }
                }
            }
        }
        
    }
    
    if (!ignoreDotAPDisk){
        
        pattern=@".apdisk";
        
        if ([file rangeOfString:pattern].location != NSNotFound) {
            
            logger([NSString stringWithFormat:@"%@%@", @"Found the following .apdisk file:" , file],true);
            
            if (!simulate){
                
                if ([manager removeItemAtPath:file error:&error])
                {
                    logger(@"Sucesfully removed file",true);
                    sumDotAPDisk++;
                }
                else  {
                    logger(@"Error removing file",true);
                }
                return 2;
            }
        }
    }
    
    if (!ignoreDSStore){
        
        pattern=@".DS_Store";
        
        if ([file rangeOfString:pattern].location != NSNotFound) {
            
            logger([NSString stringWithFormat:@"%@%@", @"Found the following .DS_Store file:" , file],true);
            
            if (!simulate){
                
                if ([manager removeItemAtPath:file error:&error])
                {
                    logger(@"Sucesfully removed file",true);
                    sumDSStore++;
                }
                else  {
                    logger(@"Error removing file",true);
                }
                return 3;
            }
        }
    }
    
    if (!ignoreDSStore){
        
        pattern=@".VolumeIcon.icns";
        
        if ([file rangeOfString:pattern].location != NSNotFound) {
            
            logger([NSString stringWithFormat:@"%@%@", @"Found the following .VolumeIcon.icns file:" , file],true);
            
            if (!simulate){
                
                if ([manager removeItemAtPath:file error:&error])
                {
                    logger(@"Sucesfully removed file",true);
                    sumVolumeIcon++;
                }
                else  {
                    logger(@"Error removing file",true);
                }
                return 4;
            }
        }
    }
    
    return 0;
}

void cleanDirectory(NSString *directory)
{
    logger([NSString stringWithFormat:@"%@%@", @"Starting to clean directory :" , directory],false);
    resetCounter();
    
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

void resetCounter(){
    sumDotAPDisk=0;
    sumDotUnderscore=0;
    sumDSStore=0;
    sumVolumeIcon=0;
    
}

