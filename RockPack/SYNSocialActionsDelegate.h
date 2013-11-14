//
//  SYNSocialActionsDelegate.h
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialButton.h"
@import Foundation;

@protocol SYNSocialActionsDelegate <NSObject>

- (void) followControlPressed: (SYNSocialButton *) socialButton;
- (void) shareControlPressed: (SYNSocialButton *) socialButton;
- (void) likeControlPressed: (SYNSocialButton *) socialButton;
- (void) addControlPressed: (SYNSocialButton *) socialButton;

@optional
- (void)deleteVideoInstancePressed:(id)sender;

@end
