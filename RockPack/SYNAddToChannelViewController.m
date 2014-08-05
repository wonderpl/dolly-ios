//
//  SYNExistingChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAddToChannelViewController.h"
#import "AppConstants.h"
#import "ExternalAccount.h"
#import "VideoInstance.h"
#import "SYNAddToChannelCreateNewCell.h"
#import "SYNFacebookManager.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNAddToChannelCell.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import "SYNMasterViewController.h"
#import <UIImageView+WebCache.h>
#import "SYNAddToChannelExpandedFlowLayout.h"
#import "SYNAddToChannelFlowLayout.h"
#import "UICollectionReusableView+Helpers.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNGenreManager.h"
#import "SYNTrackingManager.h"
#import "SYNChannelMidCell.h"
#import "SYNAddToChannelOverlayViewController.h"
#import <TestFlight.h>

#define kAnimationExpansion 0.4f

@import QuartzCore;


@interface SYNAddToChannelViewController ()
{
    
    BOOL creatingNewAnimating;
    
}

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UIButton *confirmButton;

@property (nonatomic, strong) IBOutlet UICollectionView *currentChannelsCollectionView;

@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSIndexPath *previouslySelectedPath;
@property (nonatomic, weak) Channel *selectedChannel;

@property (nonatomic, weak) SYNAddToChannelCreateNewCell *createNewChannelCell;
@property (nonatomic, strong) SYNAddToChannelFlowLayout *normalFlowLayout;
@property (nonatomic, strong) SYNAddToChannelExpandedFlowLayout* expandedFlowLayout;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) UICollectionViewCell* selectedCell;
@property (strong, nonatomic) IBOutlet UIView *topCorner;

@property (strong, nonatomic) IBOutlet UIView *topBarBackground;


@end


@implementation SYNAddToChannelViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // == On ipad the panel appears as a popup in the middle, with rounded corners
    if(IS_IPAD)
        self.view.layer.cornerRadius = 8.0f;
    
    // == Create the two layouts that will be switched
    self.expandedFlowLayout = [[SYNAddToChannelExpandedFlowLayout alloc] init];
    self.normalFlowLayout = [[SYNAddToChannelFlowLayout alloc] init];
    
    // == Start by setting the normal layout
    self.currentChannelsCollectionView.collectionViewLayout = self.normalFlowLayout;
    
    // == Register Xibs
    [self.currentChannelsCollectionView registerNib:[SYNAddToChannelCreateNewCell nib]
						 forCellWithReuseIdentifier:[SYNAddToChannelCreateNewCell reuseIdentifier]];
    
    [self.currentChannelsCollectionView registerNib:[SYNAddToChannelCell nib]
						 forCellWithReuseIdentifier:[SYNAddToChannelCell reuseIdentifier]];
    
    [self.currentChannelsCollectionView registerNib:[SYNChannelMidCell nib] forCellWithReuseIdentifier:[SYNChannelMidCell reuseIdentifier]];
    
    self.currentChannelsCollectionView.scrollsToTop = NO;

    self.currentChannelsCollectionView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
	self.closeButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.closeButton.titleLabel.font.pointSize];
	self.confirmButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.confirmButton.titleLabel.font.pointSize];
    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    self.selectedChannel = nil;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.topBarBackground.bounds byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.topBarBackground.bounds;
    maskLayer.path = maskPath.CGPath;
    self.topBarBackground.layer.mask = maskLayer;

    
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.currentChannelsCollectionView.scrollsToTop = YES;
    
    self.closeButton.enabled = YES;
    self.confirmButton.enabled = YES;
    
    // Copy Channels
    self.channels = [appDelegate.currentUser.channels array];

    [appDelegate.oAuthNetworkEngine userDataForUser: ((User *) appDelegate.currentUser)
                                            inRange: NSMakeRange(0, STANDARD_REQUEST_LENGTH)
                                       onCompletion: ^(id dictionary) {
                                           if (appDelegate.currentUser) {
                                               [appDelegate.currentUser setAttributesFromDictionary: dictionary
                                                                          ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
                                           }
                                           self.channels = [appDelegate.currentUser.channels array];
                                           [self.currentChannelsCollectionView reloadData];
                                       } onError: nil];

    [self.currentChannelsCollectionView reloadData];
    [self showInboarding];

}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    self.currentChannelsCollectionView.scrollsToTop = NO;
    
    self.channels = nil;
}

- (void)showInboarding {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsAddToCollectionFirstTime]) {
		SYNAddToChannelOverlayViewController *overlay = [[SYNAddToChannelOverlayViewController alloc] init];
        [overlay addToViewController:self];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsAddToCollectionFirstTime];
    }
}

#pragma mark - UICollectionView DataSource

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.channels.count + 1; // add one for the 'create new channel' cell
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell;
    
    if (indexPath.row == 0) // first row (create)
    {
        self.createNewChannelCell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNAddToChannelCreateNewCell reuseIdentifier]
                                                                              forIndexPath:indexPath];
        
        self.createNewChannelCell.delegate = self;
        cell = self.createNewChannelCell;
    }
    else
    {
        Channel *channel = (Channel *) self.channels[indexPath.row - 1];
        SYNChannelMidCell *existingChannel = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNChannelMidCell reuseIdentifier]
																						 forIndexPath:indexPath];
        
        existingChannel.channel = channel;
        existingChannel.followButton.hidden = YES;
        existingChannel.isFromProfile = NO;

        cell = existingChannel;
    }
    
    
    return cell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    // the create new cell is not direclty selectable but listens to the button callback 'createNewButtonPressed'
    if(indexPath.row == 0)
    {
       if(self.createNewChannelCell.isEditing)
           [self.createNewChannelCell endEditing:YES];
        return;
    }
    else
    {
		[[SYNTrackingManager sharedManager] trackCollectionSelectedIsNew:NO];
		
        self.selectedCell = [self.currentChannelsCollectionView cellForItemAtIndexPath:indexPath];
        self.selectedChannel = self.channels[indexPath.item - 1]; // (the channel index is +1 due to extra first channel)
    }
    
}

#pragma mark - Expansion of First Cell


-(void)createNewButtonPressed
{
    if(creatingNewAnimating)
        return;
    
    creatingNewAnimating = YES;
    
    // 1. Loop over all the cells and ani   mate manually
    
    int index = 0;
    for (UICollectionViewCell* cell in self.currentChannelsCollectionView.visibleCells)
    {
        
        NSIndexPath* indexPathForCell = [self.currentChannelsCollectionView indexPathForCell:cell];
        
        __block NSInteger iindex = indexPathForCell.item;
        void (^animateChangeWidth)(void) = ^{
            
            CGRect frame = cell.frame;
            
            
            if(cell == self.createNewChannelCell)
            {
                if(self.createNewChannelCell.isEditing) // then contract!
                {
                    frame.size.height = kChannelCellDefaultHeight;
                    ((SYNAddToChannelCreateNewCell*)cell).descriptionTextView.alpha = 0.0f;
                    
                    self.createNewChannelCell.separatorBottom.hidden = YES;
                    
                    
                }
                else // expand
                {
                    frame.size.height = kChannelCellExpandedHeight;
                    ((SYNAddToChannelCreateNewCell*)cell).descriptionTextView.alpha = 1.0f;
                    
                    // show the button if hidden and change its title
                    
                    self.selectedChannel = nil;
                    self.confirmButton.hidden = NO;
                    [self.confirmButton setTitle:@"create" forState:UIControlStateNormal];
                    
                }
                
                
            }
            else if(IS_IPHONE || (IS_IPAD && (iindex % 2 == 0)))
            {
                
                CGFloat correctAmount = (kChannelCellExpandedHeight - kChannelCellDefaultHeight);
                if(self.createNewChannelCell.state == CreateNewChannelCellStateEditing) // contract
                {
                    frame.origin.y -= correctAmount;
                }
                else
                {
                    frame.origin.y += correctAmount;
                }
                
            }
            cell.frame = frame;
        };
        
        index++;
        
        
        [UIView transitionWithView:cell
                          duration:kAnimationExpansion
                           options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                        animations:animateChangeWidth
                        completion:nil];
        
    }
    
    // 2. Time the completion of the animation to swap the layout
    
    [self performSelector:@selector(finilizeExpansionOfCell) withObject:self afterDelay:kAnimationExpansion];
    
    // send tracking information
    
    if(self.createNewChannelCell.state == CreateNewChannelCellStateHidden) // if it is opening, show the panel
    {
		[[SYNTrackingManager sharedManager] trackCreateChannelScreenView];
		
		[[SYNTrackingManager sharedManager] trackCollectionSelectedIsNew:YES];
    }
    

}

-(void)finilizeExpansionOfCell
{
    creatingNewAnimating = NO;
    
    if(self.createNewChannelCell.state == CreateNewChannelCellStateHidden)
        self.createNewChannelCell.state = CreateNewChannelCellStateEditing;
    else
        self.createNewChannelCell.state = CreateNewChannelCellStateHidden; // this catches the 2 editing states, 'editing' and 'finilizing'
    
    if(self.createNewChannelCell.state == CreateNewChannelCellStateEditing)
    {
        [self.currentChannelsCollectionView setCollectionViewLayout:self.expandedFlowLayout animated:YES];
        [self.currentChannelsCollectionView setContentOffset:CGPointMake(0.0f, 0.0f)];
    }
    else
    {
        [self.currentChannelsCollectionView setCollectionViewLayout:self.normalFlowLayout animated:YES];
    }
    
    self.createNewChannelCell.separatorBottom.hidden = NO;
}


#pragma mark - Main Controls Callbacks

- (IBAction)closeButtonPressed:(id)sender {
    self.closeButton.enabled = NO;
    self.confirmButton.enabled = NO;
    
    [self finishingPresentation];
	
	[self handleDismiss];
}


- (IBAction)confirmButtonPressed:(UIButton *)button {
	button.enabled = NO;
	
	[[SYNTrackingManager sharedManager] trackCollectionSaved];
	
	if (self.createNewChannelCell.isEditing) {
		// We don't have a channel, need to create one
		SYNAddToChannelCreateNewCell *cell = self.createNewChannelCell;
		NSString *description = (cell.editedDescription ? cell.descriptionTextView.text : @"");
		
		[appDelegate.oAuthNetworkEngine createChannelForUserId:appDelegate.currentOAuth2Credentials.userId
														 title:self.createNewChannelCell.nameInputTextField.text
												   description:description
													  category:@""
														 cover:@""
													  isPublic:YES
											 completionHandler:^(NSDictionary *response) {
												 
												 NSString *name = [self.createNewChannelCell.nameInputTextField.text uppercaseString];
												 [[SYNTrackingManager sharedManager] trackCollectionCreatedWithName:name];
												 
												 NSString *channelId = response[@"id"];
                                                 
                                                 if (channelId) {
                                                     [self addCurrentVideoInstanceToChannel:channelId isFavourites:NO];
                                                     
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:kChannelOwnerUpdateRequest
                                                                                                         object:nil
                                                                                                       userInfo: @{kChannelOwner : appDelegate.currentUser }];
                                                 }
											 } errorHandler:^(NSDictionary *response) {
												 NSString* messageE = IS_IPHONE ? NSLocalizedString(@"VIDEO NOT ADDED",nil) : NSLocalizedString(@"YOUR VIDEOS COULD NOT BE ADDED INTO YOUR COLLECTION",nil);
												 
												 [appDelegate.masterViewController presentNotificationWithMessage:messageE
																										  andType:NotificationMessageTypeError];
											 }];
	}
	
	if (self.selectedChannel) {
		[self addCurrentVideoInstanceToChannel:self.selectedChannel.uniqueId isFavourites:self.selectedChannel.favouritesValue];
	}
}

- (void)addCurrentVideoInstanceToChannel:(NSString *)channelId isFavourites:(BOOL)isFavourites {
    
    TFLog(@"Current User ID: %@",appDelegate.currentUser.uniqueId );
    TFLog(@"Channel ID: %@",channelId);
    TFLog(@"VideoInstance ID: %@",self.videoInstance.uniqueId);
    
    [appDelegate.oAuthNetworkEngine updateVideosForUserId:appDelegate.currentUser.uniqueId
											 forChannelId:channelId
										 videoInstanceIds:@[ self.videoInstance.uniqueId ]
											clearPrevious:NO
										completionHandler: ^(NSDictionary* result) {
											[[SYNTrackingManager sharedManager] trackVideoAddedToCollectionCompleted:isFavourites];
											
											NSString* messageS = IS_IPHONE ? NSLocalizedString(@"VIDEO ADDED",nil) : NSLocalizedString(@"YOUR VIDEOS HAVE BEEN ADDED INTO YOUR COLLECTION", nil);
											
											[appDelegate.masterViewController presentNotificationWithMessage:messageS
																									 andType:NotificationMessageTypeSuccess];
											
											[[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
																								object: self];
											
											[self handleDismiss];
										} errorHandler:^(NSDictionary* errorDictionary) {
											
											[[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
																								object: self];
											
											NSString* messageE = IS_IPHONE ? NSLocalizedString(@"AN ERROR HAS OCCURRED",nil) : NSLocalizedString(@"AN ERROR HAS OCCURRED WHEN ADDING INTO YOUR COLLECTION",nil);
											
											[appDelegate.masterViewController presentNotificationWithMessage:messageE
																									 andType:NotificationMessageTypeError];
										}];
}


#pragma mark - Set Selected Channel

-(void)setSelectedChannel:(Channel *)selectedChannel
{
    
    if(selectedChannel)
    {
        
        if(self.createNewChannelCell.isEditing) // if it is editing (open), close that cell
            [self createNewButtonPressed];
        
        
        
        self.confirmButton.hidden = NO;
        [self.confirmButton setTitle:@"add" forState:UIControlStateNormal];
    }
    else // passed nil probably by pressing on the "create new channel" cell
    {
        self.selectedCell.selected = NO;
        self.confirmButton.hidden = YES;
    }
    
    _selectedChannel = selectedChannel;
}

- (void)handleDismiss {
	if (self.presentingViewController) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		[appDelegate.masterViewController removeOverlayControllerAnimated:YES];
	}
}

#pragma mark - Popoverable

-(void)startingPresentation
{
    
}
-(void)finishingPresentation
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                        object: self];
}


- (NSUInteger)supportedInterfaceOrientations
{
    if (IS_IPHONE) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

@end
