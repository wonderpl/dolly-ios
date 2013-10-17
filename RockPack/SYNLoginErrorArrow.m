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

@implementation SYNLoginErrorArrow

- (id)initWithDefault
{
    self = [super init];
    if (self) {
        

        
        if(UIInterfaceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation]))
        {
            backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginErrorPortrait.png"]];
            [self addSubview:backgroundImageView];
            self.frame = backgroundImageView.frame;
            
            CGRect labelFrame = self.frame;
            labelFrame.origin.x += 30.0;
            labelFrame.size.width -= 40.0;
            labelFrame.origin.y += 4.0;
            labelFrame.size.height -= 5.0;
            messageLabel = [[UILabel alloc] initWithFrame:labelFrame];
        }
        
        else
        {
            backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginError.png"]];
            [self addSubview:backgroundImageView];
            self.frame = backgroundImageView.frame;
            
            CGRect labelFrame = self.frame;
            labelFrame.origin.x += 30.0;
            labelFrame.size.width -= 30.0;
            labelFrame.origin.y += 4.0;
            labelFrame.size.height -= 5.0;
            messageLabel = [[UILabel alloc] initWithFrame:labelFrame];
        }
        
        messageLabel.font = [UIFont lightCustomFontOfSize:13.0];
        messageLabel.textColor = [UIColor whiteColor];
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
