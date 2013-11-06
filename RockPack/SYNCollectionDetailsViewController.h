//
//  SYNAbstractChannelsDetailViewController.h
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractViewController.h"

typedef enum : NSInteger
{
    kChannelDetailsModeDisplay = 0,
    kChannelDetailsModeEdit = 1,
    kChannelDetailsModeCreate = 2
} kChannelDetailsMode;

@interface SYNCollectionDetailsViewController : SYNAbstractViewController <LXReorderableCollectionViewDelegateFlowLayout,
                                                                       UICollectionViewDataSource,
                                                                       UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) kChannelDetailsMode mode;

@property (nonatomic, strong) Channel *channel;

/**
 If set the channel will automatically play the video on view did load, or when the collection is updated depending on if the video ID
 is present in the channels's video set. Once played, this variabel is set to nil.
 */
@property (nonatomic, strong) NSString *autoplayVideoId;


- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsMode) mode;

//FIXME: FAVOURITES Part of workaound for missing favourites functionality. Remove once final solution implemented.
- (BOOL) isFavouritesChannel;
- (void) refreshFavouritesChannel;

- (IBAction) deleteChannelPressed: (UIButton *) sender;

@end
