//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateVideoCell.h"
#import "ChannelOwner.h"
#import "UIColor+SYNColor.h"
#import "SYNAppDelegate.h"


static NSDictionary* lightTextAttributes = nil;
static NSDictionary* boldTextAttributes = nil;

@implementation SYNAggregateVideoCell


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.likeLabel.font = [UIFont rockpackFontOfSize:self.likeLabel.font.pointSize];
    
    if(!IS_IPAD)
        self.likesNumberLabel.hidden = YES;
    else
        self.likesNumberLabel.font = [UIFont boldRockpackFontOfSize:self.likesNumberLabel.font.pointSize];
    
    
    lightTextAttributes = @{NSFontAttributeName:[UIFont rockpackFontOfSize:12.0],NSForegroundColorAttributeName:[UIColor rockpacAggregateTextLight]};
    boldTextAttributes = @{NSFontAttributeName:[UIFont boldRockpackFontOfSize:12.0],NSForegroundColorAttributeName:[UIColor rockpacAggregateTextBold]};

}


-(void)setCoverImagesAndTitlesWithArray:(NSArray*)array
{
    if(!videoImageView) {
        CGRect videoImageFrame = CGRectZero;
        videoImageFrame.size = self.imageContainer.frame.size;
        videoImageView = [[UIImageView alloc] initWithFrame:videoImageFrame];
        [self.imageContainer addSubview:videoImageView];
    }
    
    NSDictionary* coverInfo = (NSDictionary*)array[0];
    
    [videoImageView setImageWithURL: [NSURL URLWithString: coverInfo[@"image"]]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                            options: SDWebImageRetryFailed];
    
    
}

- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    
    [super setViewControllerDelegate:viewControllerDelegate];
    
    
    [self.addButton addTarget: self.viewControllerDelegate
                       action: @selector(videoAddButtonTapped:)
             forControlEvents: UIControlEventTouchUpInside];
    
    
    [self.heartButton addTarget:self.viewControllerDelegate
                         action:@selector(likeButtonPressed:)
               forControlEvents:UIControlEventTouchUpInside];
    
    
}




-(void)setTitleMessageWithDictionary:(NSDictionary*)messageDictionary
{
    NSString* channelOwnerName = messageDictionary[@"display_name"] ? messageDictionary[@"display_name"] : @"User";
    
    NSNumber* itemCountNumber = messageDictionary[@"item_count"] ? messageDictionary[@"item_count"] : @1;
    NSString* actionString = [NSString stringWithFormat:@"%i video%@", itemCountNumber.integerValue, itemCountNumber.integerValue > 1 ? @"s" : @""];

    NSString* channelNameString = messageDictionary[@"channel_name"] ? messageDictionary[@"channel_name"] : @"his channel";
    
    
    // craete the attributed string //
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    
    [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:channelOwnerName
                                                                                     attributes:boldTextAttributes]];
    
    // add buttons
    
    [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:@"added"
                                                                                     attributes:lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:actionString
                                                                                     attributes:boldTextAttributes]];
    
    
    [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:@"to"
                                                                                     attributes:lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:channelNameString
                                                                                     attributes:boldTextAttributes]];
    
    
    
    self.messageLabel.attributedText = attributedCompleteString;
}

-(void)setSupplementaryMessageWithDictionary:(NSDictionary*)messageDictionary
{
    
    
    
    NSNumber* likesNumber = messageDictionary[@"star_count"] ? messageDictionary[@"star_count"] : @(0);
    NSString* likesString = [NSString stringWithFormat:@"%i likes", likesNumber.integerValue];
    
    
    
    NSAttributedString* likesAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", likesString]
                                                                                attributes:boldTextAttributes];
    
    if(likesNumber.integerValue == 0)
    {
        if(IS_IPAD)
        {
            self.likesNumberLabel.text = likesString;
            self.likeLabel.hidden = YES;
        }
        else
        {
            self.likeLabel.attributedText = likesAttributedString;
        }
        
        
        return;
    }
    
    
    NSString* including = @"including";
    
    
    
    NSMutableString* namesString = [[NSMutableString alloc] init];
    NSOrderedSet* users = messageDictionary[@"starrers"] ? messageDictionary[@"starrers"] : [NSOrderedSet orderedSet];
    
    
    
    SYNAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    if(users.count > 0)
    {
        ChannelOwner* co;
        NSString* name;
        for (int i = 0; i < users.count; i++)
        {
            
            co = (ChannelOwner*)users[0];
            
            if([co.uniqueId isEqualToString:appDelegate.currentUser.uniqueId])
                name = @"You";
            else
                [namesString appendString:co.displayName];
            
            if((users.count - i) == 2) // the one before last
                name = @" & ";
            else if((users.count - i) > 2)
                name = @", ";
            
            [namesString appendString:name];
            
        }
        
        
    }
    
    
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
 
    if(!IS_IPAD && users.count > 3)
    {
        
        [attributedCompleteString appendAttributedString:likesAttributedString];
        
        
    }
    else
    {
        self.likesNumberLabel.text = [NSString stringWithFormat:@"%i", likesNumber.integerValue];
    }
    
    if(users.count > 1 && users.count < 4)
    {
      
        [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", including]
                                                                                         attributes:lightTextAttributes]];
        
    }
    
    [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", namesString]
                                                                                     attributes:boldTextAttributes]];
    
    
    
    self.likeLabel.attributedText = attributedCompleteString;
}
-(void)prepareForReuse
{
    [super prepareForReuse];
    self.likeLabel.hidden = NO;
}
-(void)setCoverTitleWithString:(NSString*)coverTitle
{
    
}


@end
