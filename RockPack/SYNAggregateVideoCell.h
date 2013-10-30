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



@property (nonatomic, strong) IBOutlet UILabel* channelNameLabel;
@property (nonatomic, readonly) VideoInstance* videoInstanceShowing;


@end
