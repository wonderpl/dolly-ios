//
//  SYNChannelDetailsViewController.h
//  dolly
//
//  Created by Cong on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractViewController.h"
#import "SYNSocialActionsDelegate.h"

typedef enum : NSInteger
{
    kChannelDetailsModeDisplay = 0,
    kChannelDetailsModeEdit = 1,
    kChannelDetailsModeCreate = 2
} kChannelDetailsModeTemp;

@interface SYNChannelDetailsViewController : SYNAbstractViewController <LXReorderableCollectionViewDelegateFlowLayout,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
SYNSocialActionsDelegate>

@property (nonatomic, assign) kChannelDetailsModeTemp mode;

@property (nonatomic, strong) Channel *channel;
@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;


/**
 If set the channel will automatically play the video on view did load, or when the collection is updated depending on if the video ID
 is present in the channels's video set. Once played, this variabel is set to nil.
 */
@property (nonatomic, strong) NSString *autoplayVideoId;


- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsModeTemp) mode;

//FIXME: FAVOURITES Part of workaound for missing favourites functionality. Remove once final solution implemented.
- (BOOL) isFavouritesChannel;
- (void) refreshFavouritesChannel;

- (IBAction) deleteChannelPressed: (UIButton *) sender;
- (IBAction)followControlPressed:(id)sender;
- (IBAction)shareControlPressed:(id)sender;

@end
