//
//  main.h
//  macbrush
//
//  Created by Nils Tekampe on 22.05.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#ifndef macbrush_main_h
#define macbrush_main_h


#endif

#define USAGE @"usage: macbrush [-d] [-a] [-o] [-i] [-s] [-v] [-c] [-o] [-h] targetDirectory"

void logger(NSString *message, bool verbose_only);
void mycallback(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[]);

bool processFile(NSString* file);
void cleanDirectory(NSString *directory);
