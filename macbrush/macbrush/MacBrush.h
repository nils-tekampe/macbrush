//
//  MacBrush.h
//  macbrush
//
//  Created by Nils Tekampe on 01.08.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MacBrush : NSObject{
    bool ignore_dot_underscore;
    bool ignore_apdisk;
    bool ignore_dsstore;
    bool ignore_volumeicon;
    bool simulate;
    bool verbose;
//Statisticcx
    CFArrayRef pathsToWatch;
    

    PatternMatchingString *patternAPDisk ;
    PatternMatchingString *patternDSStore ;
    PatternMatchingString *patternVolumeIcon ;
    NSArray *patternMatchingArray;
    
}
-(id) initWithValue:(bool)_ignore_dot_underscore:(bool)_ignore_apdisk:(bool)_ignore_dsstore:(bool)_ignore_volumeicon:(bool)_simulate:(bool)_verbose:(NSArray*) _pathesToWatch;
- (void) clean;
- (void) start;
- (void) stop;
- (void) restart;

@end

