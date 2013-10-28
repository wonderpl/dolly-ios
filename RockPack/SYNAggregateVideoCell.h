//
//  SYNAggregateVideoCell.h
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateCell.h"
#import "SYNSocialAddControl.h"
#import "VideoInstance.h"
#import "Video.h"

@interface SYNAggregateVideoCell : SYNAggregateCell
{
    SYNSocialControl* likeControl;
    SYNSocialControl* addControl;
    SYNSocialControl* shareControl;
}


@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, readonly) VideoInstance* videoInstanceShowing;


@end
