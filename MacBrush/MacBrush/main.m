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

int sumDotUnderscore=0;


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

    CFArrayRef pathsToWatch = (__bridge CFArrayRef)arguments;
    
    
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
    NSLog(@"Starting to watch ");
    
    
    CFRunLoopRun();
    NSLog(@"Starting to watch ");
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
    
    printf("Callback called\n");
    for (i=0; i<numEvents; i++) {
                NSString* file = [NSString stringWithCString:paths[i] encoding:NSASCIIStringEncoding];
        processFile(file);

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
                    
                    logger([NSString stringWithFormat:@"%@%@", @"Found the following ._ file:" , file],true);
                    
                    
                    
                    if (!simulate)
                        
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
    return 0;
}

void cleanDirectory(NSString *directory)
{
    logger([NSString stringWithFormat:@"%@%@", @"Starting to clean directory :" , directory],true);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url=[NSURL URLWithString:[directory stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   // NSString *bundleURL = [NSString stringWithFormat:@"%@", directory];
   // NSURL *url = [NSURL URLWithString:[bundleURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
   // NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:url
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:0
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
    {
        if (error) {
            NSLog(@"[Error] %@ (%@)", error, url);
            return NO;
        }
        
        return YES;
    }];
    
    NSMutableArray *mutableFileURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        processFile([fileURL path]);
        
        NSString *myString = [fileURL path];
        NSString  *test22=@"dfd";
        
       // NSNumber *isDirectory;
       // [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
      //  if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
        //    [enumerator skipDescendants];
          //  continue;
        //}
        
        //if (![isDirectory boolValue]) {
          //  [mutableFileURLs addObject:fileURL];
        //}
    }
}

