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
#import "Recommendation.h"
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
#import "UICollectionReusableView+Helpers.h"
#import "SYNGenreManager.h"

@interface SYNOnBoardingViewController () <UIBarPositioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, weak) UIButton *skipButton;

@property (nonatomic, assign) NSInteger followedCount;

@property (nonatomic, copy) NSArray *groupedRecommendations;

@end

@implementation SYNOnBoardingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[SYNOnBoardingCell nib]
          forCellWithReuseIdentifier:[SYNOnBoardingCell reuseIdentifier]];
    
    [self.collectionView registerNib:[SYNOnBoardingHeader nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:[SYNOnBoardingHeader reuseIdentifier]];
    
    [self.collectionView registerNib:[SYNOnBoardingSectionHeader nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:[SYNOnBoardingSectionHeader reuseIdentifier]];
    
    [self.collectionView registerNib:[SYNOnBoardingFooter nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:[SYNOnBoardingFooter reuseIdentifier]];
	
	[[SYNGenreManager sharedManager] fetchGenresWithCompletion:^(NSArray *results) {
		[self getRecommendationsFromRemoteWithGenres:results];
	}];
	
    if (IS_IPAD) {
        [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
    }
	
	if (IS_IPHONE) {
		self.collectionView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackOnboardingScreenView];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
	return UIBarPositionTopAttached;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (void)getRecommendationsFromRemoteWithGenres:(NSArray *)genres {
	
    [self.spinner startAnimating];
    
    [appDelegate.oAuthNetworkEngine getRecommendationsForUserId:appDelegate.currentUser.uniqueId
                                                  andEntityName:[ChannelOwner entityName]
                                                         params:nil
                                              completionHandler:^(id response) {
                                                  [self.spinner stopAnimating];
                                                  
                                                  if (![appDelegate.searchRegistry registerRecommendationsFromDictionary:response])
                                                      return;
												  
												  NSArray *recommendations = [self fetchRecommendations];
												  NSArray *groupedRecommendations = [self groupRecommendations:recommendations byGenres:genres];
												  
												  if (IS_IPHONE) {
													  self.groupedRecommendations = groupedRecommendations;
												  } else {
													  // For the iPad we only have one section so we're going to flatten the array
													  NSMutableArray *array = [NSMutableArray array];
													  for (NSArray *groupedRecommendation in groupedRecommendations) {
														  [array addObjectsFromArray:groupedRecommendation];
													  }
													  self.groupedRecommendations = @[ array ];
												  }
                                                  
												  [self.collectionView reloadData];
                                                  
                                              } errorHandler:^(id error) {
                                                  
                                                  [self.spinner stopAnimating];
                                                  
                                              }];
}

- (NSArray *)fetchRecommendations {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Recommendation entityName]];
	NSArray *sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES] ];
	fetchRequest.sortDescriptors = sortDescriptors;
	
	return [appDelegate.searchManagedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (NSArray *)groupRecommendations:(NSArray *)recommendations byGenres:(NSArray *)genres {
	NSDictionary *recommendationsByGenre = [self groupRecommendationsByGenre:recommendations];
	
	NSMutableArray *genreRecommendations = [NSMutableArray array];
	for (Genre *genre in genres) {
		NSMutableArray *array = [NSMutableArray array];
		
		[array addObjectsFromArray:recommendationsByGenre[genre.uniqueId]];
		
		for (SubGenre *subgenre in genre.subgenres) {
			[array addObjectsFromArray:recommendationsByGenre[subgenre.uniqueId]];
		}
		
		if ([array count]) {
			[genreRecommendations addObject:array];
		}
	}
	
	return genreRecommendations;
}

- (NSDictionary *)groupRecommendationsByGenre:(NSArray *)recommendations {
	NSMutableDictionary *recommendationsByGenre = [NSMutableDictionary dictionary];
	
	for (Recommendation *recommendation in recommendations) {
		NSString *categoryId = recommendation.categoryId;
		
		NSMutableArray *genreRecommendations = (recommendationsByGenre[categoryId] ?: [NSMutableArray array]);
		[genreRecommendations addObject:recommendation];
		
		recommendationsByGenre[recommendation.categoryId] = genreRecommendations;
	}
	
	return recommendationsByGenre;
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return [self.groupedRecommendations count] + 1;
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
	return [self numberOfRecommendationsForSection:section];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    SYNOnBoardingCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNOnBoardingCell reuseIdentifier]
                                                                        forIndexPath:indexPath];
    
	Recommendation *recommendation = [self recommendationForIndexPath:indexPath];
    
    cell.recommendation = recommendation;
	
	BOOL isEditorsPicks = (indexPath.section == 1 && indexPath.row == 0);
	if (isEditorsPicks) {
		cell.followButton.selected = YES;
		cell.followButton.userInteractionEnabled = NO;
	}
	
	if (IS_IPAD) {
		cell.subGenreLabel.text = [self titleForIndexPath:indexPath];
		cell.subGenreLabel.backgroundColor = [self colorForIndexPath:indexPath];
	}

    cell.delegate = self;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (IS_IPAD && section != 0) {
        return CGSizeMake(320, 76);
    }
	
	if (section == [self.groupedRecommendations count]) {
		return CGSizeMake(320, 76);
	}
    
	return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *) collectionView
		   viewForSupplementaryElementOfKind:(NSString *) kind
								 atIndexPath:(NSIndexPath *) indexPath {
	
	if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 0) {
			return [collectionView dequeueReusableSupplementaryViewOfKind:kind
													  withReuseIdentifier:[SYNOnBoardingHeader reuseIdentifier]
															 forIndexPath:indexPath];
            
        } else {
			
			SYNOnBoardingSectionHeader *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind
																						   withReuseIdentifier:[SYNOnBoardingSectionHeader reuseIdentifier]
																								  forIndexPath:indexPath];
			
			sectionHeader.sectionTitle.backgroundColor = [self colorForIndexPath:indexPath];
			sectionHeader.sectionTitle.text = [self titleForIndexPath:indexPath];
            
			return sectionHeader;
        }
    } else if (kind == UICollectionElementKindSectionFooter) {
		SYNOnBoardingFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
																		 withReuseIdentifier:[SYNOnBoardingFooter reuseIdentifier]
																				forIndexPath:indexPath];
		
		self.skipButton = footer.skipButton;
		
		[self.skipButton addTarget:self
							action:@selector(skipButtonPressed:)
				  forControlEvents:UIControlEventTouchUpInside];
		
		return footer;
	}
	
	return nil;
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

- (void)skipButtonPressed:(UIButton*) button {
    button.enabled = NO;
    
	[[SYNTrackingManager sharedManager] trackOnboardingCompletedWithFollowedCount:self.followedCount];
    
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];

        

        [[NSNotificationCenter defaultCenter] postNotificationName:kOnboardingCompleted
															object:self];
}

- (NSString *)trackingScreenName {
	return @"Onboarding";
}

- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath {
	Recommendation *recommendation = [self recommendationForIndexPath:indexPath];
	Genre *genre = [[SYNGenreManager sharedManager] genreWithId:recommendation.categoryId];
	return genre.genreName;
}

- (UIColor *)colorForIndexPath:(NSIndexPath *)indexPath {
	Recommendation *recommendation = [self recommendationForIndexPath:indexPath];
	return [[SYNGenreManager sharedManager] colorForGenreWithId:recommendation.categoryId];
}

- (NSInteger)numberOfRecommendationsForSection:(NSInteger)section {
	NSArray *recommendations = self.groupedRecommendations[section - 1];
	return [recommendations count];
}

- (Recommendation *)recommendationForIndexPath:(NSIndexPath *)indexPath {
	return self.groupedRecommendations[indexPath.section - 1][indexPath.row];
}

#pragma mark - AutoRotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
}

- (void)updateLayoutForOrientation:(UIDeviceOrientation)orientation {
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
