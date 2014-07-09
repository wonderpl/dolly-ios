//
//  SYNTwitterManager.h
//  dolly
//
//  Created by Cong on 07/07/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNOAuth2Credential.h"

@import UIKit;
@import Accounts;

typedef void (^TwitterLoginSuccessBlock)(SYNOAuth2Credential *userInfo);
typedef void (^TwitterLoginFailureBlock)(NSString *errorMessage);
typedef void(^TWAPIHandler)(NSData *data, NSError *error);

@interface SYNTwitterManager : NSObject

@property (nonatomic, readonly) NSArray *accounts;

+ (instancetype)sharedTwitterManager;

- (void) loginWithAccount:(ACAccount*)account
				OnSuccess: (TwitterLoginSuccessBlock) successBlock
                onFailure: (TwitterLoginFailureBlock) failureBlock;

- (void)refreshTwitterAccounts:(void (^)(BOOL)) completion;
- (NSString*)createExternalTokenFromDict:(NSData*) responseData;


@end
