//
//  SYNChannelCategoryTableCell.m
//  rockpack
//
//  Created by Mats Trovik on 24/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelCategoryTableCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNChannelCategoryTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if(selected)
    {
        self.titleLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        //self.backgroundImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SubCategorySlideSelected"]];
        self.backgroundImage.image = [UIImage imageNamed:@"SubCategorySlideSelected"];
    }
    else
    {
        self.titleLabel.textColor = [UIColor colorWithRed:14.0f/255.0f green:67.0f/255.0f blue:86.0f/255.0f alpha:1.0f];
        //self.backgroundImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SubCategorySlide"]];
        self.backgroundImage.image = [UIImage imageNamed:@"SubCategorySlide"];
    }
    
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if(highlighted)
    {
        self.titleLabel.textColor = [UIColor colorWithRed:14.0f/255.0f green:67.0f/255.0f blue:86.0f/255.0f alpha:1.0f];
        //self.backgroundImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SubCategorySlideHighlighted"]];
        self.backgroundImage.image = [UIImage imageNamed:@"SubCategorySlideHighlighted"];
    }
    else
    {
        self.titleLabel.textColor = [UIColor colorWithRed:14.0f/255.0f green:67.0f/255.0f blue:86.0f/255.0f alpha:1.0f];
        //self.backgroundImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SubCategorySlide"]];
        self.backgroundImage.image = [UIImage imageNamed:@"SubCategorySlide"];
    }
}

@end
