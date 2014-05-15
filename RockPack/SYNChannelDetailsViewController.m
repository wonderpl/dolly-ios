//
//  SYNChannelDetailsViewController.m
//  dolly
//
//  Created by Cong on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNActivityManager.h"

#import "SYNChannelDetailsViewController.h"
#import "Appirater.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNImagePickerController.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNCollectionVideoCell.h"
#import "UIFont+SYNFont.h"
#import <UIImageView+WebCache.h>
#import "User.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNVideoPlayerAnimator.h"
#import <UIButton+WebCache.h>
#import "SYNSubscribersViewController.h"
#import "UIColor+SYNColor.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNProfileRootViewController.h"
#import "SYNChannelVideosModel.h"
#import "SYNVideoPlayerViewController.h"
#import "UINavigationBar+Appearance.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNCollectectionDetailsOverlayViewController.h"
#import "SYNTrackingManager.h"
#import "SYNGenreManager.h"
#import "SYNStaticModel.h"
#import "UIPlaceHolderTextView.h"

#define kHeightChange 40.0f
#define FULL_NAME_LABEL_IPHONE 147.0f
#define FULL_NAME_LABEL_IPAD_PORTRAIT 252.0f
#define FULLNAMELABELIPADLANDSCAPE 258.0f


@interface SYNChannelDetailsViewController () <UITextViewDelegate, LXReorderableCollectionViewDelegateFlowLayout, SYNImagePickerControllerDelegate, SYNPagingModelDelegate, SYNVideoPlayerAnimatorDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *subscribingIndicator;
@property (nonatomic, weak) Channel *originalChannel;
@property (nonatomic, strong) UIAlertView *deleteChannelAlertView;
@property (strong, nonatomic) IBOutlet UIButton *btnAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lblFullName;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblChannelTitle;
@property (strong, nonatomic) IBOutlet SYNSocialButton *btnFollowChannel;
@property (strong, nonatomic) IBOutlet SYNSocialButton *btnShareChannel;

@property (strong, nonatomic) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (strong, nonatomic) IBOutlet UIButton *btnShowFollowers;
@property (strong, nonatomic) IBOutlet UIButton *btnShowVideos;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *txtViewTitle;

@property (strong, nonatomic) IBOutlet UIView *viewProfileContainer;

@property (strong, nonatomic) LXReorderableCollectionViewFlowLayout *videoCollectionViewLayoutIPhoneEdit;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *videoCollectionViewLayoutIPhone;


@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *videoCollectionViewLayoutIPad;
@property (strong, nonatomic) LXReorderableCollectionViewFlowLayout *videoCollectionViewLayoutIPadEdit;

@property (strong, nonatomic) IBOutlet UILabel *lblNoVideos;

@property (nonatomic, strong) NSIndexPath *indexPathToDelete;
@property (strong, nonatomic) IBOutlet SYNSocialButton *btnEditChannel;
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteChannel;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *txtViewDescription;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldChannelName;
@property (strong, nonatomic) UIBarButtonItem *barBtnCancel;
@property (strong, nonatomic) UIBarButtonItem *barBtnSave;
@property (strong, nonatomic) UITapGestureRecognizer *tapToHideKeyoboard;
@property (strong, nonatomic) IBOutlet UIView *viewCirleButtonContainer;
@property (strong, nonatomic) IBOutlet UIView *viewFollowAndVideoContainer;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) SYNChannelVideosModel *model;

@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;

@end


@implementation SYNChannelDetailsViewController

#pragma mark - Object lifecyle

- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsMode) mode
{
    if ((self = [super initWithViewId: kChannelDetailsViewId]))
    {
        // mode must be set first because setChannel relies on it...
        self.mode = mode;
        self.channel = channel;
		self.model = [SYNChannelVideosModel modelWithChannel:channel];
    }
    
    return self;
}

#pragma mark - View lifecyle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPAD) {
        [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    }
    
    if (IS_IPHONE) {
        self.videoCollectionViewLayoutIPhone.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    }
	
	if (IS_IPHONE) {
        self.videoCollectionViewLayoutIPhoneEdit = [[LXReorderableCollectionViewFlowLayout alloc]init];
        self.videoCollectionViewLayoutIPhoneEdit.itemSize = CGSizeMake(295,268-kHeightChange);
    }
    
    if (IS_IPAD) {
        self.videoCollectionViewLayoutIPadEdit = [[LXReorderableCollectionViewFlowLayout alloc]init];
        self.videoCollectionViewLayoutIPadEdit.itemSize = CGSizeMake(295, 268-kHeightChange);
        self.videoCollectionViewLayoutIPadEdit.sectionInset = UIEdgeInsetsMake(0, 35, 0, 35);
    }
    self.barBtnCancel = [[UIBarButtonItem alloc]initWithTitle:@"cancel"
                                                        style:UIBarButtonItemStyleBordered
                                                       target:self
                                                       action:@selector(cancelTapped)];
    
    self.barBtnSave= [[UIBarButtonItem alloc] initWithTitle:@"save"
                                                      style:UIBarButtonItemStyleBordered
                                                     target:self
                                                     action:@selector(saveTapped)];
    
    if (IS_IPHONE) {
        self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(470, 0, 0, 0);
        self.offsetValue = 470;
    }
    
    if (IS_IPAD) {
        self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(530, 0, 0, 0);
        self.offsetValue = 530;
    }
    
    
    
    self.tapToHideKeyoboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self displayChannelDetails];
    
    [self.navigationController.navigationBar setBackgroundTransparent:YES];

}

- (void)viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
	[self.txtViewDescription setPlaceHolderLabelFont:[UIFont regularCustomFontOfSize:self.txtViewDescription.font.pointSize]];
	self.txtViewDescription.placeholder = @"Change collection details";
	self.txtViewTitle.placeholder = @"Change collection titile";
    self.btnShowVideos.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [self.videoThumbnailCollectionView reloadData];
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    
    [self setUpMode];
    
    [self setupFonts];
    self.navigationItem.title = @"";


	self.model.delegate = self;
    [self.navigationController.navigationBar setBackgroundTransparent:YES];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	Genre *genre = [[SYNGenreManager sharedManager] genreWithId:self.channel.categoryId];
	[[SYNTrackingManager sharedManager] setCategoryDimension:genre.name];
	
	if ([self.channel.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId]) {
		[[SYNTrackingManager sharedManager] setChannelRelationDimension:@"own"];
		[[SYNTrackingManager sharedManager] trackOwnCollectionScreenView];
	} else {
		NSString *subscriptionStatus = (self.channel.subscribedByUserValue ? @"subscribed" : @"unsubscribed");
		[[SYNTrackingManager sharedManager] setChannelRelationDimension:subscriptionStatus];
		[[SYNTrackingManager sharedManager] trackOtherUserCollectionScreenView];
	}
}

- (void)viewWillDisappear: (BOOL) animated {
    [super viewWillDisappear: animated];
    if (IS_IPHONE) {
        [self.navigationController.navigationBar setBackgroundTransparent:NO];
    }
	
    // Remove notifications individually
    // Do this rather than plain RemoveObserver call as low memory handling is based on NSNotifications.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kVideoQueueClear
                                                  object: nil];
    
    if (self.channel.channelOwner.uniqueId == appDelegate.currentUser.uniqueId) {
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: kUserDataChanged
                                                      object: nil];
    }
    
    if (self.subscribingIndicator) {
        [self.subscribingIndicator removeFromSuperview];
        self.subscribingIndicator = nil;
    }
	
}

- (NSString *)trackingScreenName {
	return @"Collection";
}

- (void)setupFonts {
	[self.lblFullName setFont:[UIFont boldCustomFontOfSize:self.lblFullName.font.pointSize]];
	[self.lblChannelTitle setFont:[UIFont boldCustomFontOfSize:self.lblChannelTitle.font.pointSize]];
	
	[self.txtViewTitle setFont:[UIFont boldCustomFontOfSize:self.txtViewTitle.font.pointSize]];
	

	[self.lblDescription setFont:[UIFont regularCustomFontOfSize:self.lblDescription.font.pointSize]];
	[self.txtViewDescription setFont:[UIFont regularCustomFontOfSize:self.txtViewDescription.font.pointSize]];
	[self.btnShowFollowers.titleLabel setFont:[UIFont lightCustomFontOfSize:self.btnShowFollowers.titleLabel.font.pointSize]];
	[self.btnShowVideos.titleLabel setFont:[UIFont lightCustomFontOfSize:self.btnShowVideos.titleLabel.font.pointSize]];
	

	[self.lblNoVideos setFont:[UIFont regularCustomFontOfSize:self.lblNoVideos.font.pointSize]];

    [self.videoThumbnailCollectionView registerNib:[SYNCollectionVideoCell nib]
                        forCellWithReuseIdentifier:[SYNCollectionVideoCell reuseIdentifier]];
    
    // == Footer View == //
    [self.videoThumbnailCollectionView registerNib:[SYNChannelFooterMoreView nib]
                        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                               withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];

    self.btnShowFollowers.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.txtFieldChannelName setFont:[UIFont boldCustomFontOfSize:self.txtFieldChannelName.font.pointSize]];
    
    [self.txtViewDescription setTextColor:[UIColor dollyTextMediumGray]];
    
    [[self.txtFieldChannelName layer] setCornerRadius:0];
    
    self.lblNoVideos.text = NSLocalizedString(@"channel_screen_no_videos", "No videos in the channel details colleciton");
	
}

-(void) setUpMode {
    if (self.mode == kChannelDetailsModeDisplayUser) {
        self.btnEditChannel.hidden = NO;
        self.btnFollowChannel.hidden = YES;
    } else if (self.mode == kChannelDetailsModeDisplay) {
        self.btnEditChannel.hidden = YES;
        self.btnFollowChannel.hidden = NO;
    } else if (self.mode == kChannelDetailsModeEdit) {
        [self editMode];
        self.navigationItem.leftBarButtonItem = nil;
    }
    else if (self.mode == kChannelDetailsFavourites) {
        //Favourites channel is differnet
        if(IS_IPHONE) {
            self.btnEditChannel.hidden = YES;
            self.btnFollowChannel.hidden = YES;
            [self centreView:self.btnShareChannel];
            CGRect tmpFrame = self.btnShareChannel.frame;
            tmpFrame.origin.x = self.viewCirleButtonContainer.frame.size.width/2-tmpFrame.size.width/2;
			self.btnShareChannel.frame = tmpFrame;
            tmpFrame = self.viewCirleButtonContainer.frame;
            tmpFrame.origin.y -= 4;
            self.viewCirleButtonContainer.frame = tmpFrame;
        } else {
            self.btnEditChannel.hidden = YES;
            self.btnFollowChannel.hidden = YES;
            CGRect tmpFrame = self.btnShareChannel.frame;
            tmpFrame.origin.x = self.viewCirleButtonContainer.frame.size.width/2-tmpFrame.size.width/2;
			self.btnShareChannel.frame = tmpFrame;
            tmpFrame = self.viewCirleButtonContainer.frame;
            tmpFrame.origin.y -= 4;
            self.viewCirleButtonContainer.frame = tmpFrame;
        }
    }
}

-(void) displayChannelDetails {
    
    // == Avatar Image == //

    UIImage* placeholderImage = [UIImage imageNamed: @"PlaceholderAvatarProfile"];

    [self.btnAvatar setContentMode:UIViewContentModeScaleToFill];
    [self.btnAvatar.imageView setContentMode:UIViewContentModeScaleToFill];
    
    
    [self.btnAvatar setImageWithURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailLargeUrl]
                           forState: UIControlStateNormal
                   placeholderImage: placeholderImage
                            options: SDWebImageRetryFailed];
    
    self.btnAvatar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.btnAvatar.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;

    self.txtFieldChannelName.text = self.channel.title;

    self.lblFullName.text = self.channel.channelOwner.displayName;
    self.lblChannelTitle.text = self.channel.title;
	self.txtViewTitle.text = self.channel.title;
	
	self.lblDescription.attributedText = [self attributedDescriptionStringFrom:self.channel.channelDescription];
	
    self.txtViewDescription.text = self.lblDescription.text;
    
    
    [self updateButtonCounts];
    
    self.dataItemsAvailable = self.channel.totalVideosValueValue;
    [self.btnEditChannel setTitle:NSLocalizedString(@"Edit", @"Edit mode button title, channel details")];
	self.btnShareChannel.layer.borderColor = [[UIColor whiteColor] CGColor];
	[self setFollowButton];
    if ([self.channel.totalVideosValue integerValue] == 0) {
        self.lblNoVideos.hidden = NO;
    } else {
        self.lblNoVideos.hidden = YES;
    }
    
    //should not have to do this, check.
    [self.btnDeleteChannel setBackgroundColor:[UIColor whiteColor]];
    
}


- (void) setFollowButton {
	self.channel.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToChannelId:self.channel.uniqueId];
	self.btnFollowChannel.selected = self.channel.subscribedByUserValue;
}

#pragma mark - Control Actions

- (void) followControlPressed: (SYNSocialButton *) socialControl {

    if (self.btnFollowChannel.isSelected) {
        
        if (self.channel.subscribersCountValue>=1) {
            self.channel.subscribersCountValue--;
        }
        [self updateButtonCounts];
    } else {
        self.channel.subscribersCountValue++;
        [self updateButtonCounts];
    }
    
    [self followButtonPressed:socialControl withChannel:self.channel completion:nil];
}


-(void) updateButtonCounts {
    
    if (self.channel.subscribersCountValue == 1) {
        [self.btnShowFollowers setTitle:[NSString stringWithFormat: @"%ld %@", (long)self.channel.subscribersCountValue, NSLocalizedString(@"Follower", @"followers count in channeldetail")] forState:UIControlStateNormal ];
    } else {
        [self.btnShowFollowers setTitle:[NSString stringWithFormat: @"%ld %@", (long)self.channel.subscribersCountValue, NSLocalizedString(@"Followers", @"followers count in channeldetail")] forState:UIControlStateNormal ];
    }
    
    if (self.channel.totalVideosValueValue == 1) {
        [self.btnShowVideos setTitle:[NSString stringWithFormat: @"%@ %@",self.channel.totalVideosValue, NSLocalizedString(@"Video", nil)] forState:UIControlStateNormal ];
    } else {
        [self.btnShowVideos setTitle:[NSString stringWithFormat: @"%@ %@",self.channel.totalVideosValue, NSLocalizedString(@"Videos", nil)] forState:UIControlStateNormal ];
    }
    
}

- (IBAction)shareChannelPressed:(id)sender {
	[self shareChannel:self.channel];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll: (UIScrollView *) scrollView {
    [super scrollViewDidScroll:scrollView];
    [self moveHeader:scrollView.contentOffset.y];
    
}

- (void)killScroll {
    CGPoint offset = self.videoThumbnailCollectionView.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [self.videoThumbnailCollectionView setContentOffset:offset animated:NO];
}


- (void)moveHeader:(CGFloat) offset {
    if (IS_IPHONE ) {
        offset +=self.videoThumbnailCollectionView.contentInset.top;
    }
    
    if (IS_IPAD) {
        offset +=self.videoThumbnailCollectionView.contentInset.top;
        
    }
    CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
    
    self.viewProfileContainer.transform = move;
    self.btnAvatar.transform = move;
    self.viewCirleButtonContainer.transform = move;
    self.lblNoVideos.transform = move;
    self.viewFollowAndVideoContainer.transform = move;
    self.btnDeleteChannel.transform = move;
    self.txtViewDescription.transform = move;
    self.txtFieldChannelName.transform = move;
    self.viewCirleButtonContainer.transform = move;
	self.lblChannelTitle.transform = move;
	self.txtViewTitle.transform = move;
    self.lblFullName.transform = move;
}

-(void) moveNameLabelWithOffset :(CGFloat) offset {
    if (IS_IPHONE) {
        CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
        self.lblChannelTitle.transform = move;
        
        if (offset < FULL_NAME_LABEL_IPHONE) {
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
            self.lblChannelTitle.transform = move;
        }
        
        if (offset > FULL_NAME_LABEL_IPHONE) {
            CGAffineTransform move = CGAffineTransformMakeTranslation(0,-FULL_NAME_LABEL_IPHONE);
            CGAffineTransform scale =  CGAffineTransformMakeScale(1.0, 1.0);
            self.lblChannelTitle.transform = CGAffineTransformConcat(move, scale);
        }
    }
    
    if (IS_IPAD) {
        if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation]) ) {
            if (offset<FULL_NAME_LABEL_IPAD_PORTRAIT) {
                CGAffineTransform move = CGAffineTransformMakeTranslation(0,-offset);
                self.lblChannelTitle.transform = move;
            }
            
            if (offset > FULL_NAME_LABEL_IPAD_PORTRAIT) {
                CGAffineTransform move = CGAffineTransformMakeTranslation(0,-FULL_NAME_LABEL_IPAD_PORTRAIT);
                self.lblChannelTitle.transform = move;
            }
        } else if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            if (offset > FULLNAMELABELIPADLANDSCAPE) {
                CGAffineTransform move = CGAffineTransformMakeTranslation(0,-FULL_NAME_LABEL_IPAD_PORTRAIT);
                self.lblChannelTitle.transform = move;
            }
            
            if (offset<FULLNAMELABELIPADLANDSCAPE) {
                CGAffineTransform move = CGAffineTransformMakeTranslation(0,-offset);
                self.lblChannelTitle.transform = move;
            }
        }
    }
}

#pragma mark - Tab View Methods

- (void) setChannel: (Channel *) channel {

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
    
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: kChannel
                                                inManagedObjectContext: channel.managedObjectContext]];
    
    [channelFetchRequest setPredicate: [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", channel.uniqueId, self.viewId]];
    
    
    NSArray *matchingChannelEntries = [channel.managedObjectContext executeFetchRequest: channelFetchRequest
                                                                                  error: &error];
    
    if (matchingChannelEntries.count > 0)
    {
        _channel = (Channel *) matchingChannelEntries[0];
        _channel.markedForDeletionValue = NO;
        
        if (matchingChannelEntries.count > 1) // housekeeping, there can be only one!
        {
            for (int i = 1; i < matchingChannelEntries.count; i++)
            {
                [channel.managedObjectContext deleteObject: (matchingChannelEntries[i])];
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
            [_channel.managedObjectContext save: &error];
            
            if (error)
            {
                _channel = nil; // further error code
            }
        }
    }
    
    if (self.channel)
    {
		[self setFollowButton];
        
        self.channel.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToChannelId:self.channel.uniqueId];
        
        
        if ([self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
        {
            [self updateChannelOwnerWithUser];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.channel.managedObjectContext];
        
        if (self.mode == kChannelDetailsModeDisplay || self.mode == kChannelDetailsModeDisplayUser || self.mode == kChannelDetailsFavourites)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                                object: self
                                                              userInfo: @{kChannel: self.channel}];
        }
    }
    

    
    [self displayChannelDetails];
    
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
        [self.channel.channelOwner.managedObjectContext save: &error];
        
        if (!error)
        {
            [self displayChannelDetails];
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
	dispatch_async(dispatch_get_main_queue(), ^{
		NSArray *updatedObjects = [notification userInfo][NSUpdatedObjectsKey];
		
		NSArray *deletedObjects = [notification userInfo][NSDeletedObjectsKey]; // our channel has been deleted
		
		if ([deletedObjects containsObject: self.channel])
		{
			return;
		}
		
		[updatedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
			
			if (obj == self.channel)
			{
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
		
		[self setFollowButton];
		if ((self.channel.channelOwner.displayName !=  nil) && (self.txtFieldChannelName.text == nil))
		{
			[self displayChannelDetails];
		}

	});
}

- (void) reloadCollectionViews {
    [self.videoThumbnailCollectionView reloadData];
	
    [self displayChannelDetails];
}

#pragma mark - Collection Delegate/Data Source Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.model itemCount];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *) collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SYNCollectionVideoCell *videoThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNCollectionVideoCell reuseIdentifier]
                                                                                           forIndexPath:indexPath];
    
	VideoInstance *videoInstance = [self.model itemAtIndex:indexPath.item];
    
    if (self.mode == kChannelDetailsModeEdit) {
        videoThumbnailCell.deleteButton.hidden = NO;
		videoThumbnailCell.videoActionsContainer.hidden = YES;
    }
    else
    {
        videoThumbnailCell.deleteButton.hidden = YES;
		videoThumbnailCell.videoActionsContainer.hidden = NO;
    }
    
    [videoThumbnailCell setVideoInstance:videoInstance];
    [videoThumbnailCell setDelegate:self];
    
    if (self.mode != kChannelDetailsModeEdit) {
        [videoThumbnailCell setUpVideoTap];
    }
    
    return videoThumbnailCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
		   viewForSupplementaryElementOfKind:(NSString *)kind
								 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *supplementaryView = nil;
	if (kind == UICollectionElementKindSectionFooter) {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                             withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]
                                                                    forIndexPath:indexPath];
        supplementaryView = self.footerView;
		
        
        
        
		if ([self.model hasMoreItems]) {
			self.footerView.showsLoading = YES;
			
			[self.model loadNextPage];
		}
    }
	
    return supplementaryView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	return ((collectionView == self.videoThumbnailCollectionView && [self.model hasMoreItems]) ? [self footerSize] : CGSizeZero);
}

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self updateLayoutForOrientation: toInterfaceOrientation];
}


#pragma mark - SYNPagingModelDelegate

- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel {
    [self.videoThumbnailCollectionView reloadData];
}

- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel {
	
}

- (void) updateLayoutForOrientation: (UIDeviceOrientation) orientation
{
    if (IS_IPAD) {
        if (UIDeviceOrientationIsPortrait(orientation))
        {
            self.videoCollectionViewLayoutIPadEdit.sectionInset = UIEdgeInsetsMake(0, 35, 0, 35);
            self.videoCollectionViewLayoutIPad.sectionInset = UIEdgeInsetsMake(0, 35, 0, 35);
        }
        else
        {
            self.videoCollectionViewLayoutIPadEdit.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
            self.videoCollectionViewLayoutIPad.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        }
    }
}

-(void) centreView : (UIView*) viewToCentre
{
    CGPoint tmpPoint;
    tmpPoint = viewToCentre.center;
    tmpPoint.x = [super view].center.x;
    viewToCentre.center = tmpPoint;
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
	
	UIViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:self.model
																			   selectedIndex:indexPath.item];
	
	SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
	animator.delegate = self;
	animator.cellIndexPath = indexPath;
	
	self.videoPlayerAnimator = animator;
	viewController.transitioningDelegate = animator;
	
	[self presentViewController:viewController animated:YES completion:nil];
	
	
	
}

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	return (SYNCollectionVideoCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath:indexPath];
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
    
    self.model = [SYNChannelVideosModel modelWithChannel:self.channel];
    [self.videoThumbnailCollectionView reloadData];
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
                                              
                                              
                                              //                                              [self finaliseViewStatusAfterCreateOrUpdate: !self.isIPhone];
                                              
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kVideoQueueClear
                                                                                                   object: nil];
                                              
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kNoteChannelSaved
                                                                                                  object:self
                                                                                                userInfo:nil];
                                          } errorHandler: ^(id err) {
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kVideoQueueClear
                                                                                                   object: nil];
                                          }];
}



- (IBAction)avatarTapped:(id)sender
{
    User *tmpUser = [((SYNAppDelegate*)[[UIApplication sharedApplication] delegate]) currentUser];
    
    SYNProfileRootViewController *profileVC;
    
    if (tmpUser.uniqueId == self.channel.channelOwner.uniqueId) {
        profileVC = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId andChannelOwner:self.channel.channelOwner];
        profileVC.navigationItem.backBarButtonItem.title = @"";
        
    }
    else
    {
        profileVC = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId andChannelOwner:self.channel.channelOwner];
        profileVC.navigationItem.backBarButtonItem.title = @"";
        
    }
    [self.navigationController pushViewController:profileVC animated:YES];
}


-(void) profileMode
{
    self.mode = kChannelDetailsModeDisplayUser;
    
	
	self.txtViewTitle.hidden = YES;
	
	self.btnAvatar.userInteractionEnabled = YES;
    self.viewProfileContainer.hidden = NO;
    self.btnShowFollowers.hidden = NO;
    self.btnShowVideos.hidden = NO;
    self.btnFollowChannel.hidden = YES;
    self.btnEditChannel.hidden = NO;
    self.btnShareChannel.hidden = NO;
    self.viewCirleButtonContainer.hidden = NO;
    self.viewFollowAndVideoContainer.hidden = NO;
    
    self.lblChannelTitle. hidden = NO;
    //edit mode
    self.btnDeleteChannel.hidden = YES;
    self.txtFieldChannelName.hidden = YES;
    self.txtViewDescription.hidden = YES;
    
    if ([self.channel.totalVideosValue integerValue]== 0)
    {
        self.lblNoVideos.hidden = NO;
    }
    else
    {
        self.lblNoVideos.hidden = YES;
    }
    
    
    self.viewProfileContainer.alpha = 0.0f;
    self.btnAvatar.alpha = 0.0f;
    self.btnShowFollowers.alpha = 0.0f;
    self.btnShowVideos.alpha = 0.0f;
    //    self.btnFollowChannel.alpha = 0.0f;
    self.btnEditChannel.alpha = 0.0f;
    self.btnShareChannel.alpha = 0.0f;
    self.lblChannelTitle.alpha = 0.0f;
    
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
    [UIView animateWithDuration:0.4 animations:^{
        
        self.viewProfileContainer.alpha = 1.0f;
        self.btnAvatar.alpha = 1.0f;
        self.btnShowFollowers.alpha = 1.0f;
        self.btnShowVideos.alpha = 1.0f;
        //      self.btnFollowChannel.alpha = 1.0f;
        self.btnEditChannel.alpha = 1.0f;
        self.btnShareChannel.alpha = 1.0f;
        self.lblChannelTitle.alpha = 1.0f;
        
    }];
    
}


-(void) editMode
{
    
    self.mode = kChannelDetailsModeEdit;
    
    //profile mode
    
    self.viewProfileContainer.hidden = YES;
//    self.btnAvatar.hidden = YES;
	
	self.txtViewTitle.hidden = NO;

	self.btnAvatar.userInteractionEnabled = NO;
    self.btnShowFollowers.hidden = YES;
    self.btnShowVideos.hidden = YES;
    self.btnEditChannel.hidden = YES;
    self.btnShareChannel.hidden = YES;
    self.viewCirleButtonContainer.hidden = YES;
    self.viewFollowAndVideoContainer.hidden = YES;
    self.lblChannelTitle. hidden = YES;
    //edit mode
    self.btnDeleteChannel.hidden = NO;
    self.txtFieldChannelName.hidden = NO;
    self.txtViewDescription.hidden = NO;
    self.txtViewTitle.hidden = NO;
	
	
	self.btnDeleteChannel.alpha = 0.0f;
    self.txtFieldChannelName.alpha = 0.0f;
    self.txtViewDescription.alpha = 0.0f;
	self.txtViewTitle.alpha = 0.0f;

	[self.navigationItem setLeftBarButtonItem:self.barBtnCancel animated:YES];
	[self.navigationItem setRightBarButtonItem:self.barBtnSave animated:YES];
    [UIView animateWithDuration:0.4 animations:^{
        self.btnDeleteChannel.alpha = 1.0f;
        self.txtFieldChannelName.alpha = 0.3f;
        self.txtViewDescription.alpha = 0.3f;
		self.txtViewTitle.alpha = 0.3f;

    }];
    
}

- (IBAction)editTapped:(id)sender
{
	
	[[SYNTrackingManager sharedManager] trackEditCollectionScreenView];
    
    [self killScroll];

    [self editMode];
    
    for (SYNCollectionVideoCell* cell in self.videoThumbnailCollectionView.visibleCells)
    {
        
        cell.deleteButton.hidden = NO;
        void (^animateEditMode)(void) = ^{
            
            CGRect frame = cell.frame;
            
            cell.frame = frame;
            
            cell.deleteButton.alpha = 1.0f;
            cell.videoActionsContainer.alpha = 0.0f;
            
        };
        
        [UIView transitionWithView:cell
                          duration:0.5f
                           options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                        animations:animateEditMode
                        completion:^(BOOL finished) {
                            
                        }];
        
        [cell removeGestureRecognizer:cell.tap];
    }
    self.mode = kChannelDetailsModeEdit;
    // not clear why its 0.5f delay
    //TODO:pass blocks on success/fail do stuff.
    [self performSelector:@selector(updateCollectionLayout) withObject:self afterDelay:0.5f];
    
}


- (void)cancelTapped {
    
    [self profileMode];
    
    [self.txtFieldChannelName resignFirstResponder];
    [self.txtViewDescription resignFirstResponder];
	[self.txtViewTitle resignFirstResponder];
	
	self.txtViewDescription.text = self.channel.channelDescription;
	
    [self updateCollectionLayout];
    for (SYNCollectionVideoCell* cell in self.videoThumbnailCollectionView.visibleCells) {
        
        cell.deleteButton.hidden = YES;
        
        void (^animateProfileMode)(void) = ^{
            
            cell.deleteButton.alpha = 0.0f;
			cell.videoActionsContainer.alpha = 1.0f;

        };
        
        [UIView transitionWithView:cell
                          duration:0.5f
                           options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                        animations:animateProfileMode
                        completion:^(BOOL finished) {
                        }];
        
    }
    
}



-(void) updateCollectionLayout
{
	// Invalidate layout to work around crash issue with switching layout when there are no items:
	// http://stackoverflow.com/questions/18339030/uicollectionview-assertion-error-on-stale-data
	[self.videoThumbnailCollectionView.collectionViewLayout invalidateLayout];
	[self.videoThumbnailCollectionView reloadData];
	
    if (self.mode == kChannelDetailsModeEdit )
    {
        if (IS_IPHONE)
        {
            [self.videoThumbnailCollectionView setCollectionViewLayout:self.videoCollectionViewLayoutIPhoneEdit animated:YES];
        }
        if (IS_IPAD)
        {
            [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
            [self.videoThumbnailCollectionView setCollectionViewLayout:self.videoCollectionViewLayoutIPadEdit animated:YES];
        }
    }
    
    if (self.mode == kChannelDetailsModeDisplayUser )
    {
        if (IS_IPHONE)
        {
            [self.videoThumbnailCollectionView setCollectionViewLayout:self.videoCollectionViewLayoutIPhone animated:YES];
            [self.videoThumbnailCollectionView removeGestureRecognizer:self.videoCollectionViewLayoutIPhoneEdit.panGestureRecognizer];
            
            self.videoThumbnailCollectionView.delegate = self;
            self.videoThumbnailCollectionView.dataSource = self;
            
        }
        
        if (IS_IPAD)
        {
            [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
            
            [self.videoThumbnailCollectionView setCollectionViewLayout:self.videoCollectionViewLayoutIPad animated:YES];
            
            [self.videoThumbnailCollectionView removeGestureRecognizer:self.videoCollectionViewLayoutIPadEdit.panGestureRecognizer];
            
            self.videoThumbnailCollectionView.delegate = self;
            self.videoThumbnailCollectionView.dataSource = self;
        }
    }
}


#pragma mark - Deleting Video Instances

- (void) deleteVideoInstancePressed: (UIButton *) deleteButton
{
    UIView *v = deleteButton.superview.superview;
    
    self.indexPathToDelete = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    VideoInstance *videoInstanceToDelete = (VideoInstance *) self.channel.videoInstances[self.indexPathToDelete.item];
    
    if (!videoInstanceToDelete)
    {
        return;
    }
    
    [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"channel_creation_screen_channel_delete_dialog_title", nil)
                                message: NSLocalizedString(@"channel_creation_screen_video_delete_dialog_description", nil)
                               delegate: self
                      cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                      otherButtonTitles: NSLocalizedString(@"Delete", nil), nil] show];
}

#pragma mark - Delete channel

- (IBAction)deleteTapped:(id)sender
{
	NSString *title = [NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Delete Collection", "Alerview confirm to delete a Channel"), self.channel.title];
	
    self.deleteChannelAlertView = [[UIAlertView alloc] initWithTitle: title
                                                             message: nil
                                                            delegate: self
                                                   cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                                   otherButtonTitles: NSLocalizedString(@"Delete", nil), nil];
    [self.deleteChannelAlertView show];
}

- (void) deleteVideoInstance
{
    VideoInstance *videoInstanceToDelete = (VideoInstance *) self.channel.videoInstances[self.indexPathToDelete.item];
    
    if (!videoInstanceToDelete)
    {
        return;
    }
    
    UICollectionViewCell *cell = [self.videoThumbnailCollectionView cellForItemAtIndexPath: self.indexPathToDelete];
    
    [UIView animateWithDuration: 0.2
                     animations: ^{
                         cell.alpha = 0.0;
                     }
                     completion: ^(BOOL finished) {
                         [self.channel.videoInstancesSet removeObject: videoInstanceToDelete];
                         [videoInstanceToDelete.managedObjectContext deleteObject: videoInstanceToDelete];
						 
						 self.channel.totalVideosValueValue--;
                         self.model = [SYNChannelVideosModel modelWithChannel:self.channel];
                        [self.videoThumbnailCollectionView reloadData];
                     }];
}


- (void) alertView: (UIAlertView *) alertView willDismissWithButtonIndex: (NSInteger) buttonIndex
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
            [self deleteVideoInstance];
        }
    }
}


- (void)deleteChannel {
    __weak SYNChannelDetailsViewController *weakSelf = self;
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId: appDelegate.currentUser.uniqueId
                                                 channelId: self.channel.uniqueId
                                         completionHandler: ^(id response) {
                                             
                                             [appDelegate.currentUser.channelsSet removeObject: self.channel];
                                             [self.channel.managedObjectContext deleteObject: self.channel];
                                             [self.originalChannel.managedObjectContext deleteObject:self.originalChannel];
                                             
                                             // bring back controls
                                             
                                             [appDelegate saveContext: YES];
                                             [weakSelf.navigationController popToRootViewControllerAnimated:YES];

                                             
                                         } errorHandler: ^(id error) {
                                             
                                             DebugLog(@"Delete channel failed");
                                             
                                         }];
    
}



- (IBAction)followersLabelPressed: (id) sender {
    if (self.channel.subscribersCountValue == 0) {
        return;
    }
    
    SYNSubscribersViewController *subscribersViewController = [[SYNSubscribersViewController alloc] initWithChannel: self.channel];
	
	UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:nil
                                                                  action:nil];
	
	subscribersViewController.navigationController.navigationItem.backBarButtonItem = backButton;

    
    if(IS_IPAD)
    {
        UINavigationController* navigationControllerWrapper = [[UINavigationController alloc] initWithRootViewController:subscribersViewController];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 30.0f)];
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont lightCustomFontOfSize:25];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.text = @"Followers";
        subscribersViewController.navigationItem.titleView = label;
        
        navigationControllerWrapper.view.frame = subscribersViewController.view.frame;
        [appDelegate.masterViewController addOverlayController:navigationControllerWrapper animated:YES];
    }
    
    else
    {
		
        [self.navigationController pushViewController:subscribersViewController animated:YES];
    }
    
}

- (void)saveTapped {
    
	[[SYNTrackingManager sharedManager] trackCollectionSaved];
	
	self.lblDescription.attributedText = [self attributedDescriptionStringFrom:self.txtViewDescription.text];
	self.lblChannelTitle.text = IS_IPHONE ? self.txtViewTitle.text : self.txtFieldChannelName.text;

    
    [appDelegate.oAuthNetworkEngine updateChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                 channelId: self.channel.uniqueId
                                                     title: IS_IPHONE ? self.txtViewTitle.text : self.txtFieldChannelName.text
                                               description: self.txtViewDescription.text
                                                  category: @""
                                                     cover: @""
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary *resourceCreated) {

											 self.lblDescription.attributedText = [self attributedDescriptionStringFrom:self.txtViewDescription.text];
                                             
											 self.lblChannelTitle.text = IS_IPHONE ? self.txtViewTitle.text : self.txtFieldChannelName.text;
											 [[SYNTrackingManager sharedManager] trackCollectionEdited:[self.txtFieldChannelName.text uppercaseString]];
                                             
                                            
                                             
                                             NSString *channelId = resourceCreated[@"id"];
                                            
                                             if(self.mode == kChannelDetailsModeEdit)
                                                 [self setVideosForChannelById: channelId //  2nd step of the creation process
                                                                     isUpdated: YES];
                                             
                                             
											 [self cancelTapped];
                                         }
                                              errorHandler: ^(id error) {
                                                  DebugLog(@"Error @ saveChannelPressed:");
                                                  
                                                  NSString *errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                  NSString *errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_save_description", nil);
                                                  
                                                  NSArray *errorTitleArray = error[@"form_errors"][@"title"];
                                                  
                                                  if ([errorTitleArray count] > 0)
                                                  {
                                                      NSString *errorType = errorTitleArray[0];
                                                      
                                                      if ([errorType isEqualToString: @"Duplicate title."])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_description", nil);
                                                      }
                                                      else if ([errorType isEqualToString: @"Mind your language!"])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_description", nil);
                                                      }
                                                      else
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_save_description", nil);
                                                      }
                                                  }
                                                  
                                                  [self	showError: errorMessage showErrorTitle: errorTitle];
												  
                                              }];
}

- (void) setVideosForChannelById: (NSString *) channelId isUpdated: (BOOL) isUpdated
{
    
    [appDelegate.oAuthNetworkEngine updateVideosForUserId: appDelegate.currentOAuth2Credentials.userId
                                             forChannelID: channelId
                                         videoInstanceSet: self.channel.videoInstances
                                            clearPrevious: YES
                                        completionHandler: ^(id response) {
                                            // a 204 returned
                                            
                                            [self fetchAndStoreUpdatedChannelForId: channelId
                                                                          isUpdate: isUpdated];
                                        } errorHandler: ^(id err) {
                                            // this is also called when trying to save a video that has just been deleted
                                            NSString *errorMessage = nil;
                                            
                                            NSString *errorTitle = nil;
                                            
                                            if ([err isKindOfClass: [NSDictionary class]])
                                            {
                                                errorMessage = err[@"message"];
                                                
                                                if (!errorMessage)
                                                {
                                                    errorMessage = err[@"error"];
                                                }
                                            }
                                            
                                            
                                            [[NSNotificationCenter defaultCenter]  postNotificationName: kVideoQueueClear
                                                                                                 object: self];
                                            
                                            if (isUpdated)
                                            {
                                                
                                                if (!errorMessage)
                                                {
                                                    errorMessage = NSLocalizedString(@"Could not update the channel videos. Please review and try again later.", nil);
                                                }
                                                
                                                DebugLog(@"Error @ setVideosForChannelById:");
                                                [self showError: errorMessage
                                                 showErrorTitle: errorTitle];
                                            }
                                            else                           // isCreated
                                            {
                                                
                                                if (!errorMessage)
                                                {
                                                    errorMessage = NSLocalizedString(@"Could not add videos to channel. Please review and try again later.", nil);
                                                }
                                                
												// if we have an error at this stage then it means that we started a channel with a single invalid video
                                                // we want to still create that channel, but without that video while waring to the user.

                                                if (self.channel.videoInstances[0])
                                                {
                                                    [self.channel.videoInstancesSet removeObject: self.channel.videoInstances[0]];
                                                }
                                                
                                                [self fetchAndStoreUpdatedChannelForId: channelId
                                                                              isUpdate: isUpdated];
                                                
                                                
                                                [self showError: errorMessage
                                                 showErrorTitle: errorTitle];
                                            }
                                        }];
}

- (void) showError: (NSString *) errorMessage showErrorTitle: (NSString *) errorTitle
{
    
    [[[UIAlertView alloc] initWithTitle: errorTitle
                                message: errorMessage
                               delegate: nil
                      cancelButtonTitle: NSLocalizedString(@"OK", nil)
                      otherButtonTitles: nil] show];
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    [self.view addGestureRecognizer:self.tapToHideKeyoboard];
	
	textView.alpha = 1.0f;
	
	if ([textView isEqual:@""]) {
		textView.textAlignment = NSTextAlignmentLeft;
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
	
	if (textView.text.length <= 1 && [text isEqual:@""]) {
		textView.textAlignment = NSTextAlignmentLeft;
	} else {
		textView.textAlignment = NSTextAlignmentCenter;
	}
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
	
	if (textView == self.txtViewDescription) {
		return (newLength > 100) ? NO : YES;
	} else if (textView == self.txtViewTitle) {
		return (newLength > 25) ? NO : YES;
	}
	
	return NO;
}


#pragma mark - Text Field Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
	textField.alpha = 1.0f;

    [self.view addGestureRecognizer:self.tapToHideKeyoboard];
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
    return (newLength > 25) ? NO : YES;
}

-(void)dismissKeyboard
{
	
	
	[self.txtViewTitle resignFirstResponder];
    [self.txtFieldChannelName resignFirstResponder];
    [self.txtViewDescription resignFirstResponder];
    
    [self.view removeGestureRecognizer:self.tapToHideKeyoboard];
}


-(void) setAutoplayId:(NSString *)autoplayId
{
    
    __block UIViewController *viewController;
    
    [appDelegate.oAuthNetworkEngine videoForChannelForUserId:appDelegate.currentUser.uniqueId channelId:self.channel.uniqueId instanceId:autoplayId completionHandler:^(id response) {
        
        VideoInstance *vidToPlay = [VideoInstance instanceFromDictionary:response usingManagedObjectContext:appDelegate.mainManagedObjectContext];
        
        
        NSInteger tmpPosition = NSNotFound;
        
		// Check if the video instance is in the first set of videos
		for (int i = 0; i<self.model.itemCount; i++) {
			VideoInstance *videoInstance = [self.model itemAtIndex:i];
			//If the video is found, set the position
			if ([videoInstance.uniqueId isEqual:vidToPlay.uniqueId]) {
				tmpPosition = i;
			}
		}
		
		NSArray *videosArray = [self.channel.videoInstancesSet array];
		SYNPagingModel *model = [[SYNStaticModel alloc] initWithItems:videosArray];
        
        //If the Video was not found, add the video instance to th end.
        if (tmpPosition == NSNotFound) {
            
            [self.channel addVideoInstancesObject:vidToPlay];
			
            self.model = [SYNChannelVideosModel modelWithChannel:self.channel];

            
			viewController = [SYNVideoPlayerViewController viewControllerWithModel:model
																	 selectedIndex:[videosArray count] - 1];
        } else {
            self.model = [SYNChannelVideosModel modelWithChannel:self.channel];

			viewController = [SYNVideoPlayerViewController viewControllerWithModel:model
																	 selectedIndex:tmpPosition];
        }
        
		[self.navigationController presentViewController:viewController animated:YES completion:nil];
        
    } errorHandler:^(id  error) {
		//TODO: Displaying something when the video is not found
	
	}];

}


-(NSMutableAttributedString*) attributedDescriptionStringFrom:(NSString *) string {
	
	if (!string) {
		return [[NSMutableAttributedString alloc] initWithString: @""];
	}
	NSMutableAttributedString *channelDescription = [[NSMutableAttributedString alloc] initWithString: string];
	
	NSInteger strLength = [channelDescription length];
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.lineBreakMode = NSLineBreakByWordWrapping;
	[style setLineSpacing:7];
	[style setAlignment:NSTextAlignmentCenter];
	
	[channelDescription addAttribute:NSParagraphStyleAttributeName
							   value:style
							   range:NSMakeRange(0, strLength)];
	return channelDescription;
}

@end
