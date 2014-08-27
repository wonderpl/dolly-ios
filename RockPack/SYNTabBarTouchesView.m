//
//  SYNTabBarTouches.m
//  dolly
//
//  Created by Cong on 04/08/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNTabBarTouchesView.h"
#import "SYNMasterViewController.h"
#import "SYNAppDelegate.h"


@interface SYNTabBarTouchesView ()

@property (nonatomic, weak) SYNMasterViewController *masterViewController;

@end

@implementation SYNTabBarTouchesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.masterViewController = ((SYNAppDelegate*)[[UIApplication sharedApplication] delegate]).masterViewController;
    }
    return self;
}



@end
