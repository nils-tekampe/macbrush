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
#include "PatternMatchingString.h"
#import "MacBrush.h"

// I know that global variables are not the best style but for some purposes they are just the easiest way :-)

//variables as representatives for command line options
bool simulate;
bool ignoreDotUnderscore;
bool verbose;
bool skipClean;
bool skipObservation;

//Variables for ncurses
int col;
int row;

//variables for some statistics
int sumDotUnderscore=0;

NSArray *patternMatchingArray;

int main(int argc, char * argv[]) {
    
    //****************************************
    //Take care of options and arguments
    //****************************************
    
    col=-99;
    row=-99;
    
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
    [parser registerOption:@"help" shortcut:'h' requirement:GBValueNone];
    [parser registerOption:@"version" shortcut:'v' requirement:GBValueNone];
    [parser registerOption:@"ignore-dot-underscore" shortcut:'d' requirement:GBValueNone];
    [parser registerOption:@"ignore-apdisk" shortcut:'a' requirement:GBValueNone];
    [parser registerOption:@"ignore-dsstore" shortcut:'s' requirement:GBValueNone];
    [parser registerOption:@"ignore-volumeicon" shortcut:'i' requirement:GBValueNone];
    [parser registerOption:@"simulate" shortcut:'s' requirement:GBValueNone];
    [parser registerOption:@"verbose" shortcut:'V' requirement:GBValueNone];
    [parser registerOption:@"skip-clean" shortcut:'c' requirement:GBValueNone];
    [parser registerOption:@"skip-observation" shortcut:'o' requirement:GBValueNone];
    
    
    // Register settings and then parse command line
    [parser registerSettings:settings];
    [parser parseOptionsWithArguments:argv count:argc];
    
    
    // From here on, just use settings...
    ignoreDotUnderscore=[settings boolForKey:@"ignore-dot-underscore"];
    simulate=[settings boolForKey:@"ignore-dot-underscore"];
    verbose=[settings boolForKey:@"verbose"];
    skipClean=[settings boolForKey:@"skip-clean"];
    skipObservation=[settings boolForKey:@"skip-observation"];
    
    //***********************************************
    //Do some basic checks with arguments and options
    //***********************************************
    
    if ([settings boolForKey:@"help"]){
        logger(INFO, false);
        logger(USAGE, false);
        return 0;
    }
    
    if ([settings boolForKey:@"version"]){
        logger(VERSION, false);
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
    
    
    MacBrush *brusher = [[MacBrush alloc] initWithValue:[settings boolForKey:@"ignore-dot-underscore"] :[settings boolForKey:@"ignore-apdisk"]:[settings boolForKey:@"ignore-dsstore"] :[settings boolForKey:@"ignore-volumeicon"] :[settings boolForKey:@"simulate"] :[settings boolForKey:@"verbose"]:arguments];
    
    
    //********************************************************
    //Starting main functionality. 1st step: Clean directories
    //********************************************************
    
    if (!skipClean){
        [brusher clean];
        
    }
    else
    {
        logger(@"Skipping to clean directories. Will continue with observation mode",false);
    }
    
    //**********************************************************
    //Starting main functionality. 2nd step: observe directories
    //**********************************************************
    if (!skipObservation){
        
        [brusher start];
        
     //   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(printSummary) userInfo:nil repeats:YES];
        
        CFRunLoopRun();
        
    }
    else{
        
        logger(@"Skipping observation mode.",false);
    }
    
    logger(@"Tesdsfgsdfgsdfgsdfgsdgt",false);
    char ch;
    
    while( (ch = getch()) != @"z")
        
        ;
    
    return 0;
    
    
}

void startFunktionFuerNils(MacBrush *_brush){

    [_brush start];

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






