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
#import "SYNSearchResultsUserCell.h"
#import "UIImageView+WebCache.h"
#import "SYNAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SYNOAuthNetworkEngine.h"
#import "Friend.h"
#import "GAI.h"
#import "SYNFacebookManager.h"
#import "SYNMasterViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface SYNFriendsViewController () <UIScrollViewDelegate> {
    BOOL hasAttemptedToLoadData;
}

@property (nonatomic, strong) NSArray* friends;
@property (nonatomic) BOOL onRockpackFilterOn;
@property (nonatomic, weak) Friend* currentlySelectedFriend;
@property (nonatomic, strong) NSMutableString* currentSearchTerm;


@property (weak, nonatomic) IBOutlet UIImageView *searchFieldBackground;

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
    
    [self.friendsCollectionView registerNib: [UINib nibWithNibName: @"SYNSearchResultsUserCell" bundle: nil]
                 forCellWithReuseIdentifier: @"SYNSearchResultsUserCell"];
    
    self.preLoginLabel.font = [UIFont lightCustomFontOfSize:self.preLoginLabel.font.pointSize];
    
    [self.activityIndicator hidesWhenStopped];
    
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([[SYNFacebookManager sharedFBManager] hasActiveSession])
    {
        self.facebookLoginButton.hidden = YES;
        self.preLoginLabel.hidden = YES;
        self.friendsCollectionView.hidden = NO;
        self.activityIndicator.hidden = NO;
        
        
        [self fetchAndDisplayFriends];
        
        [tracker set: kGAIScreenName
               value: @"Friends All"];
    }
    else
    {
        
        self.facebookLoginButton.hidden = NO;
        self.preLoginLabel.hidden = NO;
        self.friendsCollectionView.hidden = YES;
        self.activityIndicator.hidden = YES;
        
        [tracker set: kGAIScreenName
               value: @"Friends Fb Connect"];
    }
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    
    self.searchFieldBackground.image = [[UIImage imageNamed: @"FieldSearch"]
                                        resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f,20.0f, 0.0f, 20.0f)];
    
    self.facebookLoginButton.layer.cornerRadius = 8.0f;
}



-(void)fetchAndDisplayFriends
{
    
    
    NSError *error;
    NSArray *existingFriendsArray;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"externalSystem == %@", kFacebook];
    
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
    
    [self.activityIndicator startAnimating];
    
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
                                                              
                                                              weakSelf.preLoginLabel.text = @"We could not Log you in becuase this FB account seems to be associated with a different User.";
                                                              
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
    
    SYNSearchResultsUserCell *userCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNSearchResultsUserCell"
                                                                                            forIndexPath: indexPath];
    
    userCell.channelOwner = (ChannelOwner*)(friend);
    userCell.delegate = self;
    
    // As the followButton needs to be a SYNSocialButton to tie in with the callbacks we just need to style it on the fly
    userCell.followButton.layer.borderWidth = 0.0f;
    userCell.followButton.backgroundColor = [UIColor clearColor];
    userCell.followButton.titleLabel.font = [UIFont lightCustomFontOfSize:20.0f];
    // ================= //
    
    
    return userCell;
}


-(void)profileButtonTapped
{
    
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    Friend* selectedFriend = self.friends[indexPath.item];
    
    
    [self viewProfileDetails:(ChannelOwner*)selectedFriend];
    
    
}




@end
