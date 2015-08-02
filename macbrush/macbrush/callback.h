//
//  callback.h
//  macbrush
//
//  Created by Nils Tekampe on 02.08.15.
//  Copyright (c) 2015 Nils Tekampe. All rights reserved.
//

#ifndef macbrush_callback_h
#define macbrush_callback_h

void mycallback(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[]);

bool isFile(NSString *file);
    
#endif
