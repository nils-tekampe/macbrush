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
    
}

- (id) initWithValue:(bool)_ignore_dot_underscore:(bool)_ignore_apdisk ;
- (void) start;
- (void) stop;
- (void) restart;

@end

