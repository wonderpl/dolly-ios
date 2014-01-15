//
//  GAI+Tracking.h
//  dolly
//
//  Created by Sherman Lo on 10/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAI.h"

@interface GAI (Tracking)

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
