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
#import "SYNAddToChannelCreateNewCell.h"
#import "SYNCoverChooserController.h"
#import "SYNCoverThumbnailCell.h"
#import "SYNDeviceManager.h"
#import "SYNAddToChannelViewController.h"
#import "SYNImagePickerController.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOnBoardingPopoverQueueController.h"
#import "SYNProfileRootViewController.h"
#import "SYNReportConcernTableViewController.h"
#import "SYNCollectionVideoCell.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "User.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNAvatarButton.h"
#import "SYNModalSubscribersController.h"
#import "SYNUsersViewController.h"
#import "UIButton+WebCache.h"
#import "objc/runtime.h"
#import "SYNSubscribersViewController.h"
#import "SYNAccountSettingsPopoverBackgroundView.h"


static NSString* CollectionVideoCellName = @"SYNCollectionVideoCell";

@import AVFoundation;
@import CoreImage;
@import QuartzCore;

@interface SYNChannelDetailsViewController () <UITextViewDelegate,
SYNImagePickerControllerDelegate,
UIPopoverControllerDelegate,

SYNChannelCoverImageSelectorDelegate>

@property (nonatomic, strong) SYNModalSubscribersController *modalSubscriptionsContainer;
@property (nonatomic, strong) SYNReportConcernTableViewController *reportConcernController;
@property (nonatomic, strong) UIActivityIndicatorView *subscribingIndicator;
@property (nonatomic, strong) UIImage *originalBackgroundImage;
@property (nonatomic, strong) UIImageView *blurredBGImageView;
@property (nonatomic, strong) UIPopoverController *subscribersPopover;
@property (nonatomic, strong) UIView *coverChooserMasterView;
@property (nonatomic, strong) UIView *noVideosMessageView;
@property (nonatomic, weak) Channel *originalChannel;
@property (nonatomic, strong) UIAlertView *deleteChannelAlertView;

//iPhone specific

@property (nonatomic, strong) NSString *selectedImageURL;
@property (nonatomic, strong) SYNChannelCoverImageSelectorViewController *coverImageSelector;

@property (strong, nonatomic) IBOutlet SYNAvatarButton *btnAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lblFullName;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblChannelTitle;
@property (strong, nonatomic) IBOutlet SYNSocialButton *btnFollowChannel;
@property (strong, nonatomic) IBOutlet SYNSocialButton *btnShareChannel;

@property (strong, nonatomic) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (strong, nonatomic) IBOutlet UIButton *btnShowFollowers;
@property (strong, nonatomic) IBOutlet UIButton *btnShowVideos;

@property (strong, nonatomic) IBOutlet UIView *viewProfileContainer;

@property (strong, nonatomic) IBOutlet LXReorderableCollectionViewFlowLayout *videoCollectionViewLayoutIPhone;

@property (strong, nonatomic) IBOutlet LXReorderableCollectionViewFlowLayout *videoCollectionViewLayoutIPhoneEdit;


@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *videoLayoutIPad;
@property (strong, nonatomic) IBOutlet UIView *viewEditMode;

@property (strong, nonatomic) IBOutlet SYNSocialButton *btnEditChannel;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *videoCollectionLayoutIPad;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldDescriptionEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteChannel;
@property (strong, nonatomic) UIBarButtonItem *barBtnBack; // storage for the navigation back button
@property (strong, nonatomic) IBOutlet UIView *borderAboveCollection;
@property (strong, nonatomic) IBOutlet UITextView *txtViewDescription;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldChannelName;
@property (strong, nonatomic) UICollectionViewFlowLayout *videoEditLayoutIPad;
@property (strong, nonatomic) UIBarButtonItem *barBtnCancel;
@property (strong, nonatomic) UIBarButtonItem *barBtnSave;
@end


@implementation SYNChannelDetailsViewController

#pragma mark - Object lifecyle

- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsMode) mode
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
        [self.btnShowFollowers.titleLabel setFont:[UIFont regularCustomFontOfSize:14]];
        [self.btnShowVideos.titleLabel setFont:[UIFont regularCustomFontOfSize:14]];
    }
    
    [self.txtFieldChannelName setFont:[UIFont lightCustomFontOfSize:24]];
    [self.txtViewDescription setFont:[UIFont lightCustomFontOfSize:13]];
    
    [[self.txtViewDescription layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.txtViewDescription layer] setBorderWidth:1.0];
    [[self.txtViewDescription layer] setCornerRadius:0];
    
    self.barBtnCancel = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelTapped)];
    
    self.barBtnSave= [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleBordered target:self action:@selector(save)];
    
    
    [self.videoThumbnailCollectionView registerNib: [UINib nibWithNibName: CollectionVideoCellName bundle: nil]
                        forCellWithReuseIdentifier: CollectionVideoCellName];
    
    // == Footer View == //
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: footerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                               withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    
    
    self.lblFullName.text = self.channel.channelOwner.displayName;
    
    
    self.lblChannelTitle.text = self.channel.title;
    //No cms yet
    self.lblDescription.text = @"Test Description";
    
    
    [self.btnShowFollowers setTitle:[NSString stringWithFormat: @"%lld %@", self.channel.subscribersCountValue, NSLocalizedString(@"FOLLOW", nil)] forState:UIControlStateNormal ];
    
    self.btnShowFollowers.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [self.btnShowVideos setTitle:[NSString stringWithFormat: @"%lu %@", (unsigned long)self.channel.videoInstances.count, NSLocalizedString(@"VIDEOS", nil)] forState:UIControlStateNormal ];
    
    self.btnShowVideos.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (self.mode == kChannelDetailsModeDisplay)
    {
        [tracker set: kGAIScreenName
               value: @"Channel details"];
        
        [tracker send: [[GAIDictionaryBuilder createAppView] build]];
        
    }
    
    
    if (IS_IPAD)
    {
        [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    }
    
    [self setUpMode];
    
    
    // == Avatar Image == //
    
    [self.btnAvatar setImageWithURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailURL]
                           forState: UIControlStateNormal
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                            options: SDWebImageRetryFailed];
    
    NSLog(@"%@", self.channel.channelOwner.thumbnailURL);
    
    self.videoCollectionViewLayoutIPhoneEdit = [[LXReorderableCollectionViewFlowLayout alloc]init];
    
    self.videoCollectionViewLayoutIPhoneEdit.itemSize = CGSizeMake(self.videoCollectionViewLayoutIPhone.itemSize.width, self.videoCollectionViewLayoutIPhone.itemSize.height-70);
    self.videoCollectionViewLayoutIPhoneEdit.headerReferenceSize = CGSizeMake(self.videoCollectionViewLayoutIPhone.headerReferenceSize.width, self.videoCollectionViewLayoutIPhone.headerReferenceSize.height);
    
    self.videoCollectionViewLayoutIPhoneEdit.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    
    
}



- (void) viewWillAppear: (BOOL) animated
{
    
    
    [super viewWillAppear: animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coverImageChangedHandler:)
                                                 name: kCoverArtChanged
                                               object: nil];
    

    
    if (self.channel.channelOwner.uniqueId == appDelegate.currentUser.uniqueId)
    {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(reloadUserImage:)
                                                     name: kUserDataChanged
                                                   object: nil];
    }
  
    
    if (self.channel.subscribedByUserValue)
    {
        [self.btnFollowChannel setTitle:[NSString stringWithFormat: @"%@", NSLocalizedString(@"UNFOLLOW", nil)]];
    }
    else
    {
        [self.btnFollowChannel setTitle:[NSString stringWithFormat: @"%@", NSLocalizedString(@"FOLLOW", nil)]];
    }
    
    
    
    // We set up assets depending on whether we are in display or edit mode
    //    [self setDisplayControlsVisibility: (self.mode == kChannelDetailsModeDisplay)];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
    
    if (self.channel.videoInstances.count == 0 && ![self.channel.uniqueId isEqualToString: kNewChannelPlaceholderId])
    {
        //        [self showNoVideosMessage: NSLocalizedString(@"channel_screen_loading_videos", nil)
        //                       withLoader: YES];
    }
    
    //[self displayChannelDetails];
    
    
    
    //    [self.btnAvatar setImageWithURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailSmallUrl]
    //                           forState: UIControlStateNormal
    //                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
    //                            options: SDWebImageRetryFailed];
    
    
    //    UIImage* placeholderImage = [UIImage imageNamed: @"PlaceholderAvatarProfile"];
    //
    //    NSLog(@"%@", self.channel.channelOwner.thumbnailURL);
    //
    //    if (![self.channel.channelOwner.thumbnailURL isEqualToString:@""]){ // there is a url string
    //
    //        dispatch_queue_t downloadQueue = dispatch_queue_create("com.rockpack.avatarloadingqueue", NULL);
    //        dispatch_async(downloadQueue, ^{
    //
    //            NSData * imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailURL ]];
    //
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                self.btnAvatar.imageView.image = [UIImage imageWithData: imageData];
    //            });
    //        });
    //
    //    }else{
    //
    //        self.btnAvatar.imageView.image = placeholderImage;
    //    }
    
    
    
    
    
    self.navigationController.navigationBarHidden = NO;
    
    if (IS_IPAD)
    {
        self.videoEditLayoutIPad = [[UICollectionViewFlowLayout alloc]init];
        self.videoEditLayoutIPad.itemSize = CGSizeMake(self.videoLayoutIPad.itemSize.width, self.videoLayoutIPad.itemSize.height-50);
        self.videoEditLayoutIPad.headerReferenceSize = self.videoLayoutIPad.headerReferenceSize;
        self.videoEditLayoutIPad.sectionInset = self.videoEditLayoutIPad.sectionInset;
        
    }
    
    
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteHideAllCautions
                                                        object: self];
    
    
    // Remove notifications individually
    // Do this rather than plain RemoveObserver call as low memory handling is based on NSNotifications.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kCoverArtChanged
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kVideoQueueClear
                                                  object: nil];
    
    if (self.channel.channelOwner.uniqueId == appDelegate.currentUser.uniqueId)
    {
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: kUserDataChanged
                                                      object: nil];
    }
    
    
    [self.subscribersPopover dismissPopoverAnimated: NO];
    
    self.subscribersPopover = nil;
    
    if (self.subscribingIndicator)
    {
        [self.subscribingIndicator removeFromSuperview];
        self.subscribingIndicator = nil;
    }
    
    // cancel the existing request if there is one
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                        object: self
                                                      userInfo: nil];
    
    self.navigationController.navigationBarHidden = YES;
}

-(void) setUpMode {
    
    
    NSLog(@"%d", self.mode);
    
    
    if (self.mode == kChannelDetailsModeDisplayUser)
    {
        self.btnEditChannel.hidden = NO;
        self.btnFollowChannel.hidden = YES;
    }
    else if (self.mode == kChannelDetailsModeDisplay)
    {
        self.btnEditChannel.hidden = YES;
        self.btnFollowChannel.hidden = NO;
        
    }
    
    
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
    //   [self.delegate followControlPressed:sender];
    
    // Update google analytics
    
    // Defensive programming
    if (self.channel != nil)
    {
        NSLog(@"%@", self.channel.title);
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                            object: self
                                                          userInfo: @{kChannel : self.channel}];
    }
    
    if (self.channel.subscribedByUserValue)
    {
        [self.btnFollowChannel setTitle:[NSString stringWithFormat: @"%@", NSLocalizedString(@"UNFOLLOW", nil)]];
    }
    else
    {
        [self.btnFollowChannel setTitle:[NSString stringWithFormat: @"%@", NSLocalizedString(@"FOLLOW", nil)]];
    }
    
}

- (void) addSubscribeActivityIndicator
{
    //    self.subscribingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    //    self.subscribingIndicator.center = self.btnFollowChannel.center;
    //    [self.subscribingIndicator startAnimating];
    //    [self.view addSubview: self.subscribingIndicator];
}

- (IBAction)shareControlPressed:(id)sender
{
    
    
    [super shareControlPressed: sender];
    
}


-(void) setUpFollowButton
{
    self.btnFollowChannel.title = @"";
    
    
    
    
}

#pragma mark - ScrollView Delegate

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    // TODO: Implement rest if needed
    
    
    CGFloat offset = scrollView.contentOffset.y;
    
    if (IS_IPHONE) {
        
        CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset*2);
        
        self.viewProfileContainer.transform = move;
        self.borderAboveCollection.transform = move;
        self.viewEditMode.transform = move;
        
        
    }
    else
    {
//        CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
//        
//        self.viewProfileContainer.transform = move;
//        self.viewEditMode.transform = move;
//        
        
    }
    
    NSLog(@"%f", offset);
}

#pragma mark - Tab View Methods

- (void) setChannel: (Channel *) channel
{
    self.originalChannel = channel;
    
    
    NSError *error = nil;
    
    if (!appDelegate)
    {
        appDelegate = UIApplication.sharedApplication.delegate;
    }
    
    if (self.channel)
    {
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: NSManagedObjectContextDidSaveNotification
                                                      object: self.channel.managedObjectContext];
    }
    
    _channel = channel;
    
    if (!self.channel)
    {
        return;
    }
    
    // create a copy that belongs to this viewId (@"ChannelDetails")
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: channel.managedObjectContext]];
    
    [channelFetchRequest setPredicate: [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", channel.uniqueId, self.viewId]];
    
    
    NSArray *matchingChannelEntries = [channel.managedObjectContext
                                       executeFetchRequest: channelFetchRequest
                                       error: &error];
    
    if (matchingChannelEntries.count > 0)
    {
        _channel = (Channel *) matchingChannelEntries[0];
        _channel.markedForDeletionValue = NO;
        
        if (matchingChannelEntries.count > 1) // housekeeping, there can be only one!
        {
            for (int i = 1; i < matchingChannelEntries.count; i++)
            {
                [channel.managedObjectContext
                 deleteObject: (matchingChannelEntries[i])];
            }
        }
    }
    else
    {
        // the User will be copyed over, but as a ChannelOwner, so "current" will not be set to YES
        _channel = [Channel	 instanceFromChannel: channel
                                       andViewId: self.viewId
                       usingManagedObjectContext: channel.managedObjectContext
                             ignoringObjectTypes: kIgnoreNothing];
        
        if (_channel)
        {
            [_channel.managedObjectContext
             save: &error];
            
            if (error)
            {
                _channel = nil; // further error code
            }
        }
    }
    
    if (self.channel)
    {
        // check for subscribed
        self.channel.subscribedByUserValue = NO;
        
        for (Channel *subscription in appDelegate.currentUser.subscriptions)
        {
            if ([subscription.uniqueId
                 isEqualToString: self.channel.uniqueId])
            {
                self.channel.subscribedByUserValue = YES;
            }
        }
        
        if ([self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
        {
            [self updateChannelOwnerWithUser];
            
            // set the request to maximum
            
            self.dataRequestRange = NSMakeRange(0, MAXIMUM_REQUEST_LENGTH);
        }
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.channel.managedObjectContext];
        
                if (self.mode == kChannelDetailsModeDisplay)
                {
        
                    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                                        object: self
                                                                      userInfo: @{kChannel: self.channel}];
                }
    }
}



- (void) updateChannelOwnerWithUser
{
    BOOL dateDirty = NO;
    
    if (![self.channel.channelOwner.displayName isEqualToString: appDelegate.currentUser.displayName])
    {
        self.channel.channelOwner.displayName = appDelegate.currentUser.displayName;
        dateDirty = YES;
    }
    
    if (![self.channel.channelOwner.thumbnailURL isEqualToString: appDelegate.currentUser.thumbnailURL])
    {
        self.channel.channelOwner.thumbnailURL = appDelegate.currentUser.thumbnailURL;
        dateDirty = YES;
    }
    
    if (dateDirty) // save
    {
        NSError *error;
        [self.channel.channelOwner.managedObjectContext
         save: &error];
        
        if (!error)
        {
            //[self displayChannelDetails];
        }
        else
        {
            DebugLog(@"%@", [error description]);
        }
    }
}


#pragma mark - Data Model Change

- (void) handleDataModelChange: (NSNotification *) notification
{
    NSArray *updatedObjects = [notification userInfo][NSUpdatedObjectsKey];
    
    NSArray *deletedObjects = [notification userInfo][NSDeletedObjectsKey]; // our channel has been deleted
    
    if ([deletedObjects containsObject: self.channel])
    {
        return;
    }
    
    [updatedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (obj == self.channel)
        {
            self.dataItemsAvailable = self.channel.totalVideosValue;
            
            
            self.btnFollowChannel.selected = self.channel.subscribedByUserValue;
            
            if (self.subscribingIndicator)
            {
                [self.subscribingIndicator removeFromSuperview];
                self.subscribingIndicator = nil;
            }
            
            [self reloadCollectionViews];
            
            if (self.channel.videoInstances.count == 0)
            {
                //                [self showNoVideosMessage: NSLocalizedString(@"channel_screen_no_videos", nil)
                //                               withLoader: NO];
            }
            else
            {
                //                [self showNoVideosMessage: nil
                //                               withLoader: NO];
            }
            
            return;
        }
        else if ([obj isKindOfClass: [User class]] && [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
        {
            [self updateChannelOwnerWithUser];
        }
    }];
    
    
    
    //    if ((self.channel.channelOwner.displayName !=  nil) && (self.channelOwnerLabel.text == nil))
    //    {
    //        [self displayChannelDetails];
    //    }
    
}



- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
    
    // [self displayChannelDetails];
    
    
    
}



#pragma mark - Collection Delegate/Data Source Methods

- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return self.channel.videoInstances.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    SYNCollectionVideoCell *videoThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: CollectionVideoCellName
                                                                                           forIndexPath: indexPath];
    
    
    VideoInstance *videoInstance = self.channel.videoInstances [indexPath.item];
    
    
    [videoThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                                 placeholderImage: [UIImage imageNamed: @"PlaceholderVideoWide.png"]
                                          options: SDWebImageRetryFailed];
    
    videoThumbnailCell.titleLabel.text = videoInstance.title;
    videoThumbnailCell.delegate = self;
    
    if (self.mode == kChannelDetailsModeEdit) {
        videoThumbnailCell.likeControl.hidden = YES;
        videoThumbnailCell.shareControl.hidden = YES;
        videoThumbnailCell.addControl.hidden = YES;
        videoThumbnailCell.deleteButton.hidden = NO;
    }
    else
    {
        videoThumbnailCell.likeControl.hidden = NO;
        videoThumbnailCell.shareControl.hidden = NO;
        videoThumbnailCell.addControl.hidden = NO;
        videoThumbnailCell.deleteButton.hidden = YES;
        
    }
    
    videoThumbnailCell.delegate = self;
    
    return videoThumbnailCell;
}


//- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
//            viewForSupplementaryElementOfKind: (NSString *) kind
//                                  atIndexPath: (NSIndexPath *) indexPath
//{
//    UICollectionReusableView *supplementaryView;
//
//    if (kind == UICollectionElementKindSectionFooter)
//    {
//        self.footerView = [self.videoThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
//                                                                                withReuseIdentifier: @"SYNChannelFooterMoreView"
//                                                                                       forIndexPath: indexPath];
//
//        supplementaryView = self.footerView;
//
//        if (self.channel.videoInstances.count > 0 && self.moreItemsToLoad)
//        {
//            self.footerView.showsLoading = self.isLoadingMoreContent;
//        }
//    }
//
//    return supplementaryView;
//}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout *) collectionViewLayout
referenceSizeForFooterInSection: (NSInteger) section
{
    CGSize footerSize;
    
    if (collectionView == self.videoThumbnailCollectionView &&
        self.channel.videoInstances.count != 0)
    {
        footerSize = [self footerSize];
        
        
        if (self.moreItemsToLoad)
        {
            footerSize = CGSizeMake(1.0f, 5.0f);
        }
    }
    else
    {
        footerSize = CGSizeZero;
    }
    
    return footerSize;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//
//    //    if (IS_IPAD && !self.viewEditMode.hidden)
//    //    {
//    //        CGSize tmp = self.videoCollectionLayoutIPad.itemSize;
//    //        tmp.height -= 50;
//    //
//    //        return tmp;
//    //    }
//
//    if (IS_IPAD) {
//        return self.videoCollectionLayoutIPad.itemSize;
//
//    }
//
//    if (IS_IPHONE)
//    {
//        return self.videoCollectionViewLayoutIPhone.itemSize;
//
//    }
//
//
//    return CGSizeZero;
//}

- (void) loadMoreVideos
{
    if(!self.moreItemsToLoad)
        return;
    
    
    self.loadingMoreContent = YES;
    
    
    [self incrementRangeForNextRequest];
    
    __weak typeof(self) weakSelf = self;
    
    MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
        weakSelf.loadingMoreContent = NO;
        
        [weakSelf.channel addVideoInstancesFromDictionary: dictionary];
        
        NSError *error;
        [weakSelf.channel.managedObjectContext
         save: &error];
    };
    
    // define success block //
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        weakSelf.loadingMoreContent = NO;
        DebugLog(@"Update action failed");
    };
    
    if ([self.channel.resourceURL hasPrefix: @"https"]) // https does not cache so it is fresh
    {
        [appDelegate.oAuthNetworkEngine videosForChannelForUserId: appDelegate.currentUser.uniqueId
                                                        channelId: self.channel.uniqueId
                                                          inRange: self.dataRequestRange
                                                completionHandler: successBlock
                                                     errorHandler: errorBlock];
    }
    else
    {
        [appDelegate.networkEngine videosForChannelForUserId: appDelegate.currentUser.uniqueId
                                                   channelId: self.channel.uniqueId
                                                     inRange: self.dataRequestRange
                                           completionHandler: successBlock
                                                errorHandler: errorBlock];
    }
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // the method is being replaced by the 'videoButtonPressed' because other elements on the cell migth be interactive as well
}

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self updateLayoutForOrientation: toInterfaceOrientation];
}


- (void) updateLayoutForOrientation: (UIDeviceOrientation) orientation
{
    if (IS_IPAD) {
        if (UIDeviceOrientationIsPortrait(orientation))
        {
            self.videoCollectionLayoutIPad.headerReferenceSize = CGSizeMake(670, 557);
            self.videoCollectionLayoutIPad.sectionInset = UIEdgeInsetsMake(2, 40, 2, 40);
        }
        else
        {
            self.videoCollectionLayoutIPad.headerReferenceSize = CGSizeMake(927, 463);
            self.videoCollectionLayoutIPad.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        }
    }
}

- (void) videoButtonPressed: (UIButton *) videoButton
{
    UIView *candidateCell = videoButton;
    
    while (![candidateCell isKindOfClass: [SYNCollectionVideoCell class]])
    {
        candidateCell = candidateCell.superview;
    }
    
    SYNCollectionVideoCell *selectedCell = (SYNCollectionVideoCell *) candidateCell;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
    
    SYNMasterViewController *masterViewController = (SYNMasterViewController *) appDelegate.masterViewController;
    
    NSArray *videoInstancesToPlayArray = self.channel.videoInstances.array;
    
    [masterViewController addVideoOverlayToViewController: self
                                   withVideoInstanceArray: videoInstancesToPlayArray
                                         andSelectedIndex: indexPath.item
                                               fromCenter: self.view.center];
}



#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void) collectionView: (UICollectionView *) collectionView
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath
{
    VideoInstance *viToSwap = (self.channel.videoInstancesSet)[fromIndexPath.item];
    
    [self.channel.videoInstancesSet removeObjectAtIndex: fromIndexPath.item];
    
    [self.channel.videoInstancesSet insertObject: viToSwap
                                         atIndex: toIndexPath.item];
    
    // set the new positions
    [self.channel.videoInstances enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL *stop) {
        [(VideoInstance *) obj setPositionValue : index];
    }];
}



#pragma mark - KVO support

// We fade out all controls/information views when the user starts scrolling the videos collection view
// by monitoring the collectionview content offset using KVO
- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    if ([keyPath isEqualToString: kTextViewContentSizeKey]){
        UITextView *tv = object;
        
        // Bottom vertical alignment
        CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height);
        
        // topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);
        
        [tv setContentOffset: (CGPoint) { .x = 0, .y = -topCorrect}
                    animated: NO];
    }
}


- (void) fetchAndStoreUpdatedChannelForId: (NSString *) channelId
                                 isUpdate: (BOOL) isUpdate
{
    [appDelegate.oAuthNetworkEngine channelCreatedForUserId: appDelegate.currentOAuth2Credentials.userId
                                                  channelId: channelId
                                          completionHandler: ^(id dictionary) {
                                              
                                              Channel *createdChannel;
                                              
                                              if (!isUpdate) // its a new creation
                                              {
                                                  
                                                  createdChannel = [Channel instanceFromDictionary: dictionary
                                                                         usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                                               ignoringObjectTypes: kIgnoreChannelOwnerObject];
                                                  
                                                  // this will automatically add the channel to the set of channels of the User
                                                  [appDelegate.currentUser.channelsSet
                                                   addObject: createdChannel];
                                                  
                                                  if ([createdChannel.categoryId isEqualToString: @""])
                                                  {
                                                      createdChannel.publicValue = NO;
                                                  }
                                                  
                                                  Channel * oldChannel = self.channel;
                                                  
                                                  self.channel = createdChannel;
                                                  
                                                  self.originalChannel = self.channel;
                                                  
                                                  [oldChannel.managedObjectContext deleteObject: oldChannel];
                                                  
                                                  NSError *error;
                                                  
                                                  [oldChannel.managedObjectContext save: &error];
                                              }
                                              else
                                              {
                                                  [Appirater userDidSignificantEvent: FALSE];
                                                  
                                                  [self.channel setAttributesFromDictionary: dictionary
                                                                        ignoringObjectTypes: kIgnoreChannelOwnerObject];
                                                  
                                                  // if editing the user's channel we must update the original
                                                  
                                                  [self.originalChannel setAttributesFromDictionary: dictionary
                                                                                ignoringObjectTypes: kIgnoreChannelOwnerObject];
                                              }
                                              
                                              [appDelegate saveContext: YES];
                                              
                                              // Complete Channel Creation //
                                              
                                              self.mode = kChannelDetailsModeDisplay;
                                              
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kNoteAllNavControlsShow
                                                                                                   object: self
                                                                                                 userInfo: nil];
                                              
                                              //                                              [self finaliseViewStatusAfterCreateOrUpdate: !self.isIPhone];
                                              
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kVideoQueueClear
                                                                                                   object: nil];
                                              
                                              [self notifyForChannelCreation: self.channel];
                                              
                                              self.isLocked = NO;
                                          } errorHandler: ^(id err) {
                                              self.isLocked = NO;
                                              
                                              //                                              DebugLog(@"Error @ getNewlyCreatedChannelForId:");
                                              //                                              [self	  showError: NSLocalizedString(@"Could not retrieve the uploaded channel data. Please try accessing it from your profile later.", nil)
                                              //                                                 showErrorTitle: @"Error"];
                                              
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kNoteAllNavControlsShow
                                                                                                   object: self
                                                                                                 userInfo: nil];
                                              
                                              //                                              [self finaliseViewStatusAfterCreateOrUpdate: !self.isIPhone];
                                              
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kVideoQueueClear
                                                                                                   object: nil];
                                          }];
}


- (void) notifyForChannelCreation: (Channel *) channelCreated
{
    // == Decide on the success message type shown == //
    NSNotification *successNotification = [NSNotification notificationWithName: kNoteChannelSaved
                                                                        object: self];
    
    
    SYNCaution *caution;
    CautionCallbackBlock actionBlock;
    NSMutableArray *conditionsArray = [NSMutableArray arrayWithCapacity: 3];
    NSString *buttonString;
    int numberOfConditions = 0;
    __weak SYNChannelDetailsViewController *wself = self;
    
    if (channelCreated) // channelCreated will always be true in this implementation, change from self.channels to show message only on creation and not on update
    {
        if (self.channel.title.length > 8 && [[self.channel.title substringToIndex: 8] isEqualToString: @"UNTITLED"])                  // no title
        {
            [conditionsArray addObject: NSLocalizedString(@"private_condition_title", nil)];
            buttonString = NSLocalizedString(@"enter_title", nil);
            actionBlock = ^{
                [wself setMode: kChannelDetailsModeEdit];
                //  [wself editButtonTapped: wself.editButton];
                //[wself.channelTitleTextView becomeFirstResponder];
            };
            numberOfConditions++;
        }
        
        if ([self.channel.categoryId isEqualToString: @""])
        {
            [conditionsArray addObject: NSLocalizedString(@"private_condition_category", nil)];
            buttonString = NSLocalizedString(@"select_category", nil);
            actionBlock = ^{
                [wself setMode: kChannelDetailsModeEdit];
                //                [wself editButtonTapped: wself.editButton];
                //                [wself selectCategoryButtonTapped: wself.selectCategoryButton];
            };
            numberOfConditions++;
        }
        
        if ([self.channel.channelCover.imageUrl isEqualToString: @""])
        {
            [conditionsArray addObject: NSLocalizedString(@"private_condition_cover", nil)];
            buttonString = NSLocalizedString(@"select_cover", nil);
            actionBlock = ^{
                [wself setMode: kChannelDetailsModeEdit];
                //                [wself editButtonTapped: wself.editButton];
                //                [wself addCoverButtonTapped: wself.addCoverButton];
            };
            numberOfConditions++;
        }
        
        NSMutableString *conditionString;
        switch (numberOfConditions)
        {
            case 0 :
                
                break;
                
            case 1 :
                conditionString = [NSMutableString stringWithString: NSLocalizedString(@"channel_will_remain_private_until", nil)];
                [conditionString appendString: conditionsArray[0]];
                break;
                
            case 2:
                conditionString = [NSMutableString stringWithString: NSLocalizedString(@"channel_will_remain_private_until", nil)];
                [conditionString appendString: conditionsArray[0]];
                [conditionString appendString: @" AND "];
                [conditionString appendString: conditionsArray[1]];
                break;
                
            case 3:
                conditionString = [NSMutableString stringWithString: NSLocalizedString(@"channel_will_remain_private_until", nil)];
                [conditionString appendString: conditionsArray[0]];
                [conditionString appendString: @", "];
                [conditionString appendString: conditionsArray[1]];
                [conditionString appendString: @" AND "];
                [conditionString appendString: conditionsArray[2]];
                break;
        }
        
        if (numberOfConditions > 0)
        {
            if (numberOfConditions > 1)
            {
                buttonString = @"EDIT";
                actionBlock = ^{
                    //                    [wself setMode: kChannelDetailsModeEdit];
                    //                    [wself editButtonTapped: wself.editButton];
                };
            }
            
            caution = [SYNCaution withMessage: (NSString *) conditionString
                                  actionTitle: buttonString
                                  andCallback: actionBlock];
            
            successNotification = [NSNotification notificationWithName: kNoteSavingCaution
                                                                object: self
                                                              userInfo: @{kCaution: caution}];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotification: successNotification];
}




- (IBAction)avatarTapped:(id)sender
{
    
    SYNProfileRootViewController *profileVC = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId WithMode:OtherUsersProfile andChannelOwner:self.channel.channelOwner];
    
    
    NSLog(@"%@", self.channel);
    
    
    
    NSLog(@"%@", profileVC.channelOwner);
    
    [self.navigationController pushViewController:profileVC animated:YES];
    
    
}

- (IBAction)editTapped:(id)sender
{
    self.viewProfileContainer.hidden = YES;
    self.viewEditMode.alpha = 0.0f;
    self.viewEditMode.hidden = NO;
    
    
    
    
    [UIView animateWithDuration:0.4 animations:^{
        self.viewEditMode.alpha = 1.0f;
        
    }];
    
    

    [self.videoThumbnailCollectionView setCollectionViewLayout:self.videoCollectionViewLayoutIPhoneEdit animated:YES];
    
    self.barBtnBack = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = self.barBtnCancel;
    self.navigationItem.rightBarButtonItem = self.barBtnSave;
    
    self.mode = kChannelDetailsModeEdit;
    
    for (SYNCollectionVideoCell *videoThumbnailCell in [self.videoThumbnailCollectionView visibleCells])
    {
        
        
        
        [UIView animateWithDuration:0.2 animations:^{
            
            videoThumbnailCell.likeControl.alpha = 0.0f;
            videoThumbnailCell.shareControl.alpha = 0.0f;
            videoThumbnailCell.addControl.alpha = 0.0f;
            videoThumbnailCell.deleteButton.alpha = 1.0f;
            
        }];
        
        videoThumbnailCell.likeControl.hidden = YES;
        videoThumbnailCell.shareControl.hidden = YES;
        videoThumbnailCell.addControl.hidden = YES;
        videoThumbnailCell.deleteButton.hidden = NO;
    }
    
    
    [self.videoThumbnailCollectionView reloadData];
    
}

-(void) cancelTapped
{
    
    NSLog(@"cancel");
    
    self.navigationItem.leftBarButtonItem = self.barBtnBack;
    self.viewProfileContainer.hidden = NO;
    
    self.viewProfileContainer.alpha = 0.0f;
    
    
    [UIView animateWithDuration:0.4 animations:^{
        self.viewProfileContainer.alpha = 1.0f;
        self.navigationItem.rightBarButtonItem = nil;
    }];
    
    
    self.viewEditMode.hidden = YES;
    
    self.mode = kChannelDetailsModeDisplayUser;
    
    
    [self.txtFieldChannelName resignFirstResponder];
    [self.txtFieldDescriptionEdit resignFirstResponder];
    
    [self.videoThumbnailCollectionView setCollectionViewLayout:self.videoCollectionViewLayoutIPhone animated:YES];
    
    [self.videoCollectionViewLayoutIPhone invalidateLayout];
    
    
    for (SYNCollectionVideoCell *videoThumbnailCell in [self.videoThumbnailCollectionView visibleCells])
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            videoThumbnailCell.likeControl.alpha = 1.0f;
            videoThumbnailCell.shareControl.alpha = 1.0f;
            videoThumbnailCell.addControl.alpha = 1.0f;
            videoThumbnailCell.deleteButton.alpha = 0.0f;
            
        }];
        
        videoThumbnailCell.likeControl.hidden = NO;
        videoThumbnailCell.shareControl.hidden = NO;
        videoThumbnailCell.addControl.hidden = NO;
        videoThumbnailCell.deleteButton.hidden = YES;
    }
    
    
    [self.videoThumbnailCollectionView reloadData];
    
    
}

- (IBAction)deleteTapped:(id)sender
{

    
    NSString *message = [NSString stringWithFormat: NSLocalizedString(@"DELETECHANNEL", nil), self.channel.title];
    NSString *title = [NSString stringWithFormat: NSLocalizedString(@"AREYOUSUREYOUWANTTODELETE", nil), self.channel.title];
    
    self.deleteChannelAlertView = [[UIAlertView alloc] initWithTitle: title
                                                             message: message
                                                            delegate: self
                                                   cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                                   otherButtonTitles: NSLocalizedString(@"Delete", nil), nil];
    [self.deleteChannelAlertView show];




}


- (void) alertView: (UIAlertView *) alertView
willDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (alertView == self.deleteChannelAlertView)
    {
        if (buttonIndex == 1)
        {
            [self deleteChannel];
        }
    }
    else
    {
        if (buttonIndex == 0)
        {
            // cancel, do nothing
            DebugLog(@"Delete cancelled");
        }
        else
        {
          //  [self deleteVideoInstance];
        }
    }
}


- (void) deleteChannel
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                        object: self
                                                      userInfo: nil];
    
    // return to previous screen as if the back button tapped
    
    
        [appDelegate.oAuthNetworkEngine deleteChannelForUserId: appDelegate.currentUser.uniqueId
                                                     channelId: self.channel.uniqueId
                                             completionHandler: ^(id response) {
                                                 
                                                 [appDelegate.currentUser.channelsSet removeObject: self.channel];
                                                 [self.channel.managedObjectContext deleteObject: self.channel];
                                                 [self.originalChannel.managedObjectContext deleteObject:self.originalChannel];
                                                 
                                                 // bring back controls
                                                 
                                                 
                                                 [appDelegate saveContext: YES];
                                                 
                                                 
                                                 
                                             } errorHandler: ^(id error) {
                                                 
                                                 DebugLog(@"Delete channel failed");
                                                 
                                             }];
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    }



- (IBAction) followersLabelPressed: (id) sender
{
    // [self releasedSubscribersLabel: sender];
    
    if (self.subscribersPopover)
    {
        return;
    }
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Subscribers List"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    SYNSubscribersViewController *subscribersViewController = [[SYNSubscribersViewController alloc] initWithChannel: self.channel];
    
    if (IS_IPAD)
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: subscribersViewController];
        navigationController.view.backgroundColor = [UIColor clearColor];
        
        
        self.subscribersPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
        
        self.subscribersPopover.popoverBackgroundViewClass = [SYNAccountSettingsPopoverBackgroundView class];
        
        self.subscribersPopover.popoverContentSize = CGSizeMake(514, 626);
        self.subscribersPopover.delegate = self;
        
        
        CGRect rect = CGRectMake([SYNDeviceManager.sharedInstance currentScreenWidth] * 0.5,
                                 480.0f, 1, 1);
        
        
        [self.subscribersPopover presentPopoverFromRect: rect
                                                 inView: self.view
                               permittedArrowDirections: 0
                                               animated: YES];
    }
    else
    {
        self.modalSubscriptionsContainer = [[SYNModalSubscribersController alloc] initWithContentViewController: subscribersViewController];
        
		SYNMasterViewController *masterViewController = appDelegate.masterViewController;
		[masterViewController addOverlayController:self.modalSubscriptionsContainer animated:NO];
    }
}

#pragma mark - Text Field Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
    
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 20) ? NO : YES;
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 120) ? NO : YES;
}





@end
