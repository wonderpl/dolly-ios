//
//  SYNSubscribersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNSubscribersViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNMasterViewController.h"
#import "SYNFriendCell.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNTrackingManager.h"
#import "SYNSocialButton.h"

@interface SYNSubscribersViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SYNSocialActionsDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) IBOutlet UICollectionView *usersThumbnailCollectionView;
@property (nonatomic, strong) NSArray* users;

@end


@implementation SYNSubscribersViewController


- (id) initWithChannel: (Channel *) channel
{
    if (self = [super initWithViewId: kSubscribersListViewId])
    {
        
        self.channel = channel;
        self.title = @"Followers";
        
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.users = @[];
    
    if (IS_IPHONE)
    {
        self.usersThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.usersThumbnailCollectionView.backgroundColor = [UIColor whiteColor];
    }
    
    [self.usersThumbnailCollectionView registerNib:[SYNFriendCell nib]
                        forCellWithReuseIdentifier:[SYNFriendCell reuseIdentifier]];
    
    [self.usersThumbnailCollectionView registerNib:[SYNChannelFooterMoreView nib]
                        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                               withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    
    self.activityView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    
    [self.activityView hidesWhenStopped];
    
    [self.activityView startAnimating];
    
    [self setInfoLabelText: @"LOADING"];
    
    [self.view addSubview: self.activityView];
    
    [appDelegate.searchRegistry clearImportContextFromEntityName:kChannelOwner andViewId:self.viewId];
    
    [appDelegate.networkEngine subscribersForUserId: appDelegate.currentUser.uniqueId
                                          channelId: self.channel.uniqueId
                                           forRange: self.dataRequestRange
                                        byAppending: NO
                                  completionHandler: ^(int count) {
                                      
                                      self.dataItemsAvailable = count;
                                      
                                      [self displayUsers];
                                      
                                      [self.activityView stopAnimating];
                                      
                                      
                                      if (IS_IPHONE) {
                                          CGRect tmp = self.usersThumbnailCollectionView.frame;
                                          tmp.origin.y+=self.view.frame.size.height;
                                          self.usersThumbnailCollectionView.frame = tmp;
                                          
                                          tmp = self.usersThumbnailCollectionView.frame;
                                          tmp.origin.y -= self.view.frame.size.height;
                                          
                                          [UIView animateWithDuration:0.8f animations:^{
                                              
                                              self.usersThumbnailCollectionView.frame = tmp;
                                              
                                          }];
                                          
                                      }
                                      
                                  } errorHandler: ^{
                                      
                                      [self.activityView stopAnimating];
                                  }];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackCollectionFollowersScreenView];
}


- (void) setInfoLabelText: (NSString *) text
{
    CGFloat width = self.infoLabel.frame.size.width;
    
    if (!text) // clear
    {
        [self.infoLabel removeFromSuperview];
        return;
    }
    
    self.infoLabel.text = text;
    [self.infoLabel sizeToFit];
    CGRect newFrame = self.infoLabel.frame;
    newFrame.size.width = width;
    self.infoLabel.frame = newFrame;
    CGPoint position = CGPointMake(self.view.center.x, 200.0);
    self.infoLabel.center = position;
    self.infoLabel.frame = CGRectIntegral(self.infoLabel.frame);
    
    [self.view addSubview: self.infoLabel];
    
    position.y += 40.0;
    self.activityView.center = position;
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.users.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNFriendCell* userCell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNFriendCell reuseIdentifier]
                                                                        forIndexPath:indexPath];
    
    ChannelOwner* channelOwner = (ChannelOwner*)self.users[indexPath.item];
    
    userCell.channelOwner = channelOwner;
    userCell.delegate = self;
    userCell.followButton.hidden = YES;
    
    return userCell;
}






- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
           referenceSizeForFooterInSection: (NSInteger) section
{
    CGSize footerSize;
    
    if (collectionView == self.usersThumbnailCollectionView && self.users.count != 0)
    {
        footerSize = [self footerSize];
        
        // Now set to zero anyway if we have already read in all the items
        NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
        
        // FIXME: Is this comparison correct?  Should it just be self.dataRequestRange.location >= self.dataItemsAvailable?
        if (nextStart >= self.dataItemsAvailable)
        {
            footerSize = CGSizeZero;
        }
    }
    else
    {
        footerSize = CGSizeZero;
    }
    
    return footerSize;
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (IS_IPHONE)
    {
		[appDelegate.masterViewController removeOverlayControllerAnimated:YES];
    }
    
}

#pragma mark - Footer support

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight
        && self.isLoadingMoreContent == NO)
    {
        [self loadMoreUsers];
    }
}

- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    
    UICollectionReusableView* supplementaryView;
    
    if (collectionView == self.usersThumbnailCollectionView)
    {
        if (kind == UICollectionElementKindSectionFooter)
        {
            self.footerView = [self.usersThumbnailCollectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                    withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]
                                                                                           forIndexPath:indexPath];
            supplementaryView = self.footerView;
            
            if (self.users.count > 0)
            {
                self.footerView.showsLoading = self.isLoadingMoreContent;
            }
        }
    }
    
    return supplementaryView;
}

- (CGSize) footerSize
{
    return CGSizeMake(100.0, 40.0);
}

- (void) loadMoreUsers
{
    // Check to see if we have loaded all items already
    if (self.moreItemsToLoad == TRUE)
    {
        self.loadingMoreContent = YES;
        
        [self incrementRangeForNextRequest];
        
        [appDelegate.networkEngine subscribersForUserId: appDelegate.currentUser.uniqueId
                                              channelId: self.channel.uniqueId
                                               forRange: self.dataRequestRange
                                            byAppending: YES
                                      completionHandler: ^(int count) {
                                          
                                          
                                          self.dataItemsAvailable = count;
                                          self.loadingMoreContent = NO;
                                          [self displayUsers];
                                          
                                          
                                      } errorHandler: ^{
                                          
                                          
                                      }];
    }
}



#pragma mark - Displayig Data

- (void) displayUsers
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName: kChannelOwner
                                 inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    request.predicate = [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"position"
                                                              ascending: YES]];
    request.fetchBatchSize = 20;
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: request
                                                                                  error: &error];
    
    if (!resultsArray)
    {
        return;
    }
    
    self.users = [NSMutableArray arrayWithArray: resultsArray];
    
    if (self.users.count == 0)
    {
        [self setInfoLabelText: @"No one has subscribed into this collection yet"];
    }
    else
    {
        [self setInfoLabelText: nil];
    }
    
    [self.usersThumbnailCollectionView reloadData];
}

- (void) profileButtonTapped: (UIButton *) profileButton
{
    if(!profileButton)
    {
        AssertOrLog(@"No profileButton passed");
        return; // did not manage to get the cell
    }
    
    id candidate = profileButton;
    while (![candidate isKindOfClass:[SYNFriendCell class]]) {
        candidate = [candidate superview];
    }
    
    if(![candidate isKindOfClass:[SYNFriendCell class]])
    {
        AssertOrLog(@"Did not manage to get the cell from: %@", profileButton);
        return; // did not manage to get the cell
    }
    SYNFriendCell* searchUserCell = (SYNFriendCell*)candidate;
    
    if(IS_IPAD)
    {
        
        [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
    }
	
	//in IPad this view is displayed in a pop over so we call viewProfileDetails on the top VC
    [appDelegate.masterViewController.showingViewController viewProfileDetails:searchUserCell.channelOwner];
    
}



@end
