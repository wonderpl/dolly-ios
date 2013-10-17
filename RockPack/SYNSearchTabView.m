//
//  SYNSearchTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 19/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNSearchTabView.h"
#import "UIFont+SYNFont.h"

@interface SYNSearchTabView ()

@property (nonatomic, strong) UIButton *overButton;
@property (nonatomic, strong) UIColor *numberColor;
@property (nonatomic, strong) UIColor *parenthesesColor;

@end


@implementation SYNSearchTabView

@synthesize selected = _selected;
@synthesize overButton;

- (id) initWithSearchType: (SearchTabType) itsType
{
    if (self = [super init])
    {
        backgroundImageOff = [[UIImage imageNamed: @"SearchTab"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
        backgroundImageOn = [[UIImage imageNamed: @"SearchTabSelected" ]resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
        backgroundImageHighlighted = [[UIImage imageNamed: @"SearchTabHighlighted"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
        
        CGSize correctSize = IS_IPAD ? CGSizeMake(130, 44) : CGSizeMake(108, 44);
        self.frame = CGRectMake(0.0, 0.0, correctSize.width, correctSize.height);
        
        switch (itsType)
        {
            case SearchTabTypeVideos:
                typeTitle = NSLocalizedString(@"VIDEOS", nil);
                break;
                
            case SearchTabTypeChannels:
                typeTitle = NSLocalizedString(@"CHANNELS", nil);
                break;
                
            case SearchTabTypeUsers:
                typeTitle = NSLocalizedString(@"USERS", nil);
                break;
        }
        
        onColor = [UIColor whiteColor];
        offColor = IS_IPAD ? [UIColor darkGrayColor] : [UIColor colorWithRed: 40.0f / 255.0f
                                                                       green: 45.0f / 255.0f
                                                                        blue: 51.0f / 255.0f
                                                                       alpha: 1.0f];
        self.parenthesesColor = [UIColor colorWithWhite: 170.0f / 255.0f
                                                  alpha: 1.0f];
        self.numberColor = [UIColor colorWithRed: (11.0 / 255.0)
                                           green: (166.0 / 255.0)
                                            blue: (171.0 / 255.0)
                                           alpha: (1.0)];
        
        bgImageView = [[UIImageView alloc] initWithFrame: self.frame];
        bgImageView.image = backgroundImageOff;
        
        [self addSubview: bgImageView];
        
        CGRect labelFrame = self.frame;
        
        if (IS_IPAD)
        {
            labelFrame.origin.y += 1.0f;
        }
        
        titleLabel = [[UILabel alloc] initWithFrame: labelFrame];
        titleLabel.font = [UIFont lightCustomFontOfSize: IS_IPAD ? 14.0f: 12.0f];
        titleLabel.textColor = offColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self setNumberOfItems: 0
                      animated: NO];
        
        [self addSubview: titleLabel];
        
        overButton = [UIButton buttonWithType: UIButtonTypeCustom];
        overButton.frame = self.frame;
        overButton.backgroundColor = [UIColor clearColor];
        
        [overButton addTarget: self
                       action: @selector(highlighted:)
             forControlEvents: UIControlEventTouchDown];
        
        [overButton addTarget: self
                       action: @selector(resetFromHighlighted:)
             forControlEvents: UIControlEventTouchUpOutside];
        
        [self addSubview: overButton];
    }
    
    return self;
}


+ (id) tabViewWithSearchType: (SearchTabType) itsType
{
    return [[self alloc] initWithSearchType: itsType];
}


- (void) setNumberOfItems: (NSInteger) numberOfItems animated: (BOOL) animated
{
    NSString *numberString = nil;
    
    if (numberOfItems > 1000)
    {
        numberString = [NSString stringWithFormat: @"%ik", numberOfItems / 1000];
    }
    else
    {
        numberString = [NSString stringWithFormat: @"%i", numberOfItems];
    }
    
    [self refreshLabelWithString: [NSString stringWithFormat: @"%@ (%@)", typeTitle, numberString]];
}


#pragma mark - Control Methods

- (void) addTarget: (id) target action: (SEL) action forControlEvents: (UIControlEvents) controlEvents
{
    [overButton addTarget: target
                   action: action
         forControlEvents: controlEvents];
}


- (void) removeTarget: (id) target action: (SEL) action forControlEvents: (UIControlEvents) controlEvents
{
    [overButton removeTarget: target
                      action: action
            forControlEvents: controlEvents];
}


- (BOOL) isClicked: (UIButton *) button
{
    return self.overButton == button;
}


- (void) setSelected: (BOOL) value
{
    _selected = value;
    
    if (value)
    {
        bgImageView.image = backgroundImageOn;
        titleLabel.textColor = onColor;
    }
    else
    {
        bgImageView.image = backgroundImageOff;
        titleLabel.textColor = offColor;
    }
    
    [self refreshLabelWithString: titleLabel.attributedText.string];
}


- (BOOL) selected
{
    return _selected;
}


- (void) highlighted: (id) sender
{
    if (!self.selected)
    {
        bgImageView.image = backgroundImageHighlighted;
    }
}


- (void) resetFromHighlighted: (id) sender
{
    [self setSelected: self.selected];
}


- (void) refreshLabelWithString: (NSString *) originalString
{
    NSMutableAttributedString *repaintedString = [[NSMutableAttributedString alloc] initWithString: originalString];
    
    if (!self.selected)
    {
        NSRange leftParentheseRange = [originalString rangeOfString: @"("];
        NSRange rightParentheseRange = [originalString rangeOfString: @")"];
        NSRange numberRange = NSMakeRange(leftParentheseRange.location + 1, rightParentheseRange.location - (leftParentheseRange.location + 1));
        
        [repaintedString addAttribute: NSForegroundColorAttributeName
                                value: self.parenthesesColor
                                range: leftParentheseRange];
        
        [repaintedString addAttribute: NSForegroundColorAttributeName
                                value: self.parenthesesColor
                                range: rightParentheseRange];
        
        [repaintedString addAttribute: NSForegroundColorAttributeName
                                value: self.numberColor
                                range: numberRange];
    }
    
    titleLabel.attributedText = repaintedString;
}


@end
