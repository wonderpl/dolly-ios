//
//  AMBlurView.m
//  blur
//
//  Created by Cesar Pinto Castillo on 7/1/13.
//  Copyright (c) 2013 Arctic Minds Inc. All rights reserved.
//

#import "AMBlurView.h"
@import QuartzCore;

@interface AMBlurView ()

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) CALayer *blurLayer;

@end

@implementation AMBlurView

- (instancetype) initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}


- (instancetype) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}


- (instancetype) init
{
    self = [super init];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}


- (void) setup
{
    self.toolbar = [[UIToolbar alloc] initWithFrame: self.bounds];
    self.blurLayer = self.toolbar.layer;
  
    UIView *blurView = [UIView new];
    blurView.userInteractionEnabled = NO;
    [blurView.layer addSublayer: self.blurLayer];
    
    [blurView setTranslatesAutoresizingMaskIntoConstraints: YES];
    [blurView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    [self insertSubview: blurView
                atIndex: 0];
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[blurView]|"
                                                                  options: 0
                                                                  metrics: nil
                                                                    views: NSDictionaryOfVariableBindings(blurView)]];
    
//    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-(-1)-[blurView]-(-1)-|"
//                                                                  options: 0
//                                                                  metrics: nil
//                                                                    views: NSDictionaryOfVariableBindings(blurView)]];
    
     self.backgroundColor = [UIColor clearColor];
}


- (void) setBlurTintColor: (UIColor *) blurTintColor
{
    self.toolbar.barTintColor = blurTintColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.toolbar setFrame:[self bounds]];
}

- (void) setFrame: (CGRect) frame
{
    [super setFrame: frame];
    
    self.toolbar.frame = self.bounds;
//    self.blurLayer.frame = self.bounds;
}


@end
