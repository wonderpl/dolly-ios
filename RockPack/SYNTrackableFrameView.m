//
//  SYNTrackableFrameView.m
//  rockpack
//
//  Created by Michael Michailidis on 18/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTrackableFrameView.h"

@implementation SYNTrackableFrameView

-(void)setFrame:(CGRect)frame
{
    NSLog(@"%@", NSStringFromCGRect(frame));
    [super setFrame:frame];
}

-(void)dealloc
{
    NSLog(@"");
}

@end
