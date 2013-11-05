//
//  SYNFeedMessagesView.m
//  rockpack
//
//  Created by Michael Michailidis on 30/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNPopupMessageView.h"
#import "UIFont+SYNFont.h"

#define kSpinnerTextDistance 12.0

@interface SYNPopupMessageView () 

@property (nonatomic) BOOL isLoader;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) UILabel* messageLabel;

@end


@implementation SYNPopupMessageView

+ (id) withMessage: (NSString*) message
{
    return [[self alloc] initWithMessage: message];
}


+ (id) withMessage: (NSString *) message
         andLoader: (BOOL) isLoader
{
    SYNPopupMessageView* instance = [self withMessage: message];
    instance.isLoader = isLoader;
    return instance;
}


- (id) initWithMessage: (NSString*) message
{
    if (self = [super init])
    {
        UIFont* fontToUse = [UIFont lightCustomFontOfSize: IS_IPHONE ? 14.0f : 18.0f ];
        
        CGRect labelFrame = CGRectZero;
        
        UILabel* label = [[UILabel alloc] initWithFrame: labelFrame];
        label.font = fontToUse;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithWhite:170.0f/255.0f alpha:1.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        label.numberOfLines = 0;
        
        self.messageLabel = label;
        
        // BG
        self.backgroundColor = [UIColor colorWithWhite:IS_IPHONE ? 237.0f/255.0f : 242.0f/255.0f alpha:0.9f];

        // Add
        [self addSubview: label];
        
        [self setMessage: message];
        
    }
    
    return self;
}


- (void) setMessage: (NSString*) newMessage
{
    if (IS_IPHONE)
    {
        self.messageLabel.frame = CGRectMake(0.0f, 0.0f, 260.0f, 300.0f);
    }
    
    self.messageLabel.text = newMessage;
    [self.messageLabel sizeToFit];

    self.frame = [self returnMainFrame];
    
    self.messageLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 + 4.0);
    self.messageLabel.frame = CGRectIntegral(self.messageLabel.frame);
}


- (void) setIsLoader: (BOOL) isLoader
{
    if (_isLoader == isLoader)
        return;
    
    if (_isLoader) // remove existing no matter what
    {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }
    
    _isLoader = isLoader;
    
    if (_isLoader)
    {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.hidesWhenStopped = YES;
        CGRect activityFrame = self.activityIndicatorView.frame;
        activityFrame.origin.x = kSpinnerTextDistance + self.messageLabel.frame.origin.x + self.messageLabel.frame.size.width;
        self.activityIndicatorView.frame = activityFrame;
        self.activityIndicatorView.center = CGPointMake(self.activityIndicatorView.center.x, self.frame.size.height * 0.5);
        self.activityIndicatorView.frame = CGRectIntegral(self.activityIndicatorView.frame);
        [self addSubview: self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
        
        // set frame
        self.frame = [self returnMainFrame];
    }
}


- (CGRect) returnMainFrame
{
    CGRect mainFrame = CGRectMake(0.0, 0.0, self.messageLabel.frame.size.width + 40.0, self.messageLabel.frame.size.height + 30.0);
    
    if (self.isLoader)
    {
        mainFrame.size.width += self.activityIndicatorView.frame.size.width + kSpinnerTextDistance;
    }
    
    return mainFrame;
}

@end
