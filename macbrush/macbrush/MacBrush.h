//
//  MacBrush.h
//  macbrush
//
//  Created by Nils Tekampe on 01.08.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PatternMatchingString.h"


@interface MacBrush : NSObject{
    bool ignore_dot_underscore;
    bool ignore_apdisk;
    bool ignore_dsstore;
    bool ignore_volumeicon;
    bool simulate;
    bool verbose;
    
    int sum_dotunderscore;


    CFArrayRef pathsToWatch;

    PatternMatchingString *patternAPDisk ;
    PatternMatchingString *patternDSStore ;
    PatternMatchingString *patternVolumeIcon ;
    NSArray *patternMatchingArray;
    
    FSEventStreamRef stream;
    
}
-(id) initWithValue:(bool)_ignore_dot_underscore:(bool)_ignore_apdisk:(bool)_ignore_dsstore:(bool)_ignore_volumeicon:(bool)_simulate:(bool)_verbose:(NSArray*) _pathesToWatch;
- (void) clean;
- (void) start;
- (void) stop;
- (void) restart;
- (void) logger:(NSString*)message:(bool)verbose_only;
-(void) cleanDirectory:(NSString*) directory;

+(bool) isFile:(NSString*)file;

@end

