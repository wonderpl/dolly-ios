//
//  SYNDebug.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#ifdef DEBUG
#define SYNLog(format...) SYNDebug(__FILE__, __LINE__, format)
#else
#define SYNLog(format...)
#endif

@import Foundation;

void SYNDebug (const char *fileName, int lineNumber, NSString *format, ...);
