//
//  SYNRoundButton.m
//  dolly
//
//  Created by Nick Banks on 30/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRoundButton.h"
#import "UIFont+SYNFont.h"

@implementation SYNRoundButton

- (instancetype) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}


- (instancetype) initWithCoder: (NSCoder *) coder
{
    if ((self = [super initWithCoder: coder]))
    {
        [self commonInit];
    }
    
    return self;
}


- (void) commonInit
{
    self.titleLabel.font = [UIFont lightCustomFontOfSize: 12.0f];
    
    self.layer.cornerRadius = self.frame.size.height * 0.5;
    self.layer.borderColor = [self.defaultColor CGColor];
    self.layer.borderWidth = 1.0f;
    
    [self setTitleColor: self.defaultColor
                 forState: UIControlStateNormal];
    
    [self setTitleColor: self.highlightedColor
                 forState: UIControlStateHighlighted];
    
    [self setTitleColor: self.selectedColor
                 forState: UIControlStateSelected];
    
    self.backgroundColor = [UIColor redColor];

}

//- (void) setTitle: (NSString *) title
//{
//    [button setTitle: title
//            forState: UIControlStateNormal];
//    
//    [button setTitle: title
//            forState: UIControlStateSelected];
//    
//    [button setTitle: title
//            forState: UIControlStateHighlighted];
//}


@end
