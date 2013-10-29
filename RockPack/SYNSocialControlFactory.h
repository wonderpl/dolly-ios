//
//  SYNButtonControlFactory.h
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNSocialControl.h"

@interface SYNSocialControlFactory : NSObject

+ (instancetype) defaultFactory;
-(SYNSocialControl*)createControlForType:(SocialControlType)type forTitle:(NSString*)title andPosition:(CGPoint)position;

@end
