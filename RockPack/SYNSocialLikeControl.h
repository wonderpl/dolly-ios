//
//  SYNLikeControlButton.h
//  dolly
//
//  Created by Michael Michailidis on 25/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialControl.h"

@interface SYNSocialLikeControl : SYNSocialControl
{
    @private UILabel* numberLabel;
}

@property (nonatomic) NSInteger numberOfLikes;

@end
