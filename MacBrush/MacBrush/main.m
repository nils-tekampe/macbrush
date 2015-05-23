//
//  main.m
//  MacBrush
//
//  Created by Nils Tekampe on 22.05.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//
#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>
#import "GBCli.h"
#include "main.h"


bool simulate;
bool ignoreDotUnderscore;
bool ignoreDotAPDisk;
bool ignoreDSStore;
bool ignoreVolumeIcon;
bool verbose;

int sumDotUnderscore=0;
int sumDotAPDisk=0;
int sumDSStore=0;
int sumVolumeIcon=0;


int main(int argc, const char * argv[]) {

    
    NSLog(@"Starting to watch ");
    // Create settings stack.
    GBSettings *factoryDefaults = [GBSettings settingsWithName:@"Factory" parent:nil];
    [factoryDefaults setBool:NO forKey:@"ignore-dot-underscore"];
    [factoryDefaults setBool:NO forKey:@"ignore-apdisk"];
    [factoryDefaults setBool:NO forKey:@"ignore-dsstore"];
    [factoryDefaults setBool:NO forKey:@"ignore-volumeicon"];
    [factoryDefaults setBool:NO forKey:@"simulate"];
    [factoryDefaults setBool:NO forKey:@"verbose"];
    
    [factoryDefaults setInteger:12 forKey:@"optionb"];
    GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:factoryDefaults];
    
    // Create parser and register all options.
    GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
    [parser registerOption:@"ignore-dot-underscore" shortcut:'d' requirement:GBValueNone];
    [parser registerOption:@"ignore-apdisk" shortcut:'a' requirement:GBValueNone];
    [parser registerOption:@"ignore-dsstore" shortcut:'o' requirement:GBValueNone];
    [parser registerOption:@"ignore-volumeicon" shortcut:'v' requirement:GBValueNone];
    [parser registerOption:@"simulate" shortcut:'s' requirement:GBValueNone];
    [parser registerOption:@"verbose" shortcut:'v' requirement:GBValueNone];
    
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
    
    NSArray *arguments = parser.arguments;
    
    CFArrayRef pathsToWatch = (__bridge CFArrayRef)arguments;
    
    if (arguments.count==0)
    {
        logger(@"Please provide at least one directory as an argument",false);
        return 1;
        
    }
    
    //Check for each argument that the folder is really existing
    
    for (NSString *entry in arguments) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
       if (![fileManager fileExistsAtPath:entry])
       {
            logger([NSString stringWithFormat:@"%@%@" , entry,@" cannot be found. Please only specify folders that are existing."],false);
           return 1;
       }
    }
    
    
    for (NSString *entry in arguments) {
        cleanDirectory(entry);
    }
    
    
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
    logger(@"Starting observation mode now. Please press Ctrl+C to interrupt",false);
    
    CFRunLoopRun();
    return 0;
}


void logger(NSString *message, bool verbose_only){
    
    if (!verbose_only){
        NSLog(@"%@", message);
        
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

