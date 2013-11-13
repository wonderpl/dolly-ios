//
//  SYNExistingChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "AppConstants.h"
#import "ChannelCover.h"
#import "ExternalAccount.h"
#import "GAI.h"
#import "SYNAddToChannelCreateNewCell.h"
#import "SYNCollectionDetailsViewController.h"
#import "SYNDeletionWobbleLayout.h"
#import "SYNDeviceManager.h"
#import "SYNAddToChannelViewController.h"
#import "SYNFacebookManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNAddToChannelCell.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import "SYNMasterViewController.h"
#import "UIImageView+WebCache.h"
#import "SYNAddToChannelExpandedFlowLayout.h"
#import "SYNAddToChannelFlowLayout.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationExpansion 0.4f

@import QuartzCore;


@interface SYNAddToChannelViewController ()
{
    BOOL creatingNewState;
    BOOL creatingNewAnimating;
    
}

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UIButton *confirmButtom;
@property (nonatomic, strong) IBOutlet UICollectionView *currentChannelsCollectionView;
@property (nonatomic, strong) IBOutlet UILabel *autopostTitleLabel;
@property (nonatomic, strong) IBOutlet UIView *autopostView;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSIndexPath *previouslySelectedPath;
@property (nonatomic, weak) Channel *selectedChannel;

@property (nonatomic, weak) SYNAddToChannelCreateNewCell *createNewChannelCell;
@property (nonatomic, strong) SYNAddToChannelFlowLayout *normalFlowLayout;
@property (nonatomic, strong) SYNAddToChannelExpandedFlowLayout* expandedFlowLayout;


// autopost stuff
@property (strong, nonatomic) IBOutlet UIButton *autopostNoButton;
@property (strong, nonatomic) IBOutlet UIButton *autopostYesButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;




@end


@implementation SYNAddToChannelViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // == TODO: Delete? == //
    self.autopostTitleLabel.font = [UIFont lightCustomFontOfSize: self.autopostTitleLabel.font.pointSize];
    self.autopostNoButton.titleLabel.font = [UIFont regularCustomFontOfSize: self.autopostNoButton.titleLabel.font.pointSize];
    self.autopostYesButton.titleLabel.font = [UIFont regularCustomFontOfSize: self.autopostYesButton.titleLabel.font.pointSize];
 
    
    // == Set the button to 'Add' Mode since we have not yet pressed the create new button
    [self.confirmButtom setTitle:@"Add" forState:UIControlStateNormal];
    self.confirmButtom.enabled = NO;
    
    // == On ipad the panel appears as a popup in the middle, with rounded corners
    if(IS_IPAD)
        self.view.layer.cornerRadius = 8.0f;
    
    self.expandedFlowLayout = [[SYNAddToChannelExpandedFlowLayout alloc] init];
    self.normalFlowLayout = [[SYNAddToChannelFlowLayout alloc] init];
    
    self.currentChannelsCollectionView.collectionViewLayout = self.normalFlowLayout;
    
    creatingNewState = NO;
    
    [self.currentChannelsCollectionView registerNib: [UINib nibWithNibName: NSStringFromClass([SYNAddToChannelCreateNewCell class]) bundle: nil]
                          forCellWithReuseIdentifier: NSStringFromClass([SYNAddToChannelCreateNewCell class])];
    
    [self.currentChannelsCollectionView registerNib: [UINib nibWithNibName: NSStringFromClass([SYNAddToChannelCell class]) bundle: nil]
                          forCellWithReuseIdentifier: NSStringFromClass([SYNAddToChannelCell class])];
    
    
    self.currentChannelsCollectionView.scrollsToTop = NO;

    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    // == TODO: Delete? == //
    ExternalAccount *facebookAccount = appDelegate.currentUser.facebookAccount;
    
    if (facebookAccount)
    {
        if ([[SYNFacebookManager sharedFBManager] hasActiveSessionWithPermissionType: FacebookPublishPermission] &&
            (facebookAccount.flagsValue & ExternalAccountFlagAutopostAdd))
        {
            [self switchAutopostViewToYes: YES];
        }
        else
        {
            [self switchAutopostViewToYes: NO];
        }
        
        self.autopostView.hidden = NO;
    }
    else
    {
        self.autopostView.hidden = YES;
    }
    
    
    
}


- (void) switchAutopostViewToYes: (BOOL) value
{
    self.autopostYesButton.selected = value;
    self.autopostNoButton.selected = !value;
}


- (IBAction) autopostButtonPressed: (UIButton *) sender
{
    if (sender.selected) // button is pressed twice
        return;
    
    ExternalAccount *facebookAccount = appDelegate.currentUser.facebookAccount;
    __weak SYNAddToChannelViewController *wself = self;
    __weak SYNAppDelegate *wAppDelegate = appDelegate;
    BOOL isYesButton = (sender == self.autopostYesButton);
    
    // steps
    void (^ ErrorBlock)(id) = ^(id error) {
        [wself switchAutopostViewToYes: !isYesButton];
    };
    
    void (^ CompletionBlock)(id) = ^(id no_responce) {
        if (isYesButton)
        {
            [wAppDelegate.currentUser
             setFlag: ExternalAccountFlagAutopostAdd
             toExternalAccount: kFacebook];
        }
        else
        {
            [wAppDelegate.currentUser
             unsetFlag: ExternalAccountFlagAutopostAdd
             toExternalAccount: kFacebook];
        }
        
        [wAppDelegate saveContext: YES];
        
        [wself switchAutopostViewToYes: isYesButton];
        
        if (isYesButton)
        {
            // this is a replacement for the sharing granularity
            
            id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

            [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                   action: @"videoShared"
                                                                    label: @"fbe"
                                                                    value: nil] build]];
        }
    };
    
    if (isYesButton)
    {
        // if the SDK has already the 'publish' options on, it will just call the return function()
        [[SYNFacebookManager sharedFBManager] openSessionWithPermissionType: kFacebookPermissionTypePublish
                                                                  onSuccess: ^{
                                                                      
                        // connect to external account so as to register the new access token with extended priviledges
                       [wAppDelegate.oAuthNetworkEngine connectFacebookAccountForUserId: wAppDelegate.currentUser.uniqueId
                                                                     andAccessTokenData: [[FBSession activeSession] accessTokenData]
                                                                      completionHandler: ^(id no_responce) {
                                                                          
                                                    if (facebookAccount.flagsValue & ExternalAccountFlagAutopostAdd)
                                                    {
                                                        CompletionBlock(no_responce);
                                                    }
                                                    else
                                                    {
                                                                               // set the flag on the server...
                                                      [wAppDelegate.oAuthNetworkEngine setFlag: @"facebook_autopost_add"
                                                                                     withValue: isYesButton
                                                                                      forUseId: appDelegate.currentUser.uniqueId
                                                                             completionHandler: CompletionBlock
                                                                                  errorHandler: ErrorBlock];
                                                    }
                                                                          
                                                } errorHandler: ErrorBlock];
                        }
         
         
                                    onFailure: ErrorBlock];
    }
    else
    {
        [wAppDelegate.oAuthNetworkEngine setFlag: @"facebook_autopost_add"
                                       withValue: isYesButton // should be no
                                        forUseId: appDelegate.currentUser.uniqueId
                               completionHandler: CompletionBlock
                                    errorHandler: ErrorBlock];
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.currentChannelsCollectionView.scrollsToTop = YES;

    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Channels - Create - Select"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    self.closeButton.enabled = YES;
    self.confirmButtom.enabled = YES;
    
    // Copy Channels
    self.channels = [appDelegate.currentUser.channels array];
    
    
    [self.currentChannelsCollectionView reloadData];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    self.currentChannelsCollectionView.scrollsToTop = NO;
    
    self.channels = nil;
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
        self.createNewChannelCell = [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([SYNAddToChannelCreateNewCell class])
                                                                              forIndexPath: indexPath];
        [self.createNewChannelCell.createNewButton addTarget:self
                                                      action:@selector(createNewButtonPressed)
                                            forControlEvents:UIControlEventTouchUpInside];
        cell = self.createNewChannelCell;
    }
    else
    {
        Channel *channel = (Channel *) self.channels[indexPath.row - 1];
        SYNAddToChannelCell *existingChannel = [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([SYNAddToChannelCell class])
                                                                                            forIndexPath: indexPath];
        
        existingChannel.titleLabel.text = channel.title;
        
        cell = existingChannel;
    }
    
    
    return cell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    // the create new cell is not direclty selectable but listens to the button callback 'createNewButtonPressed'
    if(indexPath.row == 0)
        return;
    
    self.selectedChannel = self.channels[indexPath.item - 1]; // channels will be plus one due to extra first channel
    
}

#pragma mark - Expansion of First Cell


-(void)createNewButtonPressed
{
    if(creatingNewAnimating)
        return;
    
    creatingNewAnimating = YES;
    
//    [self.currentChannelsCollectionView.collectionViewLayout invalidateLayout];
//    [self.currentChannelsCollectionView invalidateIntrinsicContentSize];
    
    
    
    // 1. Loop over all the cells and animate manually
    
    int index = 0;
    for (UICollectionViewCell* cell in self.currentChannelsCollectionView.visibleCells)
    {
        
        NSIndexPath* indexPathForCell = [self.currentChannelsCollectionView indexPathForCell:cell];
        
        __block int iindex = indexPathForCell.item;
        void (^animateChangeWidth)(void) = ^{
            
            CGRect frame = cell.frame;
            
            
            if(cell == self.createNewChannelCell)
            {
                if(creatingNewState) // if in "create new" state -> contract
                {
                    frame.size.height = kChannelCellDefaultHeight;
                    ((SYNAddToChannelCreateNewCell*)cell).descriptionTextView.alpha = 0.0f;
                    
                    [self.confirmButtom setTitle:@"Create" forState:UIControlStateNormal];
                }
                else
                {
                    frame.size.height = kChannelCellExpandedHeight;
                    ((SYNAddToChannelCreateNewCell*)cell).descriptionTextView.alpha = 1.0f;
                    
                    [self.confirmButtom setTitle:@"Add" forState:UIControlStateNormal];
                }
                
                
            }
            else if(IS_IPHONE || (IS_IPAD && (iindex % 2 == 0)))
            {
                
                CGFloat correctAmount = (kChannelCellExpandedHeight - kChannelCellDefaultHeight);
                if(creatingNewState) // if in create new state -> contract
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
    
    if(!creatingNewState) // if it is opening, show the panel
    {
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                               action: @"channelSelectionClick"
                                                                label: @"New"
                                                                value: nil] build]];
        
    }
    

}

-(void)finilizeExpansionOfCell
{
    creatingNewAnimating = NO;
    
    creatingNewState = !creatingNewState;
    
    if(creatingNewState)
    {
        [self.currentChannelsCollectionView setCollectionViewLayout:self.expandedFlowLayout animated:YES];
    }
    else
    {
        [self.currentChannelsCollectionView setCollectionViewLayout:self.normalFlowLayout animated:YES];
    }
}


#pragma mark - Main Controls Callbacks

- (IBAction) closeButtonPressed: (id) sender
{
    self.closeButton.enabled = NO;
    self.confirmButtom.enabled = NO;
    
    [self finishingPresentation];
    
    [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
}


- (IBAction) confirmButtonPressed: (id) sender
{
    if (!self.selectedChannel)
    {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteVideoAddedToExistingChannel
                                                        object: self
                                                      userInfo: @{kChannel: self.selectedChannel}];
    
    self.selectedChannel = nil;
    
    self.closeButton.enabled = NO; // protect from double closing the panel
    [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
}


-(void)setSelectedChannel:(Channel *)selectedChannel
{
    _selectedChannel = selectedChannel;
    if(_selectedChannel)
        self.confirmButtom.enabled = YES;
    else
        self.confirmButtom.enabled = NO;
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


@end
