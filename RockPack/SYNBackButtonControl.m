//
//  SYNBackButtonControl.m
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNBackButtonControl.h"
#import "UIFont+SYNFont.h"

#define USE_TITLE_STRING__

@implementation SYNBackButtonControl
@synthesize button;

- (id) init
{
    if (self = [super init])
    {
        // == Over Button == //
        UIImage *normalImage = [UIImage imageNamed: @"ButtonBack"];
        UIImage *highImage = [UIImage imageNamed: @"ButtonBackHighlighted"];
        
        button = [UIButton buttonWithType: UIButtonTypeCustom];
        
        [button setImage: normalImage
                forState: UIControlStateNormal];
        
        [button setImage: highImage
                forState: UIControlStateHighlighted];
        
        button.enabled = YES;
        button.frame = CGRectMake(0.0, 0.0, normalImage.size.width, normalImage.size.height);
        [self addSubview: button];
        
#ifdef USE_TITLE_STRING
        
        if (IS_IPAD)
        {
            // == UIView == //
            titleBGView = [[UIView alloc] init];
            titleBGView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"ButtonBackLabel"]];
            CGRect titleBGRect = CGRectZero;
            titleBGRect.origin.x = button.frame.origin.x + button.frame.size.width;
            titleBGRect.size.height = button.frame.size.height;
            titleBGView.frame = titleBGRect;
            
            // == UILabel == //
            titleLabel = [[UILabel alloc] init];
            CGRect titleRect = CGRectZero;
            titleRect.origin.x = 10.0;
            titleRect.origin.y = 10.0;
            titleLabel.frame = titleRect;
            titleLabel.font = [UIFont rockpackFontOfSize: 20.0];
            titleLabel.textColor = [UIColor lightGrayColor];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.backgroundColor = [UIColor clearColor];
            [titleBGView addSubview: titleLabel];
            
            [self addSubview: titleBGView];
        }
        
#endif /* ifdef USE_TITLE_STRING */
        self.frame = button.frame;
    }
    
    return self;
}


#pragma mark - UIControl Methods

- (void) addTarget: (id) target action: (SEL) action forControlEvents: (UIControlEvents) controlEvents
{
    [button	addTarget: target
               action: action
     forControlEvents: controlEvents];
    
    recogniser = [[UITapGestureRecognizer alloc] initWithTarget: target
                                                         action: action];
    [titleBGView addGestureRecognizer: recogniser];
}


- (void) removeTarget: (id) target action: (SEL) action forControlEvents: (UIControlEvents) controlEvents
{
    [button removeTarget: target
                  action: action
        forControlEvents: controlEvents];
    
    [titleBGView removeGestureRecognizer: recogniser];
}


- (NSArray *) actionsForTarget: (id) target forControlEvent: (UIControlEvents) controlEvent
{
    return [button actionsForTarget: target
                    forControlEvent: controlEvent];
}


#pragma mark - Set the Title Methods
//No more labels next to back button as per the redesign of the redesign, will leave this incase of u-turn - Kish

- (void) setBackTitle: (NSString *) backTitle
{
#ifdef USE_TITLE_STRING
    NSString *upperTitle = [backTitle uppercaseString];
    CGSize titleSize = [upperTitle sizeWithAttributes: @{NSFontAttributeName: titleLabel.font}];
    
    CGRect titleLabelRect = titleLabel.frame;
    titleLabelRect.size = titleSize;
    titleLabel.frame = titleLabelRect;
    titleLabel.center = CGPointMake(titleLabel.center.x, titleBGView.center.y + 4.0);
    titleLabel.frame = CGRectIntegral(titleLabel.frame);
    titleLabel.text = upperTitle;
    
    CGRect titleBGFrame = titleBGView.frame;
    titleBGFrame.size.width = titleLabelRect.size.width + 20.0;
    titleBGView.frame = titleBGFrame;
    
    CGSize totalSize = CGSizeZero;
    totalSize.width = button.frame.size.width + titleBGView.frame.size.width;
    totalSize.height = button.frame.size.height;
    
    CGRect overButtonFrame = CGRectZero;
    overButtonFrame.size = totalSize;
    overButtonFrame.origin = self.frame.origin;
    
    self.frame = overButtonFrame;
#endif /* ifdef USE_TITLE_STRING */
}


#pragma mark - Initialiser Method

+ (id) backButton
{
    return [[self alloc] init];
}

@end
