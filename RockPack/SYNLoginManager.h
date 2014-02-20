//
//  SYNLoginManager.h
//  dolly
//
//  Created by Sherman Lo on 8/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNNetworkOperationJsonObject.h"

@interface SYNLoginManager : NSObject

//registrationCheck is set to yes, when a user registers an account
@property (nonatomic, assign) BOOL registrationCheck;

+ (instancetype)sharedManager;

- (void)loginThroughFacebookWithCompletionHandler:(MKNKJSONCompleteBlock)completionBlock
									 errorHandler:(MKNKUserErrorBlock)errorBlock;

- (void)loginForUsername:(NSString *)username
			 forPassword:(NSString *)password
	   completionHandler:(MKNKUserSuccessBlock)completionBlock
			errorHandler:(MKNKUserErrorBlock)errorBlock;

- (void)doRequestPasswordResetForUsername:(NSString *)username
						completionHandler:(MKNKJSONCompleteBlock)completionBlock
							 errorHandler:(MKNKErrorBlock)errorBlock;

- (void)doRequestUsernameAvailabilityForUsername:(NSString *)username
							   completionHandler:(MKNKJSONCompleteBlock)completionBlock
									errorHandler:(MKNKErrorBlock)errorBlock;

- (void)uploadAvatarImage:(UIImage *)image
		completionHandler:(MKNKUserSuccessBlock)completionBlock
			 errorHandler:(MKNKUserErrorBlock)errorBlock;

- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

@end
