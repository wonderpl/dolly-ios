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
#import "Recomendation.h"
#import "SYNMasterViewController.h"
#import "SYNOnBoardingHeader.h"

static NSString* OnBoardingCellIndent = @"SYNOnBoardingCell";
static NSString* OnBoardingHeaderIndent = @"SYNOnBoardingHeader";

@interface SYNOnBoardingViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray* data;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;

@end

@implementation SYNOnBoardingViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Welcome";
    
    [self.collectionView registerNib:[UINib nibWithNibName:OnBoardingCellIndent bundle:nil]
          forCellWithReuseIdentifier:OnBoardingCellIndent];
    
    [self.collectionView registerNib: [UINib nibWithNibName: OnBoardingHeaderIndent bundle: nil]
          forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                 withReuseIdentifier: OnBoardingHeaderIndent];
    
    
    
    self.data = @[]; // so as not to throw error when accessed
    
    [self getRecommendationsFromRemote];
    
}

- (void) getRecommendationsFromRemote
{
    
    self.spinner.hidden = NO;
    
    [appDelegate.oAuthNetworkEngine getRecommendationsForUserId:appDelegate.currentUser.uniqueId
                                              completionHandler:^(id responce) {
                                                  
                                                  if(![responce isKindOfClass:[NSDictionary class]])
                                                      return;
                                                  
                                                  self.spinner.hidden = YES;
                                                  
                                                  if(![appDelegate.searchRegistry registerRecommendationsFromDictionary:responce])
                                                  {
                                                      return;
                                                  }
                                                  
                                                  
                                                  [self fetchRecommendationsFromLocal];
                                                  
        
                                              } errorHandler:^(id error) {
                                                  
                                                  self.spinner.hidden = YES;
        
                                              }];
}

- (void) fetchRecommendationsFromLocal
{
    
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
    
    Recomendation* recomendation = (Recomendation*)self.data[indexPath.row];
    
    cell.recomendation = recomendation;
    
    
    cell.delegate = self;
    
    return cell;
}

- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView = nil;
	if (kind == UICollectionElementKindSectionHeader)
    {
        supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                             withReuseIdentifier: OnBoardingHeaderIndent
                                                                    forIndexPath: indexPath];
        
        
         
    }
    
    return supplementaryView;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    
}

#pragma mark - Social Delegate






@end
