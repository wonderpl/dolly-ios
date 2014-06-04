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

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UIView* containerView;

@end

@implementation SYNNetworkMessageView

- (id)initWithMessageType:(NotificationMessageType)type
{
    UIImage* bgImage;
    if(type == NotificationMessageTypeSuccess)
    {
        // this is the 1pixel height image, either red or green according to the type
        bgImage = [UIImage imageNamed:@"BarSucess"];
    }
    else
    {
        bgImage = [UIImage imageNamed:@"BarNetwork"];
    }
    
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
        
        CGRect titleFrame = self.frame;
        _titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont regularCustomFontOfSize:17.0];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        [_containerView addSubview:_titleLabel];
        
        
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_containerView addSubview:_iconImageView];
        
        
        // Wifi Icon
        
        if(type == NotificationMessageTypeNetworkError)
        {
            [self setIconImage:[UIImage imageNamed:@"IconNetwork"]];
            [self setText:NSLocalizedString(@"Network Error",nil)];
            
        }
        
        
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        labelYOffset = 25.0f;
        
    }
    return self;
}



-(void)setText:(NSString *)text
{
    NSString* capsText = [text uppercaseString];
    CGSize textSize = [capsText sizeWithAttributes: @{NSFontAttributeName: self.titleLabel.font}];
    
    CGRect labelFrame = self.titleLabel.frame;
    labelFrame.size = textSize;
    self.titleLabel.frame = labelFrame;
    
    self.titleLabel.text = capsText;
    
    CGRect newFrame = self.containerView.frame;
    newFrame.size.width = self.titleLabel.frame.size.width + 2.0 * (self.iconImageView.frame.size.width + 10.0);
    self.containerView.frame = newFrame;
    self.containerView.center = CGPointMake(roundf(self.frame.size.width / 2.0f), roundf(self.frame.size.height / 2.0f));
    self.titleLabel.center = CGPointMake(roundf(self.containerView.frame.size.width / 2.0f), labelYOffset + 4.0f);
    self.iconImageView.center = CGPointMake(roundf(self.iconImageView.frame.size.width / 2.0f),labelYOffset);
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
