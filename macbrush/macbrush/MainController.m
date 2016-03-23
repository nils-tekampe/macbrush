//
//  MainController.m
//  macbrush
//
//  Created by Nils Tekampe on 18.03.16.
//  Copyright © 2016 Nils Tekampe. All rights reserved.
//

#import "MainController.h"
//#include <ApplicationServices/ApplicationServices.h>
#import "callback.h"
#import "Main.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@implementation MainController


- (void) setup
{
    
    

    
  //  [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event){logger(@"Test keystroke",false); return event;}];
    
      //  NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(printSummary) userInfo:nil repeats:YES];
    

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
