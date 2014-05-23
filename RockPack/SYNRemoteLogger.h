//
//  SYNRemoteLogger.h
//  dolly
//
//  Created by Sherman Lo on 23/05/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNRemoteLogger : NSObject

+ (instancetype)sharedLogger;

- (void)log:(NSString *)message;

@end
