//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNAggregateVideoCell.h"
#import "SYNAppDelegate.h"
#import "SYNTouchGestureRecognizer.h"
#import "SYNAggregateVideoItemCell.h"
#import "SYNDeviceManager.h"
#import "UIColor+SYNColor.h"
#import "UIImage+Tint.h"
#import "SYNSocialControlFactory.h"


@interface SYNAggregateVideoCell () <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) CGFloat scrollViewMargin;

@end

static NSString* kVideoItemCellIndetifier = @"SYNAggregateVideoItemCell";


@implementation SYNAggregateVideoCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    
    
    // == Create Buttons == //
    
    CGPoint middlePoint = CGPointMake(self.bottomControlsView.frame.size.width * 0.5f, self.bottomControlsView.frame.size.height * 0.5);
    
    likeControl = [[SYNSocialControlFactory defaultFactory] createControlForType:SocialControlTypeDefault
                                                                          forTitle:@"like"
                                                                       andPosition:CGPointMake(middlePoint.x - 60.0f, middlePoint.y)];
    
    [self.bottomControlsView addSubview:likeControl];
    
    addControl = [[SYNSocialControlFactory defaultFactory] createControlForType:SocialControlTypeAdd
                                                                         forTitle:nil
                                                                      andPosition:CGPointMake(middlePoint.x, middlePoint.y)];
    
    [self.bottomControlsView addSubview:addControl];
    
    shareControl = [[SYNSocialControlFactory defaultFactory] createControlForType:SocialControlTypeDefault
                                                                         forTitle:@"share"
                                                                      andPosition:CGPointMake(middlePoint.x + 60.0f, middlePoint.y)];
    
    [self.bottomControlsView addSubview:shareControl];
    
    
    // == Set Nib == //
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:kVideoItemCellIndetifier bundle:nil]
          forCellWithReuseIdentifier:kVideoItemCellIndetifier];
    
    
}


- (void) setDelegate: (id<SYNSocialActionsDelegate>) delegate
{
    [super setDelegate: delegate];

    [likeControl addTarget: self.delegate
                    action: @selector(likeControlPressed:)
          forControlEvents: UIControlEventTouchUpInside];
    
    [addControl addTarget: self.delegate
                    action: @selector(addControlPressed:)
          forControlEvents: UIControlEventTouchUpInside];
    
    [shareControl addTarget: self.delegate
                    action: @selector(shareControlPressed:)
          forControlEvents: UIControlEventTouchUpInside];
}




-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    CGFloat middleOfView = roundf(viewSize.width * 0.5f); // to avoid pixelation
    
    CGRect bgViewFrame = self.backgroundView.frame;
    if(IS_IPHONE)
    {
        bgViewFrame.size.width = 320.0f;
        
    }
    else
    {
        bgViewFrame.size.width = 400.0f;
    }
    
    self.backgroundView.frame = bgViewFrame;
    self.backgroundView.center = CGPointMake(middleOfView, self.backgroundView.center.y);
    
    // user thumbnail
    self.userThumbnailImageView.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    self.userThumbnailButton.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    
    // bottom controls
    self.bottomControlsView.center = CGPointMake(middleOfView, self.bottomControlsView.center.y);
    
    // == Collection View == //
    
    CGRect collectionFrame = self.collectionView.frame;
    
    // the idea is to put a margin so as to show the next video cell while adding an inset of the same value
    collectionFrame.size = CGSizeMake(self.sizeForItemAtDefaultPath.width + self.scrollViewMargin, self.sizeForItemAtDefaultPath.height);
    
    
    self.collectionView.frame = collectionFrame;
    
    // now set the bounds
    
    
    UIEdgeInsets scrollViewInsets = self.collectionView.contentInset;
    scrollViewInsets.left = self.scrollViewMargin;
    self.collectionView.contentInset = scrollViewInsets;
    
    // finally center it
    self.collectionView.center = CGPointMake(middleOfView, self.collectionView.center.y);
    
    
}




- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.collectionData = @[];
    
    [self.collectionView reloadData];
    
}



#pragma mark - UICollectionView DataSource

// utility method (overriding abstract class)
-(CGSize)sizeForItemAtDefaultPath
{
    return [self collectionView:self.collectionView
                         layout:self.collectionView.collectionViewLayout
         sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    CGSize correctSize = CGSizeZero;
    if(IS_IPHONE)
    {
        
        correctSize.width = 248.0f;
        correctSize.height = 139.0f;
    }
    else
    {
        
        correctSize.width = 288.0f;
        correctSize.height = 139.0f;
            
        
    }
    
    return correctSize;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.collectionData.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    SYNAggregateVideoItemCell* itemCell = [collectionView dequeueReusableCellWithReuseIdentifier: kVideoItemCellIndetifier
                                                                                    forIndexPath: indexPath];
    
    VideoInstance* videoInstance = self.collectionData[indexPath.item];
    
    
    [itemCell.imageView setImageWithURL: [NSURL URLWithString: videoInstance.thumbnailURL] // calls vi.video.thumbnailURL
                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                options: SDWebImageRetryFailed];
    
    return itemCell;
    
    
}

-(CGFloat)scrollViewMargin
{
    return 40.0f;
}

-(ChannelOwner*)channelOwner
{
    VideoInstance* heuristic = self.videoInstanceShowing;
    if(!heuristic)
        return nil;
    
    return heuristic.channel.channelOwner;
}

-(VideoInstance*)videoInstanceShowing
{
    if(self.collectionData.count == 0)
        return nil;
    
    // TODO: Figure out the correct video instance according to scroll offset
    
    return (VideoInstance*)self.collectionData[0];
}


@end
