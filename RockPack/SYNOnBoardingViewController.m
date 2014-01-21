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
#import "SYNDeviceManager.h"
#import "SYNActivityManager.h"
#import "SYNOnBoardingSectionHeader.h"
#import "SYNGenreColorManager.h"

static NSString* OnBoardingCellIndent = @"SYNOnBoardingCell";
static NSString* OnBoardingHeaderIndent = @"SYNOnBoardingHeader";
static NSString* OnBoardingFooterIndent = @"SYNOnBoardingFooter";
static NSString* OnBoardingSectionHeader = @"SYNOnBoardingSectionHeader";

@interface SYNOnBoardingViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray* data;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;

// fake navigation bar stuff
@property (nonatomic, strong) IBOutlet UILabel* navigationTitleLabel;
@property (nonatomic, strong) IBOutlet UIButton* navigationRightLabel;


@property (nonatomic, strong) NSMutableDictionary* subgenresByIdString;

@property (nonatomic) NSInteger numberYetToFollow;

@property (nonatomic, weak) UIButton* skipButton;

@property (nonatomic, strong) NSMutableArray *usersByCategory;
@property (nonatomic, strong) NSMutableArray *categories;


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
    
    
    
    [self.collectionView registerNib: [UINib nibWithNibName: OnBoardingSectionHeader bundle: nil]
          forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                 withReuseIdentifier: OnBoardingSectionHeader];

    [self.collectionView registerNib: [UINib nibWithNibName: OnBoardingFooterIndent bundle: nil]
          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                 withReuseIdentifier: OnBoardingFooterIndent];
    
    self.navigationTitleLabel.font = [UIFont regularCustomFontOfSize:self.navigationTitleLabel.font.pointSize];
    self.navigationRightLabel.titleLabel.font = [UIFont regularCustomFontOfSize:self.navigationRightLabel.titleLabel.font.pointSize];
    
    self.usersByCategory = [[NSMutableArray alloc]init];
    self.categories = [[NSMutableArray alloc]init];
    
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
                                                  andEntityName: kChannelOwner
                                                         params: nil
                                              completionHandler:^(id responce) {
                                                  
                                                  if(![responce isKindOfClass:[NSDictionary class]])
                                                      return;
                                                  
                                                  NSLog(@"Onboarding response :%@", responce);
                                                  
                                                  self.spinner.hidden = YES;
                                                  
                                                  if(![appDelegate.searchRegistry registerRecommendationsFromDictionary:responce])
                                                      return;
                                                  
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
    
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    //Change to subgenre when the proper recomendations are up
    //will greatly improve this
    categoriesFetchRequest.entity = [NSEntityDescription entityForName: kGenre
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext];

    [categoriesFetchRequest setResultType:NSDictionaryResultType];
    
    [categoriesFetchRequest setReturnsDistinctResults:YES];
    [categoriesFetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"uniqueId", @"priority", @"name", nil]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];

    NSArray* genresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                      error: &error];
    // == Gets the data from core data in order of priority and then adds its to the displayed data by that order aswell as groups users with common genres.
    
    
        NSArray *genres = [NSArray arrayWithArray:genresFetchedArray];
    NSMutableArray *tmpData = [NSMutableArray arrayWithArray:self.data];
    
    NSMutableArray *tmpArr = [[NSMutableArray alloc]init];
    NSString *tmpString = [[NSString alloc]init];
    for (NSDictionary *tmpGenre in genres) {
        tmpString = [[NSString alloc]init];
        tmpArr = [[NSMutableArray alloc]init];

        for (int i = 0; i<tmpData.count; i++) {
            Recomendation *tmpRecomendation = [tmpData objectAtIndex:i];
            
            if ([tmpRecomendation.categoryId isEqualToString:tmpGenre[@"uniqueId"]]) {
                [tmpArr addObject:tmpRecomendation];
                [tmpData removeObject:tmpRecomendation];
                i--;
                
                tmpString = tmpGenre[@"name"];
            }
            
        }
        
        if (tmpArr.count>0) {
            [self.usersByCategory addObject:tmpArr];
            [self.categories addObject:tmpString];
        }
    }
    
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return self.usersByCategory.count+1;
}


- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    if (section == 0) {
        return 0;
    }
    
    return ((NSArray*)[self.usersByCategory objectAtIndex:section-1]).count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNOnBoardingCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: OnBoardingCellIndent
                                                                        forIndexPath: indexPath];
    
    Recomendation* recomendation = (Recomendation*)self.usersByCategory[indexPath.section-1][indexPath.row];
    
    cell.recomendation = recomendation;
    
    SubGenre* subgenre = self.subgenresByIdString[recomendation.categoryId];
    
    
    cell.subGenreLabel.text = subgenre.name;
    cell.subGenreLabel.textColor = [UIColor colorWithHex:subgenre.genre.colorValue];
    
    cell.delegate = self;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return CGSizeMake(320, 90);

    }
    else
    {
        return CGSizeMake(320, 30);
    }
    
    return CGSizeZero;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if(section!=self.usersByCategory.count)
    {
        return CGSizeZero;
    }
    
    return CGSizeMake(320, 76);
}

- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView = nil;
	if (kind == UICollectionElementKindSectionHeader)
    {
        
        if (indexPath.section == 0) {
            supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                   withReuseIdentifier: OnBoardingHeaderIndent
                                                                          forIndexPath: indexPath];
            
        } else {
            supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                   withReuseIdentifier: OnBoardingSectionHeader
                                                                          forIndexPath: indexPath];
            
            [((SYNOnBoardingSectionHeader*)supplementaryView).sectionTitle setBackgroundColor:[[SYNGenreColorManager sharedInstance] colorFromID:((Recomendation*)[((NSArray*)[self.usersByCategory objectAtIndex:indexPath.section-1]) objectAtIndex:indexPath.row]).categoryId]];
            
            [((SYNOnBoardingSectionHeader*)supplementaryView).sectionTitle setText:[self.categories objectAtIndex:indexPath.section-1]];
        }

        

        
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
//        [appDelegate.oAuthNetworkEngine subscribeAllForUserId: appDelegate.currentUser.uniqueId
//                                                    subUserId: channelOwner.uniqueId

        [[SYNActivityManager sharedInstance] subscribeToUser:channelOwner
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
        [[SYNActivityManager sharedInstance] unsubscribeToUser:channelOwner
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
    [self.navigationRightLabel setTitle:[NSString stringWithFormat:@"%i more", numberYetToFollow]
                               forState:UIControlStateNormal];
    
    if(_numberYetToFollow <= 0)
    {
        [self.navigationRightLabel setTitle:@"GO"
                                   forState:UIControlStateNormal];
        
        [self.navigationRightLabel addTarget:self
                                      action:@selector(toRightPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}
-(void)toRightPressed:(UIButton*)button
{
    [self skipButtonPressed:self.skipButton];
}
#pragma mark - AutoRotation

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.view.frame = [[SYNDeviceManager sharedInstance] currentScreenRect];
}



@end
