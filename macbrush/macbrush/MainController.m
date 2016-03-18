//
//  MainController.m
//  macbrush
//
//  Created by Nils Tekampe on 18.03.16.
//  Copyright © 2016 Nils Tekampe. All rights reserved.
//

#import "MainController.h"
#include <ApplicationServices/ApplicationServices.h>
#import "callback.h"

@implementation MainController


- (void) setup
{
    
    
    
    //we need to register for keyboard events on the runloop
    CFMachPortRef      eventTap;
    CGEventMask        eventMask;
    CFRunLoopSourceRef runLoopSource;
    
    // Create an event tap. We are interested in key presses.
    eventMask = ((1 << kCGEventKeyDown) | (1 << kCGEventKeyUp));
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0,
                                eventMask, myCGEventCallback, NULL);
    if (!eventTap) {
        fprintf(stderr, "failed to create event tap\n");
        exit(1);
    }
    
    // Create a run loop source.
    runLoopSource = CFMachPortCreateRunLoopSource(
                                                  kCFAllocatorDefault, eventTap, 0);
    
    // Add to the current run loop.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource,
                       kCFRunLoopCommonModes);
    
    // Enable the event tap.
    CGEventTapEnable(eventTap, true);
    
}

/**
 Function for printing the summary during observation mode.
 Utilizes ncurses
 Only used if not in verbose mode
 */
- (void) printSummary:(NSTimer *)timer
{
    
    
    
//    if (col==-99)
//    {
//        initscr();
//        raw();
//        getyx(stdscr,row,col);
//        
//        
//    }
//    
//    mvprintw(row,col,"%d files have been removed", _sumDotUnderscore);
//    
//    
//    
}



@end
