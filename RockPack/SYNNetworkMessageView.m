//
//  SYNNetworkErrorView.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNDeviceManager.h"
#import "SYNNetworkMessageView.h"
#import "UIFont+SYNFont.h"
@import QuartzCore;

@interface SYNNetworkMessageView ()
{
    CGFloat labelYOffset;
}

@property (nonatomic, retain)UILabel* errorLabel;
@property (nonatomic, retain)UIImageView* iconImageView;
@property (nonatomic, retain)UIView* containerView;

@end

@implementation SYNNetworkMessageView

- (id)init
{
    UIImage* bgImage = [UIImage imageNamed:@"BarNetwork"];
    CGRect finalFrame = CGRectMake(0.0,
                                   [SYNDeviceManager.sharedInstance currentScreenHeight],
                                   [SYNDeviceManager.sharedInstance currentScreenWidth],
                                   bgImage.size.height);
    
    
    self = [super initWithFrame:finalFrame];
    if (self) {
        
        
        // BG
        
        self.backgroundColor = [UIColor colorWithPatternImage:bgImage];
        
        _containerView = [[UIView alloc] initWithFrame:self.frame];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.containerView];
        // Error Label
        
        _errorLabel = [[UILabel alloc] initWithFrame:self.frame];
        _errorLabel.textColor = [UIColor colorWithRed:(223.0/255.0) green:(244.0/255.0) blue:(1.0) alpha:(1.0)];
        _errorLabel.font = [UIFont lightCustomFontOfSize:17.0];
        _errorLabel.layer.shadowColor = [[UIColor colorWithRed:(128.0/255.0) green:(32.0/255.0) blue:(39.0/255.0) alpha:(1.0)] CGColor];
        _errorLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        _errorLabel.layer.shadowRadius = 1.0;
        _errorLabel.layer.shadowOpacity = 1.0;
        _errorLabel.backgroundColor = [UIColor clearColor];
        
        [_containerView addSubview:_errorLabel];
        
        
        // Wifi Icon
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_containerView addSubview:_iconImageView];
        
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        labelYOffset = 25.0f;
        
    }
    return self;
}

+(id)errorView
{
    SYNNetworkMessageView* errorView =[[self alloc] init];
    [errorView setIconImage:[UIImage imageNamed:@"IconNetwork"]];
    [errorView setText:NSLocalizedString(@"Network Error",nil)];
    return errorView;
}


-(void)setText:(NSString *)text
{
    NSString* capsText = [text uppercaseString];
    CGSize textSize = [capsText sizeWithAttributes: @{NSFontAttributeName: self.errorLabel.font}];
    
    CGRect labelFrame = self.errorLabel.frame;
    labelFrame.size = textSize;
    self.errorLabel.frame = labelFrame;
    
    self.errorLabel.text = capsText;
    
    CGRect newFrame = self.containerView.frame;
    newFrame.size.width = self.errorLabel.frame.size.width + 2.0* (self.iconImageView.frame.size.width + 10.0);
    self.containerView.frame = newFrame;
    self.containerView.center = CGPointMake(roundf(self.frame.size.width/2.0f), roundf(self.frame.size.height/2.0f));
    self.errorLabel.center = CGPointMake(roundf(self.containerView.frame.size.width/2.0f), labelYOffset + 7.0f);
    self.iconImageView.center = CGPointMake(roundf(self.iconImageView.frame.size.width/2.0f),labelYOffset);
}

-(void)setIconImage:(UIImage *)image
{
    self.iconImageView.image=image;
    CGPoint center = self.iconImageView.center;
    CGRect newFrame = self.iconImageView.frame;
    newFrame.size = image.size;
    self.iconImageView.frame = newFrame;
    self.iconImageView.center = center;
}

-(void)setCenterVerticalOffset:(CGFloat)centerYOffset
{
    labelYOffset = centerYOffset;
}

-(CGFloat)height
{
    return self.frame.size.height;
}
@end
