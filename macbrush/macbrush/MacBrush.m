//
//  MacBrush.m
//  macbrush
//
//  Created by Nils Tekampe on 01.08.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#import "MacBrush.h"
#import "PatternMatchingString.h"
#import "callback.h"
#include <ncurses.h>

@implementation MacBrush

//variables for some statistics
int sumDotUnderscore;
int col=-99;
int row=0;
//int counterPrinter=0;
int offsetSummary=0;

- (id) initWithValue:(bool)_ignore_dot_underscore:(bool)_ignore_apdisk:(bool)_ignore_dsstore:(bool)_ignore_volumeicon:(bool)_simulate:(bool)_verbose:(NSArray*) _pathesToWatch {
    self = [self init];
    if (self) {
        ignore_dot_underscore = _ignore_dot_underscore;
        ignore_apdisk=_ignore_apdisk;
        ignore_dsstore=_ignore_dsstore;
        ignore_volumeicon=_ignore_volumeicon;
        simulate=_simulate;
        verbose=_verbose;
        pathsToWatch = (__bridge CFArrayRef)_pathesToWatch;
        
        
        //********************************************************
        //Building an array for match patterns
        //********************************************************
        
        
        patternAPDisk = [[PatternMatchingString alloc] init];
        patternAPDisk.pattern=@".apdisk";
        patternAPDisk.matchCount=0;
        patternAPDisk.cleanCount=0;
        patternAPDisk.ignore=ignore_apdisk;
        
        patternDSStore = [[PatternMatchingString alloc] init];
        patternDSStore.pattern=@".DS_Store";
        patternDSStore.matchCount=0;
        patternDSStore.cleanCount=0;
        patternDSStore.ignore=ignore_dsstore;
        
        patternVolumeIcon = [[PatternMatchingString alloc] init];
        patternVolumeIcon.pattern=@".VolumeIcon.icns";
        patternVolumeIcon.matchCount=0;
        patternVolumeIcon.cleanCount=0;
        patternVolumeIcon.ignore=ignore_volumeicon;
        
        
        patternMatchingArray = [NSArray arrayWithObjects:patternAPDisk,patternDSStore,patternVolumeIcon,nil];
        
        sum_dotunderscore=0;
        
        
        CFAbsoluteTime latency = 1.0; /* Latency in seconds */
        
        FSEventStreamContext context;
        context.info = (__bridge void *)(self);
        context.version = 0;
        context.retain = NULL;
        context.release = NULL;
        context.copyDescription = NULL;
        
        //********************************************************
        //Create the stream, passing in a callback
        //********************************************************
        
        stream = FSEventStreamCreate(NULL,
                                     &mycallback,
                                     &context, //<- This is used to keep track of the current object
                                     pathsToWatch,
                                     kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                     latency,
                                     kFSEventStreamCreateFlagFileEvents//kFSEventStreamCreateFlagNone /* Flags explained in reference */
                                     );
        
        /* Create the stream before calling this. */
        FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(),kCFRunLoopDefaultMode);
        
        
            
        [self printIntroduction];
    }
    return self;
}

/**
 Function for logging/user interaction via commandline
 Will output text to stdout
 @param *message The message to print
 @param verbose_only If set to true, the message will only be printed if --verbose==true
 */
-(void) logger:(NSString*)message:(bool)verbose_only
{
    
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
- (void) clean{
    
    NSArray *array = (__bridge NSArray*)pathsToWatch;
    
    for (NSString *entry in array) {
        [self cleanDirectory:entry];
    }
}



/**
 This function processes a complete directory. It lists all the files and subfolder of the dir and
 calls processFile(..) for each of the files/folders in the directory.
 @param *directory NSString pointing to the directory to be processesd.
 */
//Todo: function could use some error handling
-(void) cleanDirectory:(NSString*) directory
{
    //Inform the user that the directory will be cleaned
    if (verbose){
        logger([NSString stringWithFormat:@"%@%@", @"Starting to clean directory :" , directory],false);
        
        
    }
    else
    {
        
        [self curseLineWithoutLineFeed:@"Cleaning directory: "];
         printw([directory UTF8String]);
        row++;
        
         }
         
         //reset statistics
         for(PatternMatchingString *pattern in patternMatchingArray)
         {
             pattern.cleanCount=0;
         }
         
         NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:directory];
         
         
         for (NSString *file in directoryEnumerator) {
             NSString *filename=file;
             filename= [directory stringByAppendingPathComponent:file];
             [self processFile:filename];
         }
         
         //inform the user about the result
         //in case the output shall be verbose, we directly push it to stdout
         if (verbose){
             logger([NSString stringWithFormat:@"%@%@", @"Finished cleaning directory: " , directory],true);
             logger([NSString stringWithFormat:@"%d%@%@%@",(int)sum_dotunderscore, @" " ,@"._", @" files have been removed"],true);
             
             sum_dotunderscore=0; //Resetting coutner for observation mode
             
             
             for(PatternMatchingString *pattern in patternMatchingArray)
             {
                 
                 logger([NSString stringWithFormat:@"%d%@%@%@",(int)pattern.cleanCount, @" " ,pattern.pattern, @" files have been removed"],true);
                 pattern.cleanCount=0; //Restting counter for observation mode
             }
         }
         //otheriwse we use the curse summary
         else {
             
             printw(", now finished: ");
             //row++;
             [self curseLineWithoutLineFeed:[NSString stringWithFormat:@"%d ._ files have been removed", sum_dotunderscore]];
             [self curseLineWithTab:[NSString stringWithFormat:@"%d .apdisk files have been removed", ((PatternMatchingString*)[patternMatchingArray objectAtIndex: 0]).matchCount]];
             [self curseLineWithoutLineFeed:[NSString stringWithFormat:@"%d .DS_Store have been removed", ((PatternMatchingString*)[patternMatchingArray objectAtIndex: 1]).matchCount]];
             [self curseLineWithTab:[NSString stringWithFormat:@"%d .VolumeIcon.icns have been removed", ((PatternMatchingString*)[patternMatchingArray objectAtIndex: 2]).matchCount]];
             
             //Resetting coutner for observation mode
             sum_dotunderscore=0;
             ((PatternMatchingString*)[patternMatchingArray objectAtIndex: 0]).matchCount=0;
             ((PatternMatchingString*)[patternMatchingArray objectAtIndex: 1]).matchCount=0;
             ((PatternMatchingString*)[patternMatchingArray objectAtIndex: 2]).matchCount=0;
             
             
             ((PatternMatchingString*)[patternMatchingArray objectAtIndex: 0]).matchCount;
             
             //        for(PatternMatchingString *pattern in patternMatchingArray)
             //        {
             //            [self curseLine:[NSString stringWithFormat:@"%d%@%@%@",(int)pattern.cleanCount, @" " ,pattern.pattern, @" files have been removed"]];
             //            pattern.cleanCount=0; //Restting counter for observation mode
             //        }
             [self curseLine:@"------------------------------------------------------------------------------"];
             
         }
         
         offsetSummary=row;
         }
         
         
         /**
          This function processes a file/folder and determines whether it should be removed. If the file has been identified for removal, the function also tries to remove the file.
          @param file The file to be processed
          @returns true if the file has been removed sucesfully Returns false if the file has not been identified to be removed or could not be removed (e.g. due to a lack of permissions.
          */
         -(bool) processFile:(NSString*) file
         {
             
             NSFileManager *manager = [NSFileManager defaultManager];
             NSError *error = nil;
             
             NSString* pattern=@"._";
             
             logger([NSString stringWithFormat:@"%@%@", @" Processing file: " , file],true);
             
             ///First we look for ´._ files
             ///._ files will only be removed if a corresponding base file is existing
             //Example: _.test.txt will be removed if a file name test.txt is existing in the same folder.
             
             if ([file rangeOfString:pattern].location == NSNotFound) {
                 
                 //let's build the name of the potentially corresponding file
                 NSString* theFileName = file.lastPathComponent;
                 NSString *path = file.stringByDeletingLastPathComponent;
                 NSString *potentialTmpFile=[NSString stringWithFormat:@"%@/%@%@", path,@"._",theFileName];
                 
                 logger([NSString stringWithFormat:@"%@%@", @"Potential ._ file:" , potentialTmpFile],true);
                 
                 if([[NSFileManager defaultManager] fileExistsAtPath:potentialTmpFile])
                 {
                     if (isFile(potentialTmpFile)){
                         
                         logger([NSString stringWithFormat:@"%@%@", @"Found the following ._ file:" , potentialTmpFile],true);
                         
                         if (!simulate && !ignore_dot_underscore){
                             
                             
                             if ([manager removeItemAtPath:potentialTmpFile error:&error])
                             {
                                 logger(@"Sucesfully removed file",true);
                                 sum_dotunderscore++;
                                 
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
             
             ///Now looking for the other patterns in a loop
             
             for(PatternMatchingString *pattern in patternMatchingArray)
             {
                 if ([file rangeOfString:pattern.pattern].location != NSNotFound) {
                     
                     logger([NSString stringWithFormat:@"%@%@", @"Found the following file:" , file],true);
                     
                     if (!simulate && !pattern.ignore){
                         if ([manager removeItemAtPath:file error:&error])
                         {
                             logger(@"Sucesfully removed file",true);
                             pattern.matchCount++;
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
         
         - (void) start{
             
             @try{
                 
                 
                 FSEventStreamStart(stream);
                 // NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(printSummary) userInfo:nil repeats:YES];
                 
             }
             @catch(NSException *e){
                 logger(@"Error during observation mode.",false);
             }
             
         }
         
         
         - (void) stop{
             
             @try{
                 
                 
                 FSEventStreamStop(stream);
                 
                 logger(@"Now stopping observation mode for the following directories:",false);
                 
                 NSArray *tmp = (__bridge NSArray*)pathsToWatch;
                 for (NSString *entry in tmp) {
                     logger(entry,false);
                 }
                 
             }
             @catch(NSException *e){
                 logger(@"Error during stopping observation mode.",false);
             }
             
         }





         
         
         - (void) printSummary{
             
             move(offsetSummary,0);
             [self curseLine:@"------------------------------------------------------------------------------"];
             [self curseLine:@"Starting to clean the following directories in observation mode"];
             
             
             //    NSArray *tmp = (__bridge NSArray*)pathsToWatch;
             //    for (NSString *entry in tmp) {
             //        [self curseLine:tmp];
             //
             //    }
             //
             //    [self curseLine:@"------------------------------------------------------------------------------"];
             //
             //    refresh();
             
             
         }
         
         
         
         - (void) printIntroduction{
             
             if (!verbose){
                 [self curseLine:@"******************************************************************************"];
                 [self curseLine:@"                  Keep OS X folders clean of temporary files   "];
                 [self curseLine:@"******************************************************************************"];
                 [self curseLine:@"##     ##    ###     ######  ########  ########  ##     ##  ######  ##     ## "];
                 [self curseLine:@"###   ###   ## ##   ##    ## ##     ## ##     ## ##     ## ##    ## ##     ## "];
                 [self curseLine:@"#### ####  ##   ##  ##       ##     ## ##     ## ##     ## ##       ##     ## "];
                 [self curseLine:@"## ### ## ##     ## ##       ########  ########  ##     ##  ######  ######### "];
                 [self curseLine:@"##     ## ######### ##       ##     ## ##   ##   ##     ##       ## ##     ## "];
                 [self curseLine:@"##     ## ##     ## ##    ## ##     ## ##    ##  ##     ## ##    ## ##     ## "];
                 [self curseLine:@"##     ## ##     ##  ######  ########  ##     ##  #######   ######  ##     ## "];
                 [self curseLine:@"******************************************************************************"];
                 [self curseLine:@"For comments and bugs please visit https://github.com/nils-tekampe/macbrush   "];
                 [self curseLine:@"******************************************************************************"];
                 
                 
                 refresh();
             }
             
         }
         
         
         - (void) curseLine:(NSString *)_text{
             
             move(row,0);
             printw([_text UTF8String]);
             row++;
             refresh();
             
         }
         
         - (void) curseLineWithoutLineFeed:(NSString *)_text{
             
             move(row,0);
             printw([_text UTF8String]);
             refresh();
             
         }
         
         - (void) curseLineWithTab:(NSString *)_text{
             
             move(row,39);
             printw([_text UTF8String]);
             row++;
             refresh();
             
         }

- (NSString *) stripDirectoryForPrinting:(NSString *)_directory{
    //stripping the directory name down to 40 characters if longer. Also add brackets
    
    if (_directory.length>38){
        return [NSString stringWithFormat:@"%1$@%2$@%3@%4@%5@", [_directory substringToIndex:15], @"...", [_directory substringFromIndex:_directory.length-20], @"]"];
    }
    else
        return [NSString stringWithFormat:@"%1$@%2$@%3@", @"[", _directory, @"]"];
    
}

         @end




