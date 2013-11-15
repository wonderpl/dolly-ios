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
    
    BOOL creatingNewAnimating;
    
}

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UIButton *confirmButtom;

@property (nonatomic, strong) IBOutlet UICollectionView *currentChannelsCollectionView;

@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSIndexPath *previouslySelectedPath;
@property (nonatomic, weak) Channel *selectedChannel;

@property (nonatomic, weak) SYNAddToChannelCreateNewCell *createNewChannelCell;
@property (nonatomic, strong) SYNAddToChannelFlowLayout *normalFlowLayout;
@property (nonatomic, strong) SYNAddToChannelExpandedFlowLayout* expandedFlowLayout;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) UICollectionViewCell* selectedCell;



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
    [self.currentChannelsCollectionView registerNib: [UINib nibWithNibName: NSStringFromClass([SYNAddToChannelCreateNewCell class]) bundle: nil]
                          forCellWithReuseIdentifier: NSStringFromClass([SYNAddToChannelCreateNewCell class])];
    
    [self.currentChannelsCollectionView registerNib: [UINib nibWithNibName: NSStringFromClass([SYNAddToChannelCell class]) bundle: nil]
                          forCellWithReuseIdentifier: NSStringFromClass([SYNAddToChannelCell class])];
    
    
    self.currentChannelsCollectionView.scrollsToTop = NO;

    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    
    self.selectedChannel = nil;
    
    
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
        
        self.createNewChannelCell.delegate = self;
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
    {
       if(self.createNewChannelCell.isEditing)
           [self.createNewChannelCell endEditing:YES];
        return;
    }
    else
    {
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
                if(self.createNewChannelCell.isEditing) // then contract!
                {
                    frame.size.height = kChannelCellDefaultHeight;
                    ((SYNAddToChannelCreateNewCell*)cell).descriptionTextView.alpha = 0.0f;
                    
                    
                    
                    
                }
                else // expand
                {
                    frame.size.height = kChannelCellExpandedHeight;
                    ((SYNAddToChannelCreateNewCell*)cell).descriptionTextView.alpha = 1.0f;
                    
                    // show the button if hidden and change its title
                    
                    self.selectedChannel = nil;
                    self.confirmButtom.hidden = NO;
                    [self.confirmButtom setTitle:@"Create" forState:UIControlStateNormal];
                    
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
    
    if(self.createNewChannelCell.isEditing)
    {
        Channel* creatingChannelFromQ = appDelegate.videoQueue.currentlyCreatingChannel;
        creatingChannelFromQ.title = self.createNewChannelCell.nameInputTextField.text;
        creatingChannelFromQ.channelDescription = self.createNewChannelCell.descriptionTextView.text;
        
        [appDelegate.masterViewController.showingViewController viewChannelDetails:creatingChannelFromQ];
        
        
        [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
        return;
        
    }
    
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



#pragma mark - Set Selected Channel

-(void)setSelectedChannel:(Channel *)selectedChannel
{
    _selectedChannel = selectedChannel;
    if(_selectedChannel)
    {
        self.confirmButtom.hidden = NO;
        [self.confirmButtom setTitle:@"Add" forState:UIControlStateNormal];
    }
    else // passed nil
    {
        self.selectedCell.selected = NO;
        self.confirmButtom.hidden = YES;
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


@end
