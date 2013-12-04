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
#import "SYNOnBoardingFooter.h"
#import "UIFont+SYNFont.h"
#import "Genre.h"
#import "AppConstants.h"
#import "SubGenre.h"
#import "UIColor+SYNColor.h"

static NSString* OnBoardingCellIndent = @"SYNOnBoardingCell";
static NSString* OnBoardingHeaderIndent = @"SYNOnBoardingHeader";
static NSString* OnBoardingFooterIndent = @"SYNOnBoardingFooter";

@interface SYNOnBoardingViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray* data;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;

// fake navigation bar stuff
@property (nonatomic, strong) IBOutlet UILabel* navigationTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* navigationRightLabel;


@property (nonatomic, strong) NSMutableDictionary* subgenresByIdString;

@property (nonatomic) NSInteger numberYetToFollow;

@property (nonatomic, weak) UIButton* skipButton;

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
    
    [self.collectionView registerNib: [UINib nibWithNibName: OnBoardingFooterIndent bundle: nil]
          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                 withReuseIdentifier: OnBoardingFooterIndent];
    
    self.navigationTitleLabel.font = [UIFont regularCustomFontOfSize:self.navigationTitleLabel.font.pointSize];
    self.navigationRightLabel.font = [UIFont regularCustomFontOfSize:self.navigationRightLabel.font.pointSize];
    
    
    
    // === Fetch Genres === //
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    categoriesFetchRequest.entity = [NSEntityDescription entityForName: kSubGenre
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    categoriesFetchRequest.includesSubentities = NO;
    
    NSError* error;
    
    NSArray* subGenresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                      error: &error];
    
    // we hold subgenres only in a dictionary
    self.subgenresByIdString = @{}.mutableCopy;
    
    for (SubGenre* s in subGenresFetchedArray)
    {
        if(!s.uniqueId)
            continue;
        
        self.subgenresByIdString[s.uniqueId] = s;
    }
    
    
    // =================== //
    
    
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
    
    self.numberYetToFollow = MIN(self.data.count, 3); // probably data.count will be much bigger than 3, so it will default to 3...
    
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
    
    SubGenre* subgenre = self.subgenresByIdString[recomendation.categoryId];
    
    
    cell.subGenreLabel.text = subgenre.name;
    cell.subGenreLabel.textColor = [UIColor colorWithHex:subgenre.genre.colorValue];
    
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
    else if (kind == UICollectionElementKindSectionFooter)
    {
        supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                               withReuseIdentifier: OnBoardingFooterIndent
                                                                      forIndexPath: indexPath];
        
        self.skipButton = ((SYNOnBoardingFooter*)supplementaryView).skipButton;
        
        [self.skipButton addTarget:self
                            action:@selector(skipButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return supplementaryView;
}

- (void) skipButtonPressed: (UIButton*) button
{
    button.enabled = NO;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.view.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    
}

#pragma mark - Social Delegate


- (void) followControlPressed: (SYNSocialButton *) socialControl
{
    // either a ChannelOwner of a Recomendation cell will link to a ChannelOwner (see SYNOnBoardingCell.m)
    
    socialControl.enabled = NO;
    
    ChannelOwner *channelOwner = (ChannelOwner*)socialControl.dataItemLinked;
    
    if(!channelOwner)
        return;
    
    if(socialControl.selected == NO)
    {
        [appDelegate.oAuthNetworkEngine subscribeAllForUserId: appDelegate.currentUser.uniqueId
                                                    subUserId: channelOwner.uniqueId
                                            completionHandler: ^(id responce) {
                                                
                                                socialControl.selected = YES;
                                                socialControl.enabled = YES;
                                                
                                                self.numberYetToFollow--;
                                                
                                            } errorHandler: ^(id error) {
                                                
                                                socialControl.enabled = YES;
                                                
                                            }];
    }
    else
    {
        [appDelegate.oAuthNetworkEngine unsubscribeAllForUserId:appDelegate.currentUser.uniqueId
                                                      subUserId:channelOwner.uniqueId
                                              completionHandler:^(id responce) {
                                                  
                                                  socialControl.selected = NO;
                                                  socialControl.enabled = YES;
                                                  
                                                  self.numberYetToFollow++;
                                                  
                                              } errorHandler:^(id error) {
                                                  
                                                  socialControl.enabled = YES;
                                                  
                                              }];
        
        
    }
    
}

-(void)setNumberYetToFollow:(NSInteger)numberYetToFollow
{
    _numberYetToFollow = numberYetToFollow;
    self.navigationRightLabel.text = [NSString stringWithFormat:@"%i more", numberYetToFollow];
    if(_numberYetToFollow == 0)
    {
        [UIView animateWithDuration:0.2f delay:0.3f options:UIViewAnimationCurveLinear animations:^{
            self.skipButton.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self skipButtonPressed:self.skipButton];
        }];
    }
    
}



@end
