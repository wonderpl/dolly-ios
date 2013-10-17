//
//  SYNYouHeaderView.m
//  rockpack
//
//  Created by Michael Michailidis on 18/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNYouHeaderView.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"

@interface SYNYouHeaderView ()

@property (nonatomic, strong) UIColor* parenthesesColor;
@property (nonatomic, strong) UIColor* numberColor;

@end

@implementation SYNYouHeaderView

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,0.0f,0.0f,0.0f)];
        UIFont* fontToUse = [UIFont lightCustomFontOfSize:21.0];
        label.font = fontToUse;
        label.textColor = [UIColor colorWithRed:(106.0/255.0) green:(114.0/255.0) blue:(112.0/255.0) alpha:(1.0)];
        label.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.parenthesesColor = label.textColor;
        self.numberColor = [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 1;
        
        
        [self addSubview:label];
        
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        backgroundImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:backgroundImageView];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        
        textCompositeView = [[UIView alloc] initWithFrame:frame];
        textCompositeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        
        [self addSubview:textCompositeView];
    }
    return self;
}

+(id)headerViewForWidth:(CGFloat)width
{
    return [[self alloc] initWithFrame:CGRectMake(0.0, 165.0f, width, 50.0)];
}

-(void)setTitle:(NSString *)title andNumber:(NSInteger)number
{
    NSString* completeString = [NSString stringWithFormat:NSLocalizedString(@"%@ (%i)",nil), title, number];

    [self refreshLabelWithString:completeString];
    [label sizeToFit];
    
    [textCompositeView addSubview:label];
    
    textCompositeView.frame = label.frame;
    
    textCompositeView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    textCompositeView.frame = CGRectIntegral(textCompositeView.frame);
    
    
}

-(void)setBackgroundImage:(UIImage*)backgroundImage
{
    backgroundImageView.image = backgroundImage;
}


-(CGFloat)currentHeight
{
    return self.frame.size.height;
}
-(CGFloat)currentWidth
{
    return self.frame.size.width;
}

-(void)setFontSize:(CGFloat)pointSize
{
    label.font = [UIFont lightCustomFontOfSize:pointSize];
}

-(void) setColorsForText:(UIColor*)textColor parentheses:(UIColor*)parenthesesColor number:(UIColor*)numberColor
{
    label.textColor = textColor;
    self.parenthesesColor = parenthesesColor;
    self.numberColor = numberColor;
    if(label.attributedText.string.length > 0)
    {
        [self refreshLabelWithString:label.attributedText.string];
    }
}

-(void)refreshLabelWithString:(NSString*)originalString
{
    NSMutableAttributedString* repaintedString = [[NSMutableAttributedString alloc] initWithString:originalString];
    NSRange leftParentheseRange = [originalString rangeOfString:@"("];
    NSRange rightParentheseRange = [originalString rangeOfString:@")"];
    NSRange numberRange = NSMakeRange(leftParentheseRange.location+1, rightParentheseRange.location - (leftParentheseRange.location+1));
    [repaintedString addAttribute: NSForegroundColorAttributeName value: self.parenthesesColor range: leftParentheseRange];
    [repaintedString addAttribute: NSForegroundColorAttributeName value: self.parenthesesColor range: rightParentheseRange];
    [repaintedString addAttribute: NSForegroundColorAttributeName value: self.numberColor range: numberRange];
    label.attributedText = repaintedString;
}

@end
