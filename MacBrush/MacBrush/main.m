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
bool verbose;







int main(int argc, const char * argv[]) {
    
    
    
    NSLog(@"Starting to watch ");
    // Create settings stack.
    GBSettings *factoryDefaults = [GBSettings settingsWithName:@"Factory" parent:nil];
    [factoryDefaults setBool:NO forKey:@"test-argument"];
    [factoryDefaults setBool:NO forKey:@"ignore-dot-underscore"];
    [factoryDefaults setBool:NO forKey:@"simulate"];
    [factoryDefaults setBool:NO forKey:@"verbose"];
    
    [factoryDefaults setInteger:12 forKey:@"optionb"];
    GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:factoryDefaults];
    
    // Create parser and register all options.
    GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
    [parser registerOption:@"test-argument" shortcut:'t' requirement:GBValueNone];
    [parser registerOption:@"ignore-dot-underscore" shortcut:'d' requirement:GBValueNone];
    [parser registerOption:@"simulate" shortcut:'s' requirement:GBValueNone];
    [parser registerOption:@"verbose" shortcut:'v' requirement:GBValueNone];
    
    // Register settings and then parse command line
    [parser registerSettings:settings];
    [parser parseOptionsWithArguments:argv count:argc];
    
    
    
    // From here on, just use settings...
    BOOL test=[settings boolForKey:@"test-argument"];
    ignoreDotUnderscore=[settings boolForKey:@"ignore-dot-underscore"];
    simulate=[settings boolForKey:@"ignore-dot-underscore"];
    verbose=[settings boolForKey:@"verbose"];
    
    NSArray *arguments = parser.arguments;
    
    
    
    
    
    
    //Fixme
    CFStringRef mypath = CFSTR("/Users/nils/test/");
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    void *callbackInfo = NULL; // could put stream-specific data here.
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 3.0; /* Latency in seconds */
    
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
    NSLog(@"Starting to watch ");
    
    
    CFRunLoopRun();
    NSLog(@"Starting to watch ");
    return 0;
}


void logger(NSString *message, int level){
    
    if (level==0){
        NSLog(@"%@", message);
        //return 0;
    }
    
    
    else if (level==1){
        if(verbose){
            NSLog(@"%@", message);
            //      return 0;
        }
        //else return 1;
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
    
    printf("Callback called\n");
    for (i=0; i<numEvents; i++) {
        
        //   NSString* file = [NSString stringWithFormat:@"%c" , paths[i]];
        NSString* file = [NSString stringWithCString:paths[i] encoding:NSASCIIStringEncoding];
        processFile(file);
        /* flags are unsigned long, IDs are uint64_t */
        // printf("Change %llu in %s, flags %lu\n", eventIds[i], paths[i], eventFlags[i]);
    }
    
    
}


int processFile(NSString* file){
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString* pattern=@"ttt";
    NSString* origFile=@"";
    
    NSRange match;
    
    
    //First we look for ´._ files
    
    if (!ignoreDotUnderscore){
        
        pattern=@"._";
        
        if ([file rangeOfString:pattern].location != NSNotFound) {
            
            //let's build the name of the potentially corresponding file
            NSString* theFileName = file.lastPathComponent;
            NSString *firstThreeChar = [theFileName substringToIndex:2];
            NSString *cuttedFileName = [theFileName substringFromIndex:2];
            NSString *path = file.stringByDeletingLastPathComponent;
            NSString *potentialBaseFile=[NSString stringWithFormat:@"%@/%@", path,cuttedFileName];
            
            //check that it really starts with ._
            if (firstThreeChar==@"._")
            {
                bool testttt=[[NSFileManager defaultManager] fileExistsAtPath:potentialBaseFile ];
                
                if([[NSFileManager defaultManager] fileExistsAtPath:potentialBaseFile ])
                {
                    
                    logger([NSString stringWithFormat:@"%@%@", @"Found the following ._ file:" , file],1);
                    
                    
                    
                    if (!simulate)
                        
                        if ([manager removeItemAtPath:file error:&error])
                        {
                            if (verbose)  NSLog(@"Sucesfully removed file");
                        }
                        else  {
                            if (verbose)  NSLog(@"Error removing file");
                        }
                    return 1;
                }
            }
            
            
        }
        
        
        
        
    }
    return 0;
}

