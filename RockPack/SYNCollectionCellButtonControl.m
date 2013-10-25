//
//  SYNLikeButtonControl.m
//  dolly
//
//  Created by Michael Michailidis on 25/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCollectionCellButtonControl.h"
#import "UIFont+SYNFont.h"

@implementation SYNCollectionCellButtonControl

+(id)buttonControl
{
    return [[self alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        // == Set Style == //
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        
        button.titleLabel.font = [UIFont lightCustomFontOfSize:12.0f];
        button.titleLabel.text = @"Michael";
        
        button.layer.cornerRadius = button.frame.size.height * 0.5;
        button.layer.borderColor = [self.defaultColor CGColor];
        button.layer.borderWidth = 1.0f;
        
        [button setTitleColor: self.defaultColor forState:UIControlStateNormal];
        [button setTitleColor: self.highlightedColor forState:UIControlStateHighlighted];
        [button setTitleColor: self.selectedColor forState:UIControlStateSelected];
        
        self.backgroundColor = [UIColor clearColor];
        button.backgroundColor = [UIColor clearColor];
        
        [self addSubview:button];
        
    }
    return self;
}

#pragma mark - UIControl Methods

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [button addTarget:target action:action forControlEvents:controlEvents];
}

-(void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [button removeTarget:target action:action forControlEvents:controlEvents];
}



#pragma mark - UIButton Wrappers

// == Althought the button is alphaed out it is useful to set it to the correct values so as to hold state for the equivalent getters == //

-(void)setHighlighted:(BOOL)highlighted
{
    button.layer.borderColor = [self.highlightedColor CGColor];
    [button setHighlighted:highlighted];
}

-(BOOL)isHighlighted
{
    return button.highlighted;
}

-(void)setSelected:(BOOL)selected
{
    [button setSelected:selected];
}
-(BOOL)isSelected
{
    return button.selected;
    
}
-(void)setEnabled:(BOOL)enabled
{
    [button setEnabled:enabled];
}
-(BOOL)isEnabled
{
    return button.enabled;
}

#pragma mark - Title

-(void)setTitle:(NSString *)title
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateHighlighted];
}
-(NSString*)title
{
    return button.titleLabel.text;
}

#pragma mark - Color Values

-(UIColor*)defaultColor
{
    // override in subclass
    return [UIColor colorWithWhite: (152.0f/255.0f)
                             alpha: 1.0f];
}

-(UIColor*)highlightedColor
{
    return [UIColor colorWithWhite: (194.0f/255.0f)
                             alpha: 1.0f];
}

-(UIColor*)selectedColor
{
    return [UIColor colorWithRed:(0.0f/255.0f)
                           green:(255.0f/255.0f)
                            blue:(0.0f/255.0f)
                           alpha:1.0f];
}

@end
