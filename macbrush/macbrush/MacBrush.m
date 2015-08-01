//
//  MacBrush.m
//  macbrush
//
//  Created by Nils Tekampe on 01.08.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#import "MacBrush.h"

@implementation MacBrush

- (id) initWithValue:(bool)_ignore_dot_underscore:(bool)_ignore_apdisk {
    self = [self init];
    if (self) {
        ignore_dot_underscore = _ignore_dot_underscore;
        ignore_apdisk=_ignore_apdisk;
    }
    return self;
}

@end


