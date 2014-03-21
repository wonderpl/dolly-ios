//
//  SYNHTTPSessionManager.h
//  dolly
//
//  Created by Sherman Lo on 12/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <AFNetworking.h>

@interface SYNHTTPSessionManager : AFHTTPSessionManager

+ (instancetype)standardAPIManager;
+ (instancetype)secureAPIManager;

@end
