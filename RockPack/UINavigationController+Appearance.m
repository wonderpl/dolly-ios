//
//  UINavigationController+Appearance.m
//  dolly
//
//  Created by Cong on 16/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UINavigationController+Appearance.h"

@implementation UINavigationController (Appearance)

-(void) setTransparent
{
     [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.translucent = YES;
        self.view.backgroundColor = [UIColor blackColor];
}

-(UINavigationBar*) setDefault
{
 //TODO: good way to return default naigation bar
    return self.navigationBar;
}


@end
