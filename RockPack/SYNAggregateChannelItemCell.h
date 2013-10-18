//
//  SYNAggregateChannelItemCell.h
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNAggregateChannelItemCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* followersLabel;
@property (nonatomic, strong) IBOutlet UILabel* videosLabel;

@property (nonatomic, strong) IBOutlet UIButton* followButton;
@property (nonatomic, strong) IBOutlet UIButton* shareButton;

-(IBAction)buttonPressed:(id)sender;

@end
