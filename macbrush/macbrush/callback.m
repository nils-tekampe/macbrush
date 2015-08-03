//
//  callback.m
//  macbrush
//
//  Created by Nils Tekampe on 02.08.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacBrush.h"

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
        
            
            MacBrush *brush = (__bridge MacBrush *)clientCallBackInfo;
            [brush processFile:file];
        
            
        }
    }
    
}

bool isFile(NSString *file){
    BOOL isDir = NO;
    if([[NSFileManager defaultManager]fileExistsAtPath:file isDirectory:&isDir] && isDir)
        return false;
    else
        return true;
}