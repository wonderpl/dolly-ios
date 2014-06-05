//
//  SYNFriendsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFriendsViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNFacebookManager.h"
#import "ChannelOwner.h"
#import "SYNFriendCell.h"
#import <UIImageView+WebCache.h>
#import "SYNAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SYNOAuthNetworkEngine.h"
#import "Friend.h"
#import "SYNFacebookManager.h"
#import "SYNMasterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNTrackingManager.h"
#import "SYNSocialButton.h"

@interface SYNFriendsViewController () <UIScrollViewDelegate> {
    BOOL hasAttemptedToLoadData;
}

@property (nonatomic, strong) NSArray* friends;
@property (nonatomic) BOOL onRockpackFilterOn;
@property (nonatomic, weak) Friend* currentlySelectedFriend;
@property (nonatomic, strong) NSMutableString* currentSearchTerm;

@property (nonatomic, strong) IBOutlet UIImageView* emptyFriendsImageView;


@end

@implementation SYNFriendsViewController

@synthesize onRockpackFilterOn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    onRockpackFilterOn = NO;
    
    self.currentSearchTerm = [[NSMutableString alloc] init];
    
    
    self.friends = [NSArray array];
    
    
    // == Register Cells == //
    
    [self.friendsCollectionView registerNib: [UINib nibWithNibName: @"SYNFriendCell" bundle: nil]
                 forCellWithReuseIdentifier: @"SYNFriendCell"];
    
    self.preLoginLabel.font = [UIFont lightCustomFontOfSize:self.preLoginLabel.font.pointSize];
    self.preLoginLabel.text = NSLocalizedString (@"friends_invite", nil);
    [self.activityIndicator hidesWhenStopped];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
    if ([[SYNFacebookManager sharedFBManager] hasActiveSession]) {
        self.facebookLoginButton.hidden = YES;
        
        self.friendsCollectionView.hidden = NO;
        self.activityIndicator.hidden = NO;
		
        [self fetchAndDisplayFriends];
        
		[[SYNTrackingManager sharedManager] trackFriendsScreenView];
    } else {
        self.facebookLoginButton.hidden = NO;
        
        self.friendsCollectionView.hidden = YES;
        self.activityIndicator.hidden = YES;
        
		[[SYNTrackingManager sharedManager] trackFriendsFBConnectScreenView];
    }
}

-(void)fetchAndDisplayFriends
{
    
    NSError *error;
    NSArray *existingFriendsArray;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"externalSystem == %@ && resourceURL != NULL", kFacebook];
    
    existingFriendsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                                 error: &error];
    
    if(!error)
    {
   
        self.friends = [NSArray arrayWithArray:existingFriendsArray];
        
        [self.friendsCollectionView reloadData];
        
    }
    
    if(hasAttemptedToLoadData)
        return;
    
    hasAttemptedToLoadData = YES;
    
    __weak SYNFriendsViewController* weakSelf = self;
    
    self.emptyFriendsImageView.hidden = YES;
    
    [self.activityIndicator startAnimating];
    self.preLoginLabel.text = NSLocalizedString (@"friends_loading", nil);
    
    [appDelegate.oAuthNetworkEngine friendsForUser:appDelegate.currentUser
                                        onlyRecent:NO
                                 completionHandler:^(id dictionary) {
        
                                     if([appDelegate.searchRegistry registerFriendsFromDictionary:dictionary])
                                     {
                                         [weakSelf fetchAndDisplayFriends];
                                     }
                                     else
                                     {
                                         DebugLog(@"There was a problem loading friends");
                                     }
                                     
                                     
                                     [self.activityIndicator stopAnimating];
        
                                     
        
                                     [self fetchAndDisplayFriends];
        
                                     if(self.friends.count == 0)
                                     {
                                         self.emptyFriendsImageView.hidden = NO;
                                         self.preLoginLabel.hidden = NO;
                                         self.preLoginLabel.text = NSLocalizedString (@"friends_empty", nil);
                                     }
                                     else
                                     {
                                         self.preLoginLabel.hidden = YES;
                                     }
                                     
        
                                 } errorHandler:^(id dictionary) {
                                     [self.activityIndicator stopAnimating];
                                     
        
                                 }];
}




-(IBAction)facebookLoginPressed:(id)sender
{
    self.activityIndicator.center = self.facebookLoginButton.center;
    
    [self.activityIndicator startAnimating];
    
    self.facebookLoginButton.hidden = YES;
    
    self.preLoginLabel.text = @"Logging In";
    
    //Weak variables to avoid block retain cycles
    __weak SYNFriendsViewController* weakSelf = self;
    __weak SYNAppDelegate* weakAppDelegate = appDelegate;
    
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    
    [facebookManager loginOnSuccess: ^(NSDictionary<FBGraphUser> *dictionary) {
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        [weakAppDelegate.oAuthNetworkEngine connectFacebookAccountForUserId: appDelegate.currentUser.uniqueId
                                                         andAccessTokenData: accessTokenData
                                                          completionHandler: ^(id no_responce) {
                                                              
                                                              [weakSelf.activityIndicator stopAnimating];
                                                              
                                                              weakSelf.friendsCollectionView.hidden = NO;
                                                              weakSelf.preLoginLabel.hidden = YES;
                                                              weakSelf.facebookLoginButton.hidden = YES;
                                                              
                                                              
                                                              [weakSelf fetchAndDisplayFriends];
            
                                                          } errorHandler:^(id error) {
                                                              
                                                              [weakSelf.activityIndicator stopAnimating];
                                                              
                                                              weakSelf.facebookLoginButton.hidden = NO;
                                                              
                                                              weakSelf.preLoginLabel.text = @"We could not log you in because this FB account seems to be associated with a different User.";
                                                              
                                                              [[SYNFacebookManager sharedFBManager] logoutOnSuccess:^{
                                                                  
                                                              } onFailure:^(NSString *errorMessage) {
                                                                  
                                                              }];
            
                                                          }];
        
        
    } onFailure: ^(NSString* errorString) {
        
        [weakSelf.activityIndicator stopAnimating];
        
        weakSelf.facebookLoginButton.hidden = NO;
        
        weakSelf.preLoginLabel.text = @"Log in with Facebook was cancelled.";
        
        
     }];

}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.friends.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    Friend *friend = self.friends[indexPath.row];
    
    SYNFriendCell *userCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendCell"
                                                                                            forIndexPath: indexPath];
    
    userCell.channelOwner = (ChannelOwner*)(friend);
    userCell.delegate = self;
    
    // As the followButton needs to be a SYNSocialButton to tie in with the callbacks we just need to style it on the fly
    
    userCell.followButton.backgroundColor = [UIColor clearColor];
    // ================= //
    
    
    return userCell;
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
    
    [self viewProfileDetails:searchUserCell.channelOwner];
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    Friend* selectedFriend = self.friends[indexPath.item];
    
    
    [self viewProfileDetails:(ChannelOwner*)selectedFriend];
    
}

-(NSString*)title
{
    return viewId;
}


@end
