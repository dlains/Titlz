//
//  DLog.h
//
//  Created by David Lains on 5/9/11.
//  Copyright 2011 Dagger Lake Software, LLC. All rights reserved.
//

#ifdef DLDEBUG
#define DLog(format...) DLDebug(__FILE__, __LINE__, format)
#else
#define DLog(format...)
#endif

void DLDebug(const char* fileName, int lineNumber, NSString* format, ...);