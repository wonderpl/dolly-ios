//
//  NSString+Timecode.h
//  rockpack
//
//  Created by Nick Banks on 14/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import Foundation;

@interface NSString (Timecode)

+ (NSString *) timecodeStringFromSeconds: (float) timeSeconds;

+ (NSString *)paddedTimecodeStringFromSeconds:(NSTimeInterval)seconds;

@end
