//
//  main.h
//  MacBrush
//
//  Created by Nils Tekampe on 22.05.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#ifndef MacBrush_main_h
#define MacBrush_main_h


#endif

void logger(NSString *message, bool verbose_only);
void mycallback(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[]);

int processFile(NSString* file);
void cleanDirectory(NSString *directory);
void resetCounter();
