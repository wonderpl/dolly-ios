//
//  SYNOnBoardingViewController.m
//  dolly
//
//  Created by Michael Michailidis on 25/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingViewController.h"
#import "SYNOnBoardingCell.h"
#import "SYNOnBoardingHeader.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "ChannelOwner.h"

static NSString* OnBoardingCellIndent = @"SYNOnBoardingCell";

@interface SYNOnBoardingViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray* data;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

@end

@implementation SYNOnBoardingViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Welcome";
    
    [self.collectionView registerNib:[UINib nibWithNibName:OnBoardingCellIndent bundle:nil]
          forCellWithReuseIdentifier:OnBoardingCellIndent];
    
    self.data = @[]; // so as not to throw error when accessed
    
    [self getRecommendationsFromRemote];
    
}

- (void) getRecommendationsFromRemote
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.oAuthNetworkEngine getRecommendationsForUserId:appDelegate.currentUser.uniqueId
                                              completionHandler:^(id responce) {
                                                  
                                                  if(![responce isKindOfClass:[NSDictionary class]])
                                                      return;
                                                  
                                                  if(![appDelegate.searchRegistry registerRecommendationsFromDictionary:responce])
                                                  {
                                                      return;
                                                  }
                                                  
                                                  [self fetchRecommendationsFromLocal];
                                                  
        
                                              } errorHandler:^(id error) {
        
                                              }];
}

- (void) fetchRecommendationsFromLocal
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: kRecommendation
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    
    NSError* error;
    self.data = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                      error: &error];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.data.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNOnBoardingCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: OnBoardingCellIndent
                                                                        forIndexPath: indexPath];
    
    ChannelOwner* co = (ChannelOwner*)self.data[indexPath.row];
    
    cell.titleLabel.text = co.displayName;
    
    
    cell.delegate = self;
    
    return cell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    
}

#pragma mark - Social Delegate

- (void) followControlPressed: (SYNSocialButton *) socialButton
{
    
    
    
}


- (void) shareControlPressed: (SYNSocialButton *) socialButton
{;}
- (void) likeControlPressed: (SYNSocialButton *) socialButton
{;}
- (void) addControlPressed: (SYNSocialButton *) socialButton
{;}



@end
