//
//  SYNSearchResultsVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsVideoCell.h"
#import "UIFont+SYNFont.h"

#import "SYNSocialButton.h"
#import "SYNSocialAddButton.h"
#import "SYNSocialLikeButton.h"

@interface SYNSearchResultsVideoCell ()

@property (strong, nonatomic) IBOutlet SYNSocialLikeButton *likeControl;
@property (strong, nonatomic) IBOutlet SYNSocialAddButton *addControl;
@property (strong, nonatomic) IBOutlet SYNSocialButton *shareControl;

@end

@implementation SYNSearchResultsVideoCell

-(void)awakeFromNib
{
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
    
    self.likeControl.title = NSLocalizedString(@"follow", @"Label for follow button on SYNAggregateChannelItemCell");
    // no title for the add button
    self.shareControl.title = NSLocalizedString(@"share", @"Label for share button on SYNAggregateChannelItemCell");
    
}

- (IBAction) likeControlPressed: (id) sender
{
    [self.delegate followControlPressed: sender];
}

- (IBAction) addControlPressed: (id) sender
{
    [self.delegate shareControlPressed: sender];
}

- (IBAction) shareControlPressed: (id) sender
{
    [self.delegate shareControlPressed: sender];
}

@end
