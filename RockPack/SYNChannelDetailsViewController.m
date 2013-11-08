//
//  SYNChannelDetailsViewController.m
//  dolly
//
//  Created by Cong on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelDetailsViewController.h"
#import "Appirater.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "CoverArt.h"
#import "GAI.h"
#import "Genre.h"
#import "SSTextView.h"
#import "SYNAppDelegate.h"
#import "SYNCaution.h"
#import "SYNChannelCoverImageSelectorViewController.h"
#import "SYNChannelCreateNewCell.h"
#import "SYNCoverChooserController.h"
#import "SYNCoverThumbnailCell.h"
#import "SYNDeviceManager.h"
#import "SYNExistingCollectionsViewController.h"
#import "SYNImagePickerController.h"
#import "SYNMasterViewController.h"
#import "SYNModalSubscribersController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOnBoardingPopoverQueueController.h"
#import "SYNProfileRootViewController.h"
#import "SYNReportConcernTableViewController.h"
#import "SYNSubscribersViewController.h"
#import "SYNCollectionVideoCell.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "User.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNAvatarButton.h"

static NSString* CollectionVideoCellName = @"SYNCollectionVideoCell";

@import AVFoundation;
@import CoreImage;
@import QuartzCore;

@interface SYNChannelDetailsViewController () <UITextViewDelegate,
SYNImagePickerControllerDelegate,
UIPopoverControllerDelegate,

SYNChannelCoverImageSelectorDelegate>

@property (nonatomic, strong) UIAlertView *deleteChannelAlertView;
@property (strong, nonatomic) IBOutlet SYNAvatarButton *btnAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lblFullName;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblChannelTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblFollowersCount;
@property (strong, nonatomic) IBOutlet UILabel *lblVideosCount;
@property (strong, nonatomic) IBOutlet SYNSocialButton *btnFollow;
@property (strong, nonatomic) IBOutlet SYNSocialButton *btnShare;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionVideoInstances;

@end


@implementation SYNChannelDetailsViewController

#pragma mark - Object lifecyle

- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsModeTemp) mode
{
    if ((self = [super initWithViewId: kChannelDetailsViewId]))
    {
        self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
        
        // mode must be set first because setChannel relies on it...
        self.mode = mode;
        self.channel = channel;
    }
    
    return self;
}


- (void) dealloc
{
}


#pragma mark - View lifecyle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPHONE) {
        [self.lblFullName setFont:[UIFont regularCustomFontOfSize:13]];
        
        [self.lblChannelTitle setFont:[UIFont regularCustomFontOfSize:24]];
        [self.lblDescription setFont:[UIFont lightCustomFontOfSize:13]];
        [self.lblFollowersCount setFont:[UIFont regularCustomFontOfSize:14]];
        [self.lblVideosCount setFont:[UIFont regularCustomFontOfSize:14]];
    }
    
    
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
}


- (IBAction) deleteChannelPressed: (UIButton *) sender
{
    NSString *message = [NSString stringWithFormat: NSLocalizedString(@"profile_screen_channel_delete_dialog_description", nil), self.channel.title];
    NSString *title = [NSString stringWithFormat: NSLocalizedString(@"profile_screen_channel_delete_dialog_title", nil), self.channel.title];
    
    self.deleteChannelAlertView = [[UIAlertView alloc] initWithTitle: title
                                                             message: message
                                                            delegate: self
                                                   cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                                   otherButtonTitles: NSLocalizedString(@"Delete", nil), nil];
    [self.deleteChannelAlertView show];
}

- (BOOL) isFavouritesChannel
{
    return [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId] && self.channel.favouritesValue;
}

- (void) refreshFavouritesChannel
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                        object: self
                                                      userInfo: @{kChannel: self.channel}];
}
- (IBAction)followControlPressed:(id)sender
{
    [self.delegate followControlPressed:sender];
}

- (IBAction)shareControlPressed:(id)sender
{
    [self.delegate shareControlPressed: sender];

}

@end
