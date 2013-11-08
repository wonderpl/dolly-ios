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
#import "SYNExistingChannelCreateNewCell.h"
#import "SYNCollectionDetailsViewController.h"
#import "SYNDeletionWobbleLayout.h"
#import "SYNDeviceManager.h"
#import "SYNExistingCollectionsViewController.h"
#import "SYNFacebookManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNExistingChannelCell.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
@import QuartzCore;


@interface SYNExistingCollectionsViewController ()
{
    BOOL creatingNewState;
    BOOL creatingNewAnimating;
    
}

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UIButton *confirmButtom;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionsCollectionView;
@property (nonatomic, strong) IBOutlet UILabel *autopostTitleLabel;
@property (nonatomic, strong) IBOutlet UIView *autopostView;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSIndexPath *previouslySelectedPath;
@property (nonatomic, weak) Channel *selectedChannel;

@property (nonatomic, weak) SYNExistingChannelCreateNewCell *createNewChannelCell;


// autopost stuff
@property (strong, nonatomic) IBOutlet UIButton *autopostNoButton;
@property (strong, nonatomic) IBOutlet UIButton *autopostYesButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;




@end


@implementation SYNExistingCollectionsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // == TODO: Delete? == //
    self.autopostTitleLabel.font = [UIFont lightCustomFontOfSize: self.autopostTitleLabel.font.pointSize];
    
    self.autopostNoButton.titleLabel.font = [UIFont regularCustomFontOfSize: self.autopostNoButton.titleLabel.font.pointSize];
    self.autopostYesButton.titleLabel.font = [UIFont regularCustomFontOfSize: self.autopostYesButton.titleLabel.font.pointSize];
    // ================= //
    
    
    [self.collectionsCollectionView registerNib: [UINib nibWithNibName: NSStringFromClass([SYNExistingChannelCreateNewCell class]) bundle: nil]
                          forCellWithReuseIdentifier: NSStringFromClass([SYNExistingChannelCreateNewCell class])];
    
    [self.collectionsCollectionView registerNib: [UINib nibWithNibName: NSStringFromClass([SYNExistingChannelCell class]) bundle: nil]
                          forCellWithReuseIdentifier: NSStringFromClass([SYNExistingChannelCell class])];
    
    
    self.collectionsCollectionView.scrollsToTop = NO;

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
    // == TODO: Delete? == //
    
    
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
    __weak SYNExistingCollectionsViewController *wself = self;
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
    
    self.collectionsCollectionView.scrollsToTop = YES;

    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Channels - Create - Select"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    self.closeButton.enabled = YES;
    self.confirmButtom.enabled = YES;
    
    // Copy Channels
    self.channels = [appDelegate.currentUser.channels array];
    
    if (self.selectedChannel)
    {
        int selectedIndex = [self.channels indexOfObject: self.selectedChannel];
        
        if (selectedIndex != NSNotFound)
        {
            self.selectedChannel = (self.channels)[selectedIndex];
            self.previouslySelectedPath = [NSIndexPath indexPathForRow: selectedIndex + 1
                                                             inSection: 0];
            self.confirmButtom.enabled = YES;
        }
        else
        {
            self.previouslySelectedPath = nil;
            self.selectedChannel = nil;
            self.confirmButtom.enabled = NO;
        }
    }
    else
    {
        self.previouslySelectedPath = nil;
        self.selectedChannel = nil;
        self.confirmButtom.enabled = NO;
    }
    
    
    [self.collectionsCollectionView reloadData];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    self.collectionsCollectionView.scrollsToTop = NO;
    
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
        self.createNewChannelCell = [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([SYNExistingChannelCreateNewCell class])
                                                                                        forIndexPath: indexPath];
        [self.createNewChannelCell.createNewButton addTarget:self
                                                      action:@selector(createNewButtonPressed)
                                            forControlEvents:UIControlEventTouchUpInside];
        cell = self.createNewChannelCell;
    }
    else
    {
        Channel *channel = (Channel *) self.channels[indexPath.row - 1];
        SYNExistingChannelCell *existingChannel = [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([SYNExistingChannelCell class])
                                                                                            forIndexPath: indexPath];
        
        existingChannel.titleLabel.text = channel.title;
        
        
        
        
        cell = existingChannel;
    }
    
    
    return cell;
}

- (CGSize)	collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout *) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    // TODO: Set for iPad as well...
    if(indexPath.row == 0 && creatingNewState)
    {
        return CGSizeMake(320.0f, 200.0f);
    }
    else
    {
        return CGSizeMake(320.0f, 60.0f);
    }
  
    
}

-(void)createNewButtonPressed
{
    if(creatingNewAnimating)
        return;
    
    creatingNewAnimating = YES;
    
    creatingNewState = !creatingNewState; // toggle state
    
    if(creatingNewState) // if it is opening, show the panel
    {
        self.createNewChannelCell.descriptionTextView.hidden = NO;
    }
    
    __weak SYNExistingCollectionsViewController* wself = self;
    
    [self.collectionsCollectionView performBatchUpdates:^{
        
        [wself.collectionsCollectionView reloadData];
        
    } completion:^(BOOL finished) {
        
        creatingNewAnimating = NO;
        if(!creatingNewState) // if it has just closed, hide the panel
        {
            wself.createNewChannelCell.descriptionTextView.hidden = YES;
        }
        
    }];
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    // the create new cell is not direclty selectable but listens to the button callback 'createNewButtonPressed'
    if(indexPath.row == 0)
        return;
    
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"channelSelectionClick"
                                                            label: @"New"
                                                            value: nil] build]];
    
    
    
    
    
}


- (IBAction) closeButtonPressed: (id) sender
{
    self.closeButton.enabled = NO;
    self.confirmButtom.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                        object: self];
    
    [self closeAnimation: ^(BOOL finished) {
        
        // will remove itself and will be deallocated since no other reference is held
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
}


- (IBAction) confirmButtonPressed: (id) sender
{
    if (!self.selectedChannel)
    {
        return;
    }
    
    self.confirmButtom.enabled = NO;
    self.closeButton.enabled = NO;
    
    [self closeAnimation: ^(BOOL finished) {
        [self.view removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteVideoAddedToExistingChannel
                                                            object: self
                                                          userInfo: @{kChannel: self.selectedChannel}];
    }];
}


- (void) closeAnimation: (void (^)(BOOL finished)) completionBlock
{
    [UIView animateWithDuration: kAddToChannelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         CGRect newFrame = self.view.frame;
                         newFrame.origin.y = newFrame.size.height;
                         self.view.frame = newFrame;
                     }
                     completion: completionBlock];
}


- (NSIndexPath *) indexPathForChannelCell: (UICollectionViewCell *) cell
{
    NSIndexPath *indexPath = [self.collectionsCollectionView indexPathForCell: cell];
    return  indexPath;
}


- (void) channelTapped: (UICollectionViewCell *) cell
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"channelSelectionClick"
                                                            label: @"Existing"
                                                            value: nil] build]];
    
    if (self.previouslySelectedPath)
    {
        SYNExistingChannelCell *cellToDeselect = (SYNExistingChannelCell *) [self.collectionsCollectionView cellForItemAtIndexPath: self.previouslySelectedPath];
        
    }
    
    SYNExistingChannelCell *cellToSelect = (SYNExistingChannelCell *) cell;
    
    
    //Compensate for the extra "create new" cell
    NSIndexPath *indexPath = [self indexPathForChannelCell: cell];
    
    self.selectedChannel = (Channel *) self.channels[indexPath.row - 1];
    self.previouslySelectedPath = indexPath;
    self.confirmButtom.enabled = YES;
}













@end
