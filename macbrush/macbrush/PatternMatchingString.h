//
//  PatternMatchingString.h
//  macbrush
//
//  Created by Nils Tekampe on 04.06.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatternMatchingString : NSString

@property (readwrite) NSString *pattern;
@property (readwrite) NSUInteger matchCount;
@property (readwrite) bool ignore;

@end