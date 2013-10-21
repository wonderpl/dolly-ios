//
//  SYNSideNavigationIphoneCell.m
//  rockpack
//
//  Created by Mats Trovik on 29/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNSideNavigationIphoneCell.h"
#import "UIFont+SYNFont.h"

@interface SYNSideNavigationIphoneCell ()

@property (nonatomic,weak)UIImageView* backgroundImageView;
@property (nonatomic,strong)UIColor* defaultColor;
@property (nonatomic,strong)UIColor* selectedColor;
@property (nonatomic,strong)UIColor* defaultShadowColor;
@property (nonatomic,strong)UIColor* selectedShadowColor;
@end

@implementation SYNSideNavigationIphoneCell

- (id) initWithStyle: (UITableViewCellStyle) style
     reuseIdentifier: (NSString *) reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        self.defaultColor = [UIColor colorWithRed: (40.0/255.0)
                                            green: (45.0/255.0)
                                             blue: (51.0/255.0)
                                            alpha: (1.0)];
        self.defaultShadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        self.selectedColor = [UIColor colorWithWhite:1.0 alpha:1.0f];
        self.selectedShadowColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        if (IS_IPAD)
        {
            self.textLabel.font = [UIFont lightCustomFontOfSize:15];
        }
        
        else
        {
            self.textLabel.font = [UIFont lightCustomFontOfSize:18];
        }
        
        self.textLabel.textColor = self.defaultColor;
        self.textLabel.shadowColor = self.defaultShadowColor;
        self.textLabel.shadowOffset = CGSizeMake(0.0f,1.0f);
        self.textLabel.backgroundColor = [UIColor clearColor];
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.frame];
        self.backgroundView = imageView;
        self.backgroundImageView = imageView;
        
        self.accessoryNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.accessoryNumberLabel.backgroundColor = [UIColor clearColor];
        self.accessoryNumberLabel.hidden = YES;
        self.accessoryNumberBackground = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"NotificationBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,16,0,16)]];
        self.accessoryNumberLabel.font = [UIFont lightCustomFontOfSize:14];
        self.accessoryNumberLabel.textColor = self.selectedColor;
        self.accessoryNumberLabel.shadowColor = self.selectedShadowColor;
        self.accessoryNumberLabel.shadowOffset = CGSizeMake(0.0f,1.0f);
        [self.contentView addSubview:self.accessoryNumberBackground];
        [self.contentView addSubview:self.accessoryNumberLabel];
        
    }
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint center = self.textLabel.center;
    
    if (IS_IPAD)
    {
        center.y += 3.0f;
    }
    else
    {
        center.y += 4.0f;
    }
    
    self.textLabel.center = center;
}


- (void)setSelected: (BOOL) selected
           animated: (BOOL) animated
{
    [super setSelected: selected
              animated: animated];
    
    if (selected)
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavSelected"];
        self.textLabel.textColor = self.selectedColor;
        self.textLabel.shadowColor = self.selectedShadowColor;
        if(self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
        {
            UIImageView* arrow = (UIImageView*)self.accessoryView;
            arrow.image =[UIImage imageNamed: @"NavArrowSelected"];
        }
    }
    else
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavDefault"];
        self.textLabel.textColor = self.defaultColor;
        self.textLabel.shadowColor = self.defaultShadowColor;
        if(self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
        {
            UIImageView* arrow = (UIImageView*)self.accessoryView;
            arrow.image =[UIImage imageNamed: @"NavArrow"];
        }
    }
}


- (void) setHighlighted: (BOOL) highlighted
               animated: (BOOL) animated
{
    if (highlighted)
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavHighlighted"];
        self.textLabel.textColor = self.defaultColor;
        self.textLabel.shadowColor = self.defaultShadowColor;
        self.textLabel.shadowOffset = CGSizeMake(0.0f,1.0f);
    }
    else
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavDefault"];
    }
}


- (void) setAccessoryNumber: (NSString *) accessoryNumberString
{
    self.accessoryNumberLabel.text = accessoryNumberString;
    [self.accessoryNumberLabel sizeToFit];
    
    if (IS_IPAD)
    {
        self.accessoryNumberLabel.center = CGPointMake(144.0f - self.accessoryNumberLabel.frame.size.width/2 ,IS_IOS_7_OR_GREATER ? 24.0f : 25.0f );
        self.accessoryNumberBackground.center = CGPointMake(144.0f - self.accessoryNumberLabel.frame.size.width/2 , IS_IOS_7_OR_GREATER ? 24.0f : 22.0f );
    }
    
    else
    {
        self.accessoryNumberLabel.center = CGPointMake(230.0f - self.accessoryNumberLabel.frame.size.width/2 , IS_IOS_7_OR_GREATER ? 29.0f : 30.0f );
        self.accessoryNumberBackground.center = CGPointMake(230.0f - self.accessoryNumberLabel.frame.size.width/2 , IS_IOS_7_OR_GREATER ? 29.0f : 27.0f );
    }
    
    CGRect newFrame = self.accessoryNumberBackground.frame;
    newFrame.size.width = MAX(33.0,self.accessoryNumberLabel.frame.size.width - 10.0f);
    self.accessoryNumberBackground.frame = newFrame;
}

@end
