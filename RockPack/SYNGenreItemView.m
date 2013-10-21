//
//  SYNCategoryItemView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Genre.h"
#import "SYNDeviceManager.h"
#import "SYNGenreItemView.h"
#import "SubGenre.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

// These layout offsets and font sizes have been eyeballed to compensate for font offset. May need tweaking.

#define kCategoriesTabOffsetXLandscape		34.0f
#define kCategoriesTabOffsetXPortrait		16.0f

#define kCategoriesTabLabelOffsetYLandscape 6.0f
#define kCategoriesTabLabelOffsetYPortrait	8.0f
#define kCategoriesSubTabLabelOffsetY		11.0f

#define kCategoriesTabFontSizeLandscape		15.0f
#define kCategoriesTabFontSizePortrait		13.0f
#define kCategoriesSubTabFontSizeLandscape	13.0f
#define kCategoriesSubTabFontSizePortrait	12.0f


@implementation SYNGenreItemView

@synthesize model;

- (id) initWithTabItemModel: (Genre *) tabItemModel
{
    if ((self = [super init]))
    {
        // Set view tag equal to the category id
        self.tag = [tabItemModel.uniqueId integerValue];
        
        // Identify what type it is (could have passed is as argument)
        if ([tabItemModel isKindOfClass: [SubGenre class]])
        {
            type = TabItemTypeSub;
        }
        else
        {
            type = TabItemTypeMain;
        }
        
        model = tabItemModel;
        
        [self setViewAttributesWithItemName: model.name];
    }
    
    return self;
}


- (id) initWithLabel: (NSString *) label
              andTag: (int) tag
{
    if ((self = [super init]))
    {
        // Use 0 as the 'special' tag id representing Other
        self.tag = tag;
        
        // As this is a special label, assum that it is a main tab
        type = TabItemTypeMain;
        
        [self setViewAttributesWithItemName: label];
    }
    
    return self;
}


- (void) setViewAttributesWithItemName: (NSString *) itemName
{
    if (type == TabItemTypeMain)
    {
        grayColor = [UIColor colorWithRed: (40.0 / 255.0)
                                    green: (45.0 / 255.0)
                                     blue: (51.0 / 255.0)
                                    alpha: (1.0)];
    }
    else
    {
        grayColor = [UIColor colorWithRed: (113.0 / 255.0)
                                    green: (124.0 / 255.0)
                                     blue: (126.0 / 255.0)
                                    alpha: (1.0)];
    }
    
    UIFont *fontToUse;
    
    if (type == TabItemTypeMain)
    {
        fontToUse = [UIFont lightCustomFontOfSize: 15.0f];
    }
    else
    {
        fontToUse = [UIFont lightCustomFontOfSize: 13.0f];
    }
    
    CGSize sizeToUse = [itemName sizeWithAttributes: @{NSFontAttributeName: fontToUse}];
    
    self.label = [[UILabel alloc] initWithFrame: CGRectMake(0.0, 0.0, sizeToUse.width + kCategoriesTabOffsetXLandscape, 0.0f)];
    self.label.font = fontToUse;
    self.label.text = itemName;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = grayColor;
    self.label.userInteractionEnabled = NO;
    self.label.backgroundColor = [UIColor clearColor];

    [self addSubview: self.label];
    
    self.backgroundColor = [UIColor clearColor];
}


- (void) makeHighlighted
{
    UIImage *pressedImage = [UIImage imageNamed: @"CategoryBarSelected"];
    
    self.backgroundColor = [UIColor colorWithPatternImage: pressedImage];
    
    UIColor *color = [UIColor whiteColor];
    self.label.textColor = color;
}


- (void) makeStandard
{
    self.backgroundColor = [UIColor clearColor];
    self.label.textColor = grayColor;
}


#pragma mark - resize for different orientations

- (void) resizeForOrientation: (UIInterfaceOrientation) orientation
                   withHeight: (CGFloat) height
{
    BOOL isLandscape = [SYNDeviceManager.sharedInstance isLandscape];
    CGFloat offsetX;
    UIFont *fontToUse;
    CGFloat labelYOffset;
    
    if (type == TabItemTypeMain)
    {
        if (isLandscape)
        {
            fontToUse = [UIFont lightCustomFontOfSize: kCategoriesTabFontSizeLandscape];
            offsetX = kCategoriesTabOffsetXLandscape;
            labelYOffset = kCategoriesTabLabelOffsetYLandscape;
        }
        else
        {
            fontToUse = [UIFont lightCustomFontOfSize: kCategoriesTabFontSizePortrait];
            offsetX = kCategoriesTabOffsetXPortrait;
            labelYOffset = kCategoriesTabLabelOffsetYPortrait;
        }
    }
    else if (isLandscape)
    {
        fontToUse = [UIFont lightCustomFontOfSize: kCategoriesSubTabFontSizeLandscape];
        offsetX = kCategoriesTabOffsetXLandscape;
        labelYOffset = kCategoriesSubTabLabelOffsetY;
    }
    else
    {
        fontToUse = [UIFont lightCustomFontOfSize: kCategoriesSubTabFontSizePortrait];
        offsetX = kCategoriesTabOffsetXPortrait;
        labelYOffset = kCategoriesSubTabLabelOffsetY;
    }
    
    self.label.font = fontToUse;
    
    CGSize sizeToUse = [self.label.text sizeWithAttributes: @{NSFontAttributeName: fontToUse}];
    
    CGRect newFrame = self.label.frame;
    newFrame.size = CGSizeMake(sizeToUse.width + offsetX, height + labelYOffset);
    self.label.frame = newFrame;
    
    CGRect finalFrame = self.label.frame;
    finalFrame.size = CGSizeMake(sizeToUse.width + offsetX, height);
    
    self.frame = finalFrame;
}


@end
