//
//  SYNCautionMessageView.m
//  rockpack
//
//  Created by Michael Michailidis on 25/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNCautionMessageView.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

#define CAUTION_VIEW_WIDTH		  320.0
#define CAUTION_TITLE_FONT_SIZE	  17.0
#define CAUTION_MESSAGE_FONT_SIZE 13.0
#define CAUTION_BUTTON_FONT_SIZE  14.0
#define CAUTION_BUTTONS_Y		  104.0

@implementation SYNCautionMessageView

#pragma mark - Object lifecyle

+ (id) withCaution: (SYNCaution *) caution
{
    return [[self alloc] initWithCaution: caution];
}

- (id) initWithCaution: (SYNCaution *) caution
{
    UIImage *bgImage = [UIImage imageNamed: @"PanelPrivateAlert"];
    
    if (!bgImage)
    {
        return nil;
    }
    
    if (self = [super initWithFrame: CGRectMake(0.0, 0.0, CAUTION_VIEW_WIDTH, bgImage.size.height)])
    {
        self.caution = caution;
        
        self.userInteractionEnabled = YES;
        
        self.backgroundColor = [UIColor colorWithPatternImage: bgImage];
        
        UIFont *titleFontToUse = [UIFont regularCustomFontOfSize: CAUTION_TITLE_FONT_SIZE];
        UIFont *messageFontToUse = [UIFont lightCustomFontOfSize: CAUTION_MESSAGE_FONT_SIZE];
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; // center
        
        // == title label == //
        CGRect titleFrame = self.frame;
        titleFrame.origin.y = 25.0;
        titleFrame.size.height = [caution.title sizeWithAttributes: @{NSFontAttributeName: titleFontToUse}].height;
        self.titleLabel = [[UILabel alloc] initWithFrame: titleFrame];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = titleFontToUse;
        self.titleLabel.text = caution.title;
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
        self.titleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.5);
        self.titleLabel.layer.shadowRadius = 0.5;
        self.titleLabel.layer.shadowOpacity = 0.5;
        self.titleLabel.layer.masksToBounds = NO;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview: self.titleLabel];
        
        // == main label == //
        NSLineBreakMode wordWrappingMode = NSLineBreakByWordWrapping;
        CGRect messageFrame = self.frame;
        messageFrame.origin.x = 30.0;
        messageFrame.origin.y = 48.0;
        messageFrame.size.width -= 60.0;
        messageFrame.size.height = 52.0f;
        
        
        self.messageLabel = [[UILabel alloc] initWithFrame: messageFrame];
        self.messageLabel.textColor = [UIColor whiteColor];
        self.messageLabel.font = messageFontToUse;
        self.messageLabel.numberOfLines = 3;
        self.messageLabel.lineBreakMode = wordWrappingMode;
        
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        
        self.messageLabel.layer.shadowColor = [[UIColor colorWithRed: (128.0 / 255.0)
                                                               green: (32.0 / 255.0)
                                                                blue: (39.0 / 255.0)
                                                               alpha: (1.0)] CGColor];
        
        self.messageLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        self.messageLabel.layer.shadowRadius = 0.5;
        self.messageLabel.layer.shadowOpacity = 0.5;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        
        self.messageLabel.text = caution.message;
        
        [self addSubview: self.messageLabel];
        
        // == buttons == //
        if (caution.actionButtonTitle)
        {
            UIImage *actionButtonImage = [UIImage imageNamed: @"ButtonPrivateLeft"];
            UIImage *actionButtonImageHighlighted = [UIImage imageNamed: @"ButtonPrivateLeftHighlighted"];
            self.actionButton = [UIButton buttonWithType: UIButtonTypeCustom];
            
            self.actionButton.frame = CGRectMake(20.0, CAUTION_BUTTONS_Y, actionButtonImage.size.width, actionButtonImage.size.height);
            
            [self.actionButton setBackgroundImage: actionButtonImage
                                         forState: UIControlStateNormal];
            
            [self.actionButton setBackgroundImage: actionButtonImageHighlighted
                                         forState: UIControlStateHighlighted];
            //set text label
            [self.actionButton setTitleColor: [UIColor blackColor]
                                    forState: UIControlStateNormal];
            
            [self.actionButton setTitleEdgeInsets: UIEdgeInsetsMake(4.0, 0.0, 0.0, 0.0)];
            self.actionButton.titleLabel.font = [UIFont regularCustomFontOfSize: CAUTION_BUTTON_FONT_SIZE];
            
            [self.actionButton setTitleShadowColor: [UIColor blackColor]
                                          forState: UIControlStateNormal];
            
            [self.actionButton setTitle: self.caution.actionButtonTitle
                               forState: UIControlStateNormal];
            
            [self.actionButton addTarget: self
                                  action: @selector(buttonPressed:)
                        forControlEvents: UIControlEventTouchUpInside];
            
            [self addSubview: self.actionButton];
        }
        
        // -- passing the skip button image is not mandatory since it is mostly standard -- //
        UIImage *skipButtonImage = [UIImage imageNamed: @"ButtonPrivateRight"];
        UIImage *skipButtonImageHighlighted = [UIImage imageNamed: @"ButtonPrivateRightHighlighted"];
        self.skipButton = [UIButton buttonWithType: UIButtonTypeCustom];
        self.skipButton.frame = CGRectMake(self.actionButton.frame.origin.x + self.actionButton.frame.size.width + 10.0,
                                           CAUTION_BUTTONS_Y, skipButtonImage.size.width, skipButtonImage.size.height);
        
        [self.skipButton setBackgroundImage: skipButtonImage
                                   forState: UIControlStateNormal];
        
        [self.skipButton setBackgroundImage: skipButtonImageHighlighted
                                   forState: UIControlStateHighlighted];
        
        [self.skipButton setTitleEdgeInsets: UIEdgeInsetsMake(4.0, 0.0, 0.0, 0.0)];
        
        // check wether it has been set by the user
        [self.skipButton setTitleColor: [UIColor blackColor]
                              forState: UIControlStateNormal];
        
        self.skipButton.titleLabel.font = [UIFont regularCustomFontOfSize: CAUTION_BUTTON_FONT_SIZE];
        
        [self.skipButton setTitleShadowColor: [UIColor blackColor]
                                    forState: UIControlStateNormal];
        
        if (caution.skipButtonTitle)
        {
            [self.skipButton setTitle: self.caution.skipButtonTitle
                             forState: UIControlStateNormal];
        }
        else
        {
            [self.skipButton setTitle: @"SKIP"
                             forState: UIControlStateNormal];
        }
        
        [self.skipButton addTarget: self
                            action: @selector(buttonPressed:)
                  forControlEvents: UIControlEventTouchUpInside];
        
        [self addSubview: self.skipButton];
        
        // add effects
        
        self.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0, 3.0);
        self.layer.shadowRadius = 3.0;
        self.layer.shadowOpacity = 0.4;
    }
    
    return self;
}


- (void) hide
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kNoteHideAllCautions
                                                  object: nil];
    // hide and remove the view in all cases
    CGRect cautionMessageFrame = self.frame;
    cautionMessageFrame.origin.y = -cautionMessageFrame.size.height; // hide it
    
    [UIView animateWithDuration: 0.4
                     animations: ^{
                         self.frame = cautionMessageFrame;
                     }
     
     
                     completion: ^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}


- (void) buttonPressed: (UIButton *) button
{
    if (button == self.actionButton)
    {
        if (self.caution.action)
        {
            self.caution.action();
        }
    }
    else if (button == self.skipButton)
    {
        if (self.caution.skip)
        {
            self.caution.skip();
        }
    }
    
    [self hide];
}


- (void) presentInView: (UIView *) containerView
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(hide)
                                                 name: kNoteHideAllCautions
                                               object: nil];
    
    CGRect cautionMessageFrame = self.frame;
    cautionMessageFrame.origin.y = -cautionMessageFrame.size.height; // hide it
    cautionMessageFrame.origin.x = ([[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5) - (cautionMessageFrame.size.width * 0.5); // center it
    self.frame = CGRectIntegral(cautionMessageFrame);
    
    [containerView addSubview: self];
    
    // animate down
    cautionMessageFrame.origin.y = 0.0;
    
    [UIView animateWithDuration: 0.4
                     animations: ^{
                         self.frame = cautionMessageFrame;
                     }];
}

@end
