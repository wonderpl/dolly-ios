//
//  SYNLoginManager.m
//  dolly
//
//  Created by Sherman Lo on 8/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNLoginManager.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNFacebookManager.h"
#import "SYNActivityManager.h"
#import "SYNOAuth2Credential.h"
#import "SYNTrackingManager.h"
#import <MKNetworkKit.h>

@implementation SYNLoginManager

+ (instancetype)sharedManager {
	static dispatch_once_t onceToken;
	static SYNLoginManager *sharedManager;
	dispatch_once(&onceToken, ^{
		sharedManager = [[SYNLoginManager alloc] init];
	});
	return sharedManager;
}

- (void)registerLoginWithCredentials:(SYNOAuth2Credential *)credentials
							  origin:(LoginOrigin)origin
				   completionHandler:(MKNKUserSuccessBlock)completionBlock
						 errorHander:(MKNKUserErrorBlock)errorBlock {
	
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	[appDelegate.oAuthNetworkEngine retrieveAndRegisterUserFromCredentials:credentials
														 completionHandler:^(NSDictionary *dictionary) {
															 if ([self checkAndSaveRegisteredUser:credentials]) {
																 User *currentUser = appDelegate.currentUser;
																 
																 currentUser.loginOriginValue = origin;
																 
																 if (origin == LoginOriginRockpack && appDelegate.currentUser.facebookAccount) {
																	 // Link it with the FB SDK
																	 NSString *facebookToken = currentUser.facebookAccount.token;
																	 [[SYNFacebookManager sharedFBManager] openSessionFromExistingToken:facebookToken
																															  onSuccess: ^{
																																  DebugLog(@"Linked FB Account");
																															  }
																															  onFailure: ^(NSString *errorMessage) {
																																  DebugLog(@"");
																															  }];
																 }
																 
																 completionBlock(dictionary);
															 } else {
																 DebugLog(@"ERROR: User not registered");
															 }
														 } errorHandler:errorBlock];
}


- (void)loginForUsername:(NSString *)username
			 forPassword:(NSString *)password
	   completionHandler:(MKNKUserSuccessBlock)completionBlock
			errorHandler:(MKNKUserErrorBlock)errorBlock {
	
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	__weak typeof(self) weakSelf = self;
	
    [appDelegate.oAuthNetworkEngine doSimpleLoginForUsername: username
												 forPassword:password
										   completionHandler:^(SYNOAuth2Credential *credential) {
											   __strong typeof(self) strongSelf = weakSelf;
											   
											   [strongSelf registerLoginWithCredentials:credential
																				 origin:LoginOriginRockpack
																	  completionHandler:completionBlock
																			errorHander:errorBlock];
										   } errorHandler: errorBlock];
}

- (void)loginThroughFacebookWithCompletionHandler:(MKNKJSONCompleteBlock)completionBlock
									 errorHandler:(MKNKUserErrorBlock)errorBlock {
	
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
    SYNFacebookManager *facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess: ^(NSDictionary <FBGraphUser> *dictionary) {
        FBAccessTokenData *accessTokenData = [[FBSession activeSession] accessTokenData];
        
        // Log our user's age in Google Analytics
        NSString *birthday = dictionary[@"birthday"];
        
        if (birthday) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"MM/dd/yyyy"];
			
			[[SYNTrackingManager sharedManager] setAgeDimensionFromBirthDate:[dateFormatter dateFromString:birthday]];
        }
		
		// We need to check if the expiration date is valid (if the user is using the native iOS Facebook settings, it will be invalid ([NSDate distantFuture])
		NSDate *expDate = nil;
		if ([accessTokenData.expirationDate compare:[NSDate distantFuture]] != NSOrderedSame) {
			expDate = accessTokenData.expirationDate;
		}
		
        // after the log-in with FB through its SDK, log in with the server hitting "/ws/login/external/"
        [appDelegate.oAuthNetworkEngine doFacebookLoginWithAccessToken:accessTokenData.accessToken
															   expires:expDate
														   permissions:accessTokenData.permissions                 // @"read" at this time
													 completionHandler:^(SYNOAuth2Credential *credential) {
														 
														 [self registerLoginWithCredentials:credential
																					 origin:LoginOriginFacebook
																		  completionHandler:completionBlock
																				errorHander:errorBlock];
													 } errorHandler: errorBlock];
	} onFailure: ^(NSString *errorString) {
		errorBlock(errorString);
	}];
}

- (void)doRequestPasswordResetForUsername:(NSString *)username
						completionHandler:(MKNKJSONCompleteBlock)completionBlock
							 errorHandler:(MKNKErrorBlock)errorBlock {
	
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
    [appDelegate.oAuthNetworkEngine doRequestPasswordResetForUsername:username
													completionHandler:completionBlock
														 errorHandler:errorBlock];
}

- (BOOL)checkAndSaveRegisteredUser: (SYNOAuth2Credential *) credential {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if (!appDelegate.currentUser) {
		return NO;
	}
	
	appDelegate.currentOAuth2Credentials = credential;
	
	return YES;
}

- (void)doRequestUsernameAvailabilityForUsername:(NSString *)username
							   completionHandler:(MKNKJSONCompleteBlock)completionBlock
									errorHandler:(MKNKErrorBlock)errorBlock {
	
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
    [appDelegate.oAuthNetworkEngine doRequestUsernameAvailabilityForUsername:username
														   completionHandler:completionBlock
																errorHandler:errorBlock];
}

- (void)uploadAvatarImage:(UIImage *)image
		completionHandler:(MKNKUserSuccessBlock)completionBlock
			 errorHandler:(MKNKUserErrorBlock)errorBlock {
	
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
    [appDelegate.oAuthNetworkEngine updateAvatarForUserId:appDelegate.currentOAuth2Credentials.userId
													image:image
										completionHandler:completionBlock
											 errorHandler:errorBlock];
}

- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock {
	
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	__weak typeof(self) weakSelf = self;
	
    [appDelegate.oAuthNetworkEngine registerUserWithData:userData completionHandler: ^(SYNOAuth2Credential* credential) {
        
        // Case where the user registers
        [appDelegate.oAuthNetworkEngine retrieveAndRegisterUserFromCredentials: credential
																  completionHandler: ^(NSDictionary* dictionary) {
																	  
																	  __strong typeof(self) strongSelf = weakSelf;
																	  
																	  [strongSelf checkAndSaveRegisteredUser: credential];
																	  completionBlock(dictionary);
																  }  errorHandler: errorBlock];
    } errorHandler: errorBlock];
}


- (void) setRegistrationCheck:(BOOL)registrationCheck
{
    
    
    if (registrationCheck == YES) {
    
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: kUserDefaultsDiscoverUserFirstTime];
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey: kUserDefaultsOtherPersonsProfile];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey: kUserDefaultsCreateChannelFirstTime];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey: kUserDefaultsYourProfileFirstTime];
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kUserDefaultsFeedCount];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kUserDefaultsShareFirstTime];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kUserDefaultsAddToCollectionFirstTime];

    } else {
        
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey: kUserDefaultsDiscoverUserFirstTime];
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey: kUserDefaultsOtherPersonsProfile];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kUserDefaultsCreateChannelFirstTime];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kUserDefaultsYourProfileFirstTime];
		[[NSUserDefaults standardUserDefaults] setInteger:3 forKey:kUserDefaultsFeedCount];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kUserDefaultsShareFirstTime];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kUserDefaultsAddToCollectionFirstTime];

    
    }
    
    _registrationCheck = registrationCheck;
}
@end
