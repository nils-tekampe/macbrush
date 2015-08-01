//
//  MacBrush.m
//  macbrush
//
//  Created by Nils Tekampe on 01.08.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#import "MacBrush.h"
#include "PatternMatchingString.h"

@implementation MacBrush

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
        
        
        *patternAPDisk = [[PatternMatchingString alloc] init];
        patternAPDisk.pattern=@".apdisk";
        patternAPDisk.matchCount=0;
        patternAPDisk.ignore=ignore_apdisk;
        
        *patternDSStore = [[PatternMatchingString alloc] init];
        patternDSStore.pattern=@".DS_Store";
        patternDSStore.matchCount=0;
        patternDSStore.ignore=ignore_dsstore;
        
        *patternVolumeIcon = [[PatternMatchingString alloc] init];
        patternVolumeIcon.pattern=@".VolumeIcon.icns";
        patternVolumeIcon.matchCount=0;
        patternVolumeIcon.ignore=ignore_volumeicon;
        
        
        patternMatchingArray = [NSArray arrayWithObjects:patternAPDisk,patternDSStore,patternVolumeIcon,nil];
        
    }
    return self;
}

@end


