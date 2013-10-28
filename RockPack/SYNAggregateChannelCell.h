//
//  SYNAggregateChannelCell.h
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateCell.h"
#import "Channel.h"

@interface SYNAggregateChannelCell : SYNAggregateCell 

@property (nonatomic, strong) IBOutlet UIButton* followButton;
@property (nonatomic, strong) IBOutlet UIButton* shareButton;

@property (nonatomic, readonly) Channel* channelShowing;

@end
