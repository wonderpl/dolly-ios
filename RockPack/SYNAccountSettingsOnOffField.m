//
//  SYNAccountSettingsOnOffField.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAccountSettingsOnOffField.h"
#import "UIFont+SYNFont.h"
@import QuartzCore;

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"


@implementation SYNAccountSettingsOnOffField

- (id) initWithFrame: (CGRect) frame
           andString: (NSString *) value
{
    UIFont *rockpackFont = [UIFont regularCustomFontOfSize: 20];
    CGSize measure = [value sizeWithAttributes: @{NSFontAttributeName: rockpackFont}];
    
    self = [super initWithFrame: frame];
    
    if (self)
    {
        self.textField = [[UITextField alloc] initWithFrame: CGRectMake(8.0, 0.0, measure.width, measure.height)];
        self.textField.text = value;
        self.textField.font = rockpackFont;
        self.textField.backgroundColor = [UIColor clearColor];
        self.textField.textColor = [UIColor whiteColor];
        self.textField.textAlignment = NSTextAlignmentLeft;
        [self addSubview: self.textField];
        
        self.onOffSwitch = [[UISwitch alloc] init];
        CGRect onOffFrame = self.onOffSwitch.frame;
        onOffFrame.origin.x = self.frame.size.width - onOffFrame.size.width - 6.0f;
        
        [self.onOffSwitch addTarget: self
                             action: @selector(switchToggled:)
                   forControlEvents: UIControlEventTouchUpInside];
        
        [self addSubview: self.onOffSwitch];
        
        CGRect selfFrame = self.frame;
        selfFrame.size.height = onOffFrame.size.height + 12.0;
        self.frame = selfFrame;
        
        self.onOffSwitch.frame = onOffFrame;
        self.onOffSwitch.center = CGPointMake(self.onOffSwitch.center.x, self.frame.size.height * 0.5);
        self.onOffSwitch.frame = CGRectIntegral(self.onOffSwitch.frame);
        
        self.textField.center = CGPointMake(self.textField.center.x, self.frame.size.height * 0.5 + 2.0);
        self.textField.frame = CGRectIntegral(self.textField.frame);
        
        self.backgroundColor = [UIColor colorWithRed: 1.0
                                               green: 1.0
                                                blue: 1.0
                                               alpha: 0.1f];
        
        self.layer.cornerRadius = 4.0;
    }
    
    return self;
}


- (void) switchToggled: (UISwitch *) switchComponent
{
    [target performSelector: action
                 withObject: self];
}


- (void) addTarget: (id) atarget action: (SEL) anaction
{
    target = atarget;
    action = anaction;
}

@end
