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
#import "SYNGenreManager.h"
#import "SYNTrackingManager.h"

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


@property (nonatomic, strong) NSMutableDictionary* subgenresByIdString;
@property (nonatomic, strong) NSMutableDictionary* genresByIdString;

@property (nonatomic, weak) UIButton* skipButton;

@property (nonatomic, strong) NSMutableArray *usersByCategory;
@property (nonatomic, strong) NSMutableArray *categories;

@property (nonatomic, assign) NSInteger followedCount;

@end

@implementation SYNOnBoardingViewController



- (void)viewDidLoad {
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
    
    self.usersByCategory = [[NSMutableArray alloc]init];
    self.categories = [[NSMutableArray alloc]init];
    
    // === Fetch Genres === //
    
    
    [self loadBasicDataWithComplete:^(BOOL success) {
    
        NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
        
        categoriesFetchRequest.entity = [NSEntityDescription entityForName: kGenre
                                                    inManagedObjectContext: appDelegate.mainManagedObjectContext];
        
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
        
        [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
        
        
        categoriesFetchRequest.includesSubentities = NO;
        
        NSError* error;
        
        NSArray* genresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                          error: &error];
        
        
        // we hold subgenres only in a dictionary
        self.subgenresByIdString = @{}.mutableCopy;
        self.genresByIdString = @{}.mutableCopy;
        
        for (Genre* g in genresFetchedArray) {
            
            if(!g.uniqueId)
                continue;
            
            self.genresByIdString[g.uniqueId] = g;
            
            for (SubGenre* s in g.subgenres)
            {
                if(!s.uniqueId)
                    continue;
                
                self.subgenresByIdString[s.uniqueId] = s;
            }
            
        }

    }];

    
    
    // =================== //
    
    
    self.data = @[]; // so as not to throw error when accessed
    
    [self getRecommendationsFromRemote];
    if (IS_IPAD) {
        [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
    }

    
    if (!IS_IPHONE_5) {
        UIEdgeInsets tmpInsets = self.collectionView.contentInset;
        tmpInsets.bottom += 88;
        [self.collectionView setContentInset: tmpInsets];
    }

    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (void)loadBasicDataWithComplete:(void(^)(BOOL))CompleteBlock
{
    
    [appDelegate.networkEngine updateCategoriesOnCompletion: ^(NSDictionary* dictionary){
        
        [appDelegate.mainRegistry performInBackground:^BOOL(NSManagedObjectContext *backgroundContext) {
            
            return [appDelegate.mainRegistry registerCategoriesFromDictionary: dictionary];
            
        } completionBlock:^(BOOL success) {
            
            CompleteBlock(success);
            
            [[SYNGenreManager sharedInstance] registerGenreColorsFromCoreData];
            
            [appDelegate.mainManagedObjectContext save:nil];
            
        }];
    } onError:^(NSError* error) {
        
    } forceReload:NO];
}

- (void) getRecommendationsFromRemote {
    
    self.spinner.hidden = NO;
    
    [appDelegate.oAuthNetworkEngine getRecommendationsForUserId:appDelegate.currentUser.uniqueId
                                                  andEntityName: kChannelOwner
                                                         params: nil
                                              completionHandler:^(id responce) {
                                                  
                                                  if(![responce isKindOfClass:[NSDictionary class]])
                                                      return;

                                                  self.spinner.hidden = YES;
                                                  
                                                  if(![appDelegate.searchRegistry registerRecommendationsFromDictionary:responce])
                                                      return;
                                                  
                                                  [self fetchRecommendationsFromLocal];
                                                  
                                                  
                                              } errorHandler:^(id error) {
                                                  
                                                  self.spinner.hidden = YES;
                                                  
                                              }];
}



- (void) fetchRecommendationsFromLocal {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: kRecommendation
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    NSError* error;
    self.data = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                      error: &error];
    
    
    NSFetchRequest *categoriesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Genre entityName]];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSArray* genresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                      error: &error];
    // == Gets the data from core data in order of priority and then adds its to the displayed data by that order aswell as groups users with common genres.
    
    NSArray *genres = [NSArray arrayWithArray:genresFetchedArray];
    NSMutableArray *tmpData = [NSMutableArray arrayWithArray:self.data];
    
    NSMutableArray *tmpArr = [[NSMutableArray alloc]init];
    NSString *tmpString = [[NSString alloc]init];
    
    
    
    for (Genre *tmpGenre in genres) {
        tmpString = [[NSString alloc]init];
        if (IS_IPHONE) {
            tmpArr = [[NSMutableArray alloc]init];
        }
        
        for (int i = tmpData.count; i>0; i--) {
            Recomendation *tmpRecomendation = [tmpData objectAtIndex:i-1];
            
            SubGenre* subgenre = self.subgenresByIdString[tmpRecomendation.categoryId];
            
            if ([subgenre.genre.name isEqualToString:tmpGenre.name]) {
                
                [tmpArr addObject:tmpRecomendation];
                [tmpData removeObject:tmpRecomendation];
                tmpString = tmpGenre.name;
            }
        }
        
        if (tmpArr.count>0 && IS_IPHONE) {
            
            [self.usersByCategory addObject:tmpArr];
            [self.categories addObject:tmpString];
        }
    }
    

    if (IS_IPHONE && tmpData.count >0) {
        [self.usersByCategory insertObject: tmpData atIndex:0];
    }
    
    if (IS_IPAD) {
        // assuming the list is ordered in the backend
        for (int i = tmpData.count; i>0; i--) {
            Recomendation *tmpRecomendation = [tmpData objectAtIndex:i-1];
            [tmpArr insertObject:tmpRecomendation atIndex:0];
        }
        
        [self.usersByCategory addObject:tmpArr];
    }
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
    
    if (IS_IPAD) {
        return 2;
    }
    return self.usersByCategory.count+1;
}


- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section {
    
    if (section == 0) {
        return 0;
    }
    
    //Ipad has no section headers, all data is in the first object
    if (IS_IPAD) {
        return ((NSArray*)[self.usersByCategory firstObject]).count;
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
    
    if (self.genresByIdString[recomendation.categoryId]) {
        Genre* genre = self.genresByIdString[recomendation.categoryId];
        cell.subGenreLabel.text = genre.name;
        
        cell.followButton.selected = YES;
        cell.followButton.userInteractionEnabled = NO;
    }
    
    if(self.subgenresByIdString[recomendation.categoryId]){
        SubGenre* subgenre = self.subgenresByIdString[recomendation.categoryId];
        cell.subGenreLabel.text = subgenre.genre.name;
    }

    cell.delegate = self;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    // IPAD has a section for the empty header and
    if (IS_IPAD) {
        if (section != 0) {
            return CGSizeZero;
        } else {
            return CGSizeMake(320, 108);
        }
    }
    
    if (section==0) {
        return CGSizeMake(320, 90);
    } else {
        return CGSizeMake(320, 30);
    }
    
    return CGSizeZero;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (IS_IPAD && section != 0) {
        return CGSizeMake(320, 76);
    }
    
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
            
            Recomendation* recomendation = (Recomendation*)self.usersByCategory[indexPath.section-1][indexPath.row];

            [((SYNOnBoardingSectionHeader*)supplementaryView).sectionTitle setBackgroundColor:[[SYNGenreManager sharedInstance] colorFromID:recomendation.categoryId]];
            
            // special case for editors picks as its a genre not a subgenre
            if (self.genresByIdString[recomendation.categoryId]) {
                Genre* genre = self.genresByIdString[recomendation.categoryId];
                
                [((SYNOnBoardingSectionHeader*)supplementaryView).sectionTitle setText:genre.name];
                
            } else if(self.subgenresByIdString[recomendation.categoryId]) {
                SubGenre* subgenre = self.subgenresByIdString[recomendation.categoryId];
                
                [((SYNOnBoardingSectionHeader*)supplementaryView).sectionTitle setText:subgenre.genre.name];
            }
            
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

- (void)followControlPressed:(SYNSocialButton *)socialButton {
	// Track the number of people followed
	if (socialButton.selected) {
		self.followedCount--;
	} else {
		self.followedCount++;
	}
	
	[super followControlPressed:socialButton];
}

- (void) skipButtonPressed: (UIButton*) button
{
    button.enabled = NO;
    
	[[SYNTrackingManager sharedManager] trackOnboardingCompletedWithFollowedCount:self.followedCount];
    
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];

        

        [[NSNotificationCenter defaultCenter] postNotificationName:kOnboardingCompleted
															object:self];

}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath {
    
    
    
}

- (NSString *)trackingScreenName {
	return @"Onboarding";
}

#pragma mark - AutoRotation

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];

}

- (void) updateLayoutForOrientation: (UIDeviceOrientation) orientation {
    
    if (IS_IPAD) {
        if ([[SYNDeviceManager sharedInstance] isPortrait]) {
            UICollectionViewFlowLayout *tmpLayout = ((UICollectionViewFlowLayout*)[self.collectionView collectionViewLayout]);
            
            tmpLayout.sectionInset = UIEdgeInsetsMake(0, 120, 0, 120);
            [self.collectionView setCollectionViewLayout:tmpLayout];
            [self.collectionView.collectionViewLayout invalidateLayout];
            
        } else {
            UICollectionViewFlowLayout *tmpLayout = ((UICollectionViewFlowLayout*)[self.collectionView collectionViewLayout]);
            
            tmpLayout.sectionInset = UIEdgeInsetsMake(0, 100, 0, 100);
            [self.collectionView setCollectionViewLayout:tmpLayout];
            [self.collectionView.collectionViewLayout invalidateLayout];
        }
        
    }

}



@end
