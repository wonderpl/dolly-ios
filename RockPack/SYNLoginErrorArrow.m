//
//  SYNLoginErrorArrow.m
//  rockpack
//
//  Created by Michael Michailidis on 13/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNLoginErrorArrow.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNLoginErrorArrow

- (id)initWithDefault
{
    CGRect correctFrame = CGRectZero;
    if(UIInterfaceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation]))
        correctFrame.size = CGSizeMake(233.0f, 62.0);
    else
        correctFrame.size = CGSizeMake(350.0f, 62.0);
    
    self = [super initWithFrame:correctFrame];
    
    if (self) {
        
        CGRect labelFrame = self.frame;
        labelFrame.origin.x += 30.0;
        labelFrame.size.width -= 30.0;
        labelFrame.origin.y += 4.0;
        labelFrame.size.height -= 5.0;
        messageLabel = [[UILabel alloc] initWithFrame:labelFrame];
        
        messageLabel.font = [UIFont lightCustomFontOfSize:16.0];
        
        messageLabel.shadowColor = [UIColor whiteColor];
        messageLabel.shadowOffset = CGSizeMake(0, 1);
        
        messageLabel.textColor = [UIColor colorWithRed:(142.0f/255.0f) green:(22.0f/255.0f) blue:(41.0f/255.0f) alpha:(1.0f)];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.numberOfLines = 2;        
        
        [self addSubview:messageLabel];
        
    }
    return self;
}

-(void)setMessage:(NSString *)message
{
    messageLabel.text = message;
}

+(id)withMessage:(NSString*)message
{
    SYNLoginErrorArrow* instance = [[SYNLoginErrorArrow alloc] initWithDefault];
    
    [instance setMessage:message];
    
    return instance;
}
@end
