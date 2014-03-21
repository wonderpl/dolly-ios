//
//  SYNLocationManager.h
//  dolly
//
//  Created by Sherman Lo on 17/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNGenreManager.h"

@interface SYNLocationManager : NSObject

@property (nonatomic, copy, readonly) NSString *locale;
@property (nonatomic, copy, readonly) NSString *location;

+ (instancetype)sharedManager;

- (void)updateLocationWithCompletion:(SYNNetworkStringResultBlock)competionBlock;

@end
