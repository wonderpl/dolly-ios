//
//  SYNProfileChannelViewController.m
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileChannelViewController.h"
#import "SYNChannelCreateNewCell.h"
#import "SYNChannelMidCell.h"
#import "SYNProfileHeader.h"
#import "SYNDeviceManager.h"
#import "SYNChannelDetailsViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNTrackingManager.h"
#import "SYNIPhoneCreateChannelLayout.h"
#import "SYNIPadCreateChannelLayout.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNChannelFooterMoreView.h"
#import "SYNProfileExpandedFlowLayout.h"
#import "UINavigationBar+Appearance.h"

static const CGFloat PARALLAX_SCROLL_VALUE = 2.0f;
static const CGFloat ALPHA_IN_EDIT = 0.2f;
static const CGFloat FULL_NAME_LABEL_IPHONE = 355.0f; // lower is down
static const CGFloat FULL_NAME_LABEL_IPAD_PORTRAIT = 533.0f;
static const CGFloat FULLNAMELABELIPADLANDSCAPE = 412.0f;

@interface SYNProfileChannelViewController () <SYNChannelCreateNewCelllDelegate, SYNChannelMidCellDelegate, SYNPagingModelDelegate>
@property (nonatomic,strong) IBOutlet UIView *fakeNavigationBar;
@property (nonatomic,strong) IBOutlet UILabel *fakeNavigationBarTitle;
@property (nonatomic, weak) SYNChannelCreateNewCell *createChannelCell;
@property (nonatomic) BOOL creatingChannel;
@property (nonatomic) BOOL showingDescription;

@property (nonatomic, strong) IBOutlet UICollectionViewFlowLayout *defaultLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *channelExpandedLayout;

@property (nonatomic, strong) UIBarButtonItem *barBtnCancelCreateChannel;
@property (nonatomic, strong) UIBarButtonItem *barBtnSaveCreateChannel;

@property (nonatomic, strong) SYNProfileHeader* headerView;
@property (nonatomic, strong) SYNChannelMidCell *deleteCell;
@property (nonatomic, strong) NSIndexPath *indexPathToDelete;
@property (nonatomic, strong) SYNProfileChannelModel *model;

@property (nonatomic, strong) UITapGestureRecognizer *tapToHideKeyoboard;

@end

@implementation SYNProfileChannelViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    [self setUpBarButtons];
	
	
	self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (IS_IPHONE) {
        self.channelExpandedLayout = [[SYNIPhoneCreateChannelLayout alloc] init];
    } else {
        self.channelExpandedLayout = [[SYNIPadCreateChannelLayout alloc] initWithLayout:self.defaultLayout];
    }
    
    self.fakeNavigationBarTitle.font = [UIFont regularCustomFontOfSize:self.fakeNavigationBarTitle.font.pointSize];
    [self.fakeNavigationBarTitle setText: self.channelOwner.displayName];

    self.tapToHideKeyoboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (IS_IPAD) {
        [self updateLayoutForOrientation: [[SYNDeviceManager sharedInstance] orientation]];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    
	[super viewDidAppear:YES];
	[UIView animateWithDuration:2.0 animations:^{
		[self showInboardingAnimationDescription];
	}];
}



- (void)registerNibs {
    
    [self.cv registerNib: [SYNChannelCreateNewCell nib]
	forCellWithReuseIdentifier: [SYNChannelCreateNewCell reuseIdentifier]];
    
    
    [self.cv registerNib: [SYNChannelMidCell nib]
forCellWithReuseIdentifier: [SYNChannelMidCell reuseIdentifier]];
    
    
    [self.cv registerNib: [SYNProfileHeader nib]
forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
     withReuseIdentifier:[SYNProfileHeader reuseIdentifier]];
    
    [self.cv registerNib:[SYNChannelFooterMoreView nib]
forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
     withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
}

- (void)setUpBarButtons {
    self.barBtnCancelCreateChannel = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelCreateChannel)];
    self.barBtnCancelCreateChannel.tintColor = [UIColor colorWithRed: (100 / 255.0f)
                                                             green: (99 / 255.0f)
                                                              blue: (112 / 255.0f)
                                                             alpha: 1.0f];
    
    self.barBtnSaveCreateChannel = [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveCreateChannelTapped)];
    self.barBtnSaveCreateChannel.tintColor = [UIColor colorWithRed: (100 / 255.0f)
                                                             green: (99 / 255.0f)
                                                              blue: (112 / 255.0f)
                                                             alpha: 1.0f];
}


#pragma mark - setChannelOwner 

- (void)setChannelOwner:(ChannelOwner*)channelOwner {
    _channelOwner = channelOwner;
    self.model = [SYNProfileChannelModel modelWithChannelOwner:_channelOwner];
    self.model.delegate = self;
}

- (void)setShowingDescription:(BOOL)showingDescription {
	_showingDescription = showingDescription;
}

#pragma mark - Scrollview delegates

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    [self hideDescriptionCurrentlyShowing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    [self coverPhotoAnimation];
    [self moveNameLabelWithOffset:scrollView.contentOffset.y];
}

- (void)coverPhotoAnimation {
    if (self.cv.contentOffset.y<=0) {
        [self.headerView.coverImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.headerView.coverImageTop setConstant:self.cv.contentOffset.y];
    } else {
        [self.headerView.coverImage setContentMode:UIViewContentModeCenter];
        [self.headerView.coverImageTop setConstant:self.cv.contentOffset.y/PARALLAX_SCROLL_VALUE];
    }
}

- (void)moveNameLabelWithOffset :(CGFloat) offset {
    float offSetCheck = IS_IPHONE? FULL_NAME_LABEL_IPHONE: UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation]) ? FULL_NAME_LABEL_IPAD_PORTRAIT: FULLNAMELABELIPADLANDSCAPE;
    
    if (offset > offSetCheck) {
		[self.delegate showNavigationBar];
	} else {
		[self.delegate hideNavigationBar];
    }
}

#pragma mark - UICollectionView DataSource/Delegate

- (NSInteger)collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section {
     // to account for the extra 'creation' cell at the start of the collection view
    if (section == 1) {
        return 0;
    }
    return self.model.itemCount + (self.isUserProfile ? 1 : 0);
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
    return 2;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (self.isUserProfile && indexPath.row == 0) {
        // first row for a user profile only (create)
        
        SYNChannelCreateNewCell *createCell = [collectionView dequeueReusableCellWithReuseIdentifier: [SYNChannelCreateNewCell  reuseIdentifier]
                                                                                        forIndexPath: indexPath];
        
        if (self.creatingChannel) {
            createCell.state = CreateNewChannelCellStateEditing;
        } else {
            createCell.state = CreateNewChannelCellStateHidden;
        }
        createCell.viewControllerDelegate = self;
        
        self.createChannelCell = createCell;
        cell = createCell;
        
    } else {
        SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell" forIndexPath: indexPath];
        
        Channel *channel;
        channel = (Channel *) self.channelOwner.channelsSet[indexPath.item - (self.isUserProfile ? 1 : 0)];

        channelThumbnailCell.followButton.hidden = self.isUserProfile;
        channelThumbnailCell.channel = channel;
        
        // Disallow deletion of favourites cell
        BOOL isFavouritesCell = (self.isUserProfile && channel.favouritesValue);
        channelThumbnailCell.deletableCell = !isFavouritesCell;

        channelThumbnailCell.viewControllerDelegate = self;
        cell = channelThumbnailCell;
    }
	
    return cell;
}

- (void)collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath {
    
	if (self.isUserProfile && indexPath.row == 0) {
        return;
    }

    if (self.creatingChannel) {
        [self cancelCreateChannel];
        return;
    }
	
	
	if (self.showingDescription) {
		[self hideDescriptionCurrentlyShowing];
	}
	
	
	
    SYNChannelMidCell* cell = (SYNChannelMidCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    SYNChannelMidCell *selectedCell = cell;
    
    if (selectedCell.state != ChannelMidCellStateDefault) {
        [selectedCell setState: ChannelMidCellStateDefault withAnimation:YES];
        return;
    }
    
    SYNChannelDetailsViewController *channelVC;
    
    Channel *channel;
    
    
     if(self.isUserProfile) {
        
        channel = self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
        
        if (channel.favouritesValue) {
            channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsFavourites];
            [self.navigationController pushViewController:channelVC animated:YES];
            return;
        }
    } else {
        channel = self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
    }
    
    if (self.isUserProfile) {
        channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplayUser];
    } else {
        channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplay];
    }
    [self.navigationController pushViewController:channelVC animated:YES];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IS_IPHONE) {
        if (self.isUserProfile  && indexPath.row == 0 && !self.creatingChannel) {
            return CGSizeMake(320, 60);
        }
		
        if (self.isUserProfile  && indexPath.row == 0 && self.creatingChannel) {
            return CGSizeMake(320, 172);
        }
    }
    
    return ((UICollectionViewFlowLayout*)self.cv.collectionViewLayout).itemSize;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    // cant seem to get value from the layout
    
    
    if (section != 0) {
        return CGSizeZero;
    }
    if (IS_IPHONE) {
        if (self.isUserProfile) {
            return CGSizeMake(320, 560);
        } else {
            return CGSizeMake(320, 560);
        }
    } else {
        if (UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation])) {
            return CGSizeMake(self.view.frame.size.width, 780);
        } else {
            return CGSizeMake(self.view.frame.size.width, 664);
        }
    }
    return CGSizeZero;
}


- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath {
    UICollectionReusableView *supplementaryView = nil;
	if (kind == UICollectionElementKindSectionHeader) {
        
        supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                               withReuseIdentifier: [SYNProfileHeader reuseIdentifier]
                                                                      forIndexPath: indexPath];
        self.headerView = ((SYNProfileHeader*)supplementaryView);
        self.headerView.channelOwner = self.channelOwner;
        self.headerView.isUserProfile = self.isUserProfile;
        self.headerView.delegate = ((SYNProfileViewController*)self.parentViewController);
        supplementaryView = self.headerView;
    }
    
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
	return ((collectionView == self.cv && [self.model hasMoreItems]) ? [self footerSize] : CGSizeZero);
}


#pragma mark - CreateNewCelllDelegates

- (void)createNewButtonPressed {
  
    [[SYNTrackingManager sharedManager] trackCreateChannelScreenView];
    
    self.creatingChannel = YES;
    
    self.cv.scrollEnabled = NO;

    
    self.headerView.coverImage.alpha = ALPHA_IN_EDIT;

    self.createChannelCell.state = CreateNewChannelCellStateEditing;
    
    __weak SYNProfileChannelViewController *wself = self;
    [wself.cv setCollectionViewLayout:self.channelExpandedLayout animated:YES completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
        [wself setCreateOffset];
        }];
    }];
    
    self.parentViewController.navigationItem.leftBarButtonItem = self.barBtnCancelCreateChannel;
    self.parentViewController.navigationItem.rightBarButtonItem = self.barBtnSaveCreateChannel;
}


- (void)setCreateOffset{

    if (IS_IPHONE) {
            self.cv.contentOffset = CGPointMake(0, self.headerView.frame.size.height-64);
    } else {
        if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation])) {
            if (self.cv.contentOffset.y < 400) {
                self.cv.contentOffset =  CGPointMake(0, 429);
            }
        } else {
                self.cv.contentOffset =  CGPointMake(0, 444);
        }
    }
}


- (void)cancelCreateChannelWithBlock:(void (^)(void))callbackBlock {
    
    [self cancelCreateHelper];
    [self.cv setCollectionViewLayout:self.defaultLayout animated:YES completion:^(BOOL finished) {
        callbackBlock();
    }];
}

- (void)cancelCreateHelper {
	
	self.createChannelCell.descriptionTextView.text = @"";

    self.creatingChannel = NO;
    self.cv.scrollEnabled = YES;
    
    self.headerView.coverImage.alpha = 1.0;
    
    self.parentViewController.navigationItem.leftBarButtonItem = nil;
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
    
    [self.createChannelCell.createTextField resignFirstResponder];
    [self.createChannelCell.descriptionTextView resignFirstResponder];
    
    self.createChannelCell.state = CreateNewChannelCellStateHidden;

}

- (void)cancelCreateChannel {
    
    [self cancelCreateHelper];
    
    __weak SYNProfileChannelViewController *wself = self;
    [self.cv setCollectionViewLayout:self.defaultLayout animated:YES completion:^(BOOL finished) {
        [wself scrollUpWithTime];
    }];
}

- (void)updateCollectionLayout {
    
    if (self.cv.collectionViewLayout == self.defaultLayout) {
        [self.cv setCollectionViewLayout:self.channelExpandedLayout];
    } else {
        [self.cv setCollectionViewLayout:self.defaultLayout];
    }
}

- (void)scrollUpWithTime {
    if (self.channelOwner.channelsSet.count<=3 && IS_IPHONE) {
        [UIView animateWithDuration:0.4 animations:^{
            [self.cv setContentOffset:CGPointMake(0, 0) animated:YES];
        }];
    }
}

- (void)saveCreateChannelTapped {
    
	__weak SYNProfileChannelViewController *weakSelf = self;
	
    [appDelegate.oAuthNetworkEngine createChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     title: self.createChannelCell.createTextField.text
                                               description: self.createChannelCell.descriptionTextView.text
                                                  category: @""
                                                     cover: @""
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary *resourceCreated) {
											
											 NSString *name = [self.createChannelCell.createTextField.text uppercaseString];
											 [[SYNTrackingManager sharedManager] trackCollectionCreatedWithName:name];
			
                                            
                                             [self cancelCreateChannelWithBlock:^{
                                                 

												 weakSelf.headerView.channelOwner.totalVideosValueChannelValue--;
												 [weakSelf.headerView setSegmentedControllerText];
												 
												 [self createNewCollection];


                                             }];
                                             
                                         } errorHandler: ^(id error) {
                                             
                                             
                                             DebugLog(@"Error @ createChannelPressed:");
                                             
                                             NSString *errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                             NSString *errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_create_description", nil);
                                             
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
                                             }
                                             
                                             [self	 showError: errorMessage
                                               showErrorTitle: errorTitle];
                                         }];
}


- (void)showError: (NSString *) errorMessage showErrorTitle: (NSString *) errorTitle {
    [[[UIAlertView alloc] initWithTitle: errorTitle
                                message: errorMessage
                               delegate: nil
                      cancelButtonTitle: NSLocalizedString(@"OK", nil)
                      otherButtonTitles: nil] show];
}

- (void)createNewCollection {
    
    NSManagedObjectID *channelOwnerObjectId = self.channelOwner.objectID;
    NSManagedObjectContext *channelOwnerObjectMOC = self.channelOwner.managedObjectContext;
    MKNKUserErrorBlock errorBlock = ^(id error) {
        
    };
    
    __block float oldCount = self.channelOwner.channelsSet.count+1;
    
    __weak SYNProfileChannelViewController *weakSelf = self;
    
    
    [appDelegate.oAuthNetworkEngine userDataForUser: ((User *) self.channelOwner)
                                       onCompletion: ^(id dictionary) {
                                           
                                           NSError *error = nil;
                                           ChannelOwner * channelOwnerFromId = (ChannelOwner *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId error: &error];
                                           
                                           if (channelOwnerFromId) {
                                               [channelOwnerFromId setAttributesFromDictionary: dictionary
                                                                           ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
                                               if (weakSelf.channelOwner.channelsSet.count+1 > oldCount) {
                                                   
                                                   [weakSelf.cv performBatchUpdates:^{
                                                       
                                                       [weakSelf.cv insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:2 inSection:0]]];
                                                   } completion:^(BOOL finished) {
                                                       
                                                       [self showInboardingAnimationAfterCreate];
                                                   }];
                                               }
                                           } else {
                                               DebugLog (@"Channel disappeared from underneath us");
                                           }
                                       } onError: errorBlock];
}

#pragma mark - inboarding animations

- (void)showInboardingAnimationAfterCreate {
    SYNChannelMidCell *cell;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsCreateChannelFirstTime]) {
    
        if (self.isUserProfile) {
            cell = ((SYNChannelMidCell*)[self.cv cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]]);
            if (cell) {
                
                if (IS_IPHONE && !IS_IPHONE_5) {
                    [self.cv setContentOffset:CGPointMake(0, 300) animated:YES];
                }
                
                [cell descriptionAndDeleteAnimation];
            }
        } else {
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsCreateChannelFirstTime];
    }
}

- (void)showInboardingAnimationDescription {
   
    SYNChannelMidCell *cell;
    
    if (!self.isUserProfile) {
        cell = ((SYNChannelMidCell*)[self.cv cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
        
        NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey: kUserDefaultsOtherPersonsProfile];
        if (value<2)
        {
            if (cell) {
                value+=1;
                [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kUserDefaultsOtherPersonsProfile];
                
                if (IS_IPHONE) {
                    BOOL isIPhone4 = IS_IPHONE && !IS_IPHONE_5;
                    [self.cv setContentOffset: isIPhone4 ? CGPointMake(0, 150): CGPointMake(0, 150) animated:YES];
                }

                [cell descriptionAnimation];
            }
        }
    }
    else if (self.isUserProfile) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey: kUserDefaultsYourProfileFirstTime]) {
            cell = ((SYNChannelMidCell*)[self.cv cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]]);
            
            if (cell) {
                if (IS_IPHONE) {
                    BOOL isIPhone4 = IS_IPHONE && !IS_IPHONE_5;
                    [self.cv setContentOffset: isIPhone4 ? CGPointMake(0, 150): CGPointMake(0, 150) animated:YES];
                }
                
                [cell descriptionAnimation];
            } else {
                NSLog(@"cell is nil");
            }
            
            [[NSUserDefaults standardUserDefaults] setBool: YES
                                                    forKey: kUserDefaultsYourProfileFirstTime];
        }
    }
}

#pragma mark - setOffset

- (void)setContentOffSet: (CGPoint) offset {
    
    [self.cv setContentOffset:offset];
}

#pragma mark - Delete channel

- (void)deleteChannelTapped: (SYNChannelMidCell*) cell {
    
    self.deleteCell = cell;
    NSString *titleString = [NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Delete Collection", "Alerview confirm to delete a Channel"), cell.channel.title];
    
    [[[UIAlertView alloc] initWithTitle:titleString message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"No to alert view") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes to alert view") , nil] show];
}

- (void)deleteChannel:(SYNChannelMidCell *)cell {
    cell.state = ChannelMidCellStateDefault;
    
    __weak SYNProfileChannelViewController *weakSelf = self;
    
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId: appDelegate.currentUser.uniqueId
                                                 channelId: cell.channel.uniqueId
                                         completionHandler: ^(id response) {
                                             
                                             [weakSelf.cv performBatchUpdates:^{
                                                 [weakSelf.channelOwner.channelsSet removeObject:cell.channel];
                                                 
                                                 UIView *cellView = cell;
                                                 
                                                 weakSelf.indexPathToDelete = [weakSelf.cv indexPathForItemAtPoint: cellView.center];
                                                 
                                                 [weakSelf.cv deleteItemsAtIndexPaths:[NSArray arrayWithObject: weakSelf.indexPathToDelete]];
                                                 
                                             } completion:^(BOOL finished) {
                                                 [cell.channel.managedObjectContext deleteObject:cell.channel];
												 
												 weakSelf.headerView.channelOwner.totalVideosValueChannelValue--;
												 [weakSelf.headerView setSegmentedControllerText];
                                                 
                                             }];
                                         } errorHandler: ^(id error) {
                                             DebugLog(@"Delete channel failed");
                                         }];
}




- (void)cellStateChanged {
    [self hideDescriptionCurrentlyShowing];
	self.showingDescription = YES;
}


- (void) followButtonTapped:(SYNChannelMidCell *)cell {
	[self followButtonPressed:cell.followButton withChannel:cell.channel];
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[[SYNTrackingManager sharedManager] trackUserCollectionsFollowFromScreenName:[self trackingScreenName]];
    
    if (buttonIndex == 1) {
        [self deleteChannel:self.deleteCell];
    }
}


#pragma mark - Orientation change

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration {
	if (IS_IPHONE) {
        return;
    }

    [self updateLayoutForOrientation: toInterfaceOrientation];
}

- (void)updateLayoutForOrientation: (UIDeviceOrientation) orientation {
    
    
    if (UIDeviceOrientationIsPortrait(orientation)) {
        self.defaultLayout.sectionInset = UIEdgeInsetsMake(0, 44.0, 70.0, 44.0);
        self.defaultLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 701);
		self.defaultLayout.minimumLineSpacing = 14;
        self.channelExpandedLayout.sectionInset = UIEdgeInsetsMake(0, 44.0, 500.0, 44.0);

    } else {
        self.defaultLayout.sectionInset = UIEdgeInsetsMake(0.0, 21.0, 70.0, 21.0);
        self.defaultLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 574);
		self.defaultLayout.minimumLineSpacing = 14;
		self.channelExpandedLayout.sectionInset = UIEdgeInsetsMake(0, 21.0, 500.0, 21.0);
    }
    
    if (self.creatingChannel) {
        [self setCreateOffset];
    }
    
    [self.cv.collectionViewLayout invalidateLayout];
}

#pragma mark - Paging model delegates


- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel {

	[self.cv reloadData];
}

- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel {
}

#pragma mark - reset cells

- (void)hideDescriptionCurrentlyShowing {
    
    for (UICollectionViewCell *cell in [self.cv visibleCells]) {
        if ([cell isKindOfClass:[SYNChannelMidCell class]]) {
            if (((SYNChannelMidCell*)cell).state != ChannelMidCellStateAnimating) {
                [((SYNChannelMidCell*)cell) setState:ChannelMidCellStateDefault withAnimation:YES];
            }
        }
    }
	self.showingDescription = NO;
}

#pragma mark - textfield delegates


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.view addGestureRecognizer:self.tapToHideKeyoboard];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 25) ? NO : YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view removeGestureRecognizer:self.tapToHideKeyoboard];
    if (textField == self.createChannelCell.createTextField) {
        [self.createChannelCell.descriptionTextView becomeFirstResponder];
        
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}


#pragma mark - Text View Delegates

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.creatingChannel && self.createChannelCell.descriptionTextView == textView && [textView.text isEqualToString:@""]) {
        self.createChannelCell.descriptionPlaceholderLabel.hidden = NO;
    }
    
    [textView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.view addGestureRecognizer:self.tapToHideKeyoboard];
    if (self.creatingChannel && self.createChannelCell.descriptionTextView == textView ) {
        self.createChannelCell.descriptionPlaceholderLabel.hidden = YES;
        self.createChannelCell.descriptionTextView.text = @"";
        [self.createChannelCell.descriptionTextView performSelector:@selector(setText:) withObject:@"" afterDelay:0.1f];
        
    }
    [self setCreateOffset];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        
        if (textView == self.createChannelCell.descriptionTextView) {
            [self saveCreateChannelTapped];
        }
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 100) ? NO : YES;
}

- (BOOL)isUserProfile {
	return [_channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId];
}


#pragma mark - gesture reconiser methods

- (void)dismissKeyboard {
    [self.createChannelCell.descriptionTextView resignFirstResponder];
    [self.createChannelCell.createTextField resignFirstResponder];
    [self.view removeGestureRecognizer:self.tapToHideKeyoboard];
}

- (NSString*)trackingScreenName {
	return @"Profile";
}

@end
