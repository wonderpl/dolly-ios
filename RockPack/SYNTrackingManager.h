//
//  SYNTrackingManager.h
//  dolly
//
//  Created by Sherman Lo on 18/02/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNTrackingManager : NSObject

+ (instancetype)sharedManager;

- (void)trackVideoShare;
- (void)trackVideoAdd;
- (void)trackFacebookLogin;
- (void)trackUserLoginFromOrigin:(NSString *)origin;

- (void)trackStartScreenView;
- (void)trackLoginScreenView;
- (void)trackForgotPasswordScreenView;
- (void)trackRegisterScreenView;
- (void)trackRegisterStep2ScreenView;

- (void)setAgeDimensionFromBirthDate:(NSDate *)birthDate;


@end
