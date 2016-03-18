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

CGEventRef
myCGEventCallback(CGEventTapProxy proxy, CGEventType type,
                  CGEventRef event, void *refcon)
{
    // Paranoid sanity check.
    if ((type != kCGEventKeyDown) && (type != kCGEventKeyUp))
        return event;
    
    // The incoming keycode.
    CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(
                                                               event, kCGKeyboardEventKeycode);
    
    // Swap 'a' (keycode=0) and 'z' (keycode=6).
    if (keycode == (CGKeyCode)0)
        keycode = (CGKeyCode)6;
    else if (keycode == (CGKeyCode)6)
        keycode = (CGKeyCode)0;
    
    // Set the modified keycode field in the event.
    CGEventSetIntegerValueField(
                                event, kCGKeyboardEventKeycode, (int64_t)keycode);
    
    // We must return the event for it to be useful.
    return event;
}


bool isFile(NSString *file){
    BOOL isDir = NO;
    if([[NSFileManager defaultManager]fileExistsAtPath:file isDirectory:&isDir] && isDir)
        return false;
    else
        return true;
}