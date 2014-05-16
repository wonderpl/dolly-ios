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
#import "Recommendation.h"
#import "SYNOnBoardingHeader.h"
#import "SYNOnBoardingFooter.h"
#import "UIFont+SYNFont.h"
#import "UIDevice+Helpers.h"
#import "Genre.h"
#import "AppConstants.h"
#import "SubGenre.h"
#import "UIColor+SYNColor.h"
#import "SYNDeviceManager.h"
#import "SYNOnBoardingSectionHeader.h"
#import "SYNGenreManager.h"
#import "SYNTrackingManager.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNNetworkMessageView.h"
#import "SYNActivityManager.h"
#import "UIViewController+PresentNotification.h"
#import "SYNDiscoverSectionHeaderView.h"
#import "SYNIPadOnBoardingLayout.h"

@interface SYNOnBoardingViewController () <UIBarPositioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SYNOnboardingFooterDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) SYNNetworkMessageView* networkMessageView;
@property (strong, nonatomic) IBOutlet SYNIPadOnBoardingLayout *collectionLayout;

@property (nonatomic, assign) NSInteger followedCount;

@property (nonatomic, copy) NSArray *groupedRecommendations;

@end

@implementation SYNOnBoardingViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[SYNOnBoardingCell nib]
          forCellWithReuseIdentifier:[SYNOnBoardingCell reuseIdentifier]];
    
    [self.collectionView registerNib:[SYNOnBoardingHeader nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:[SYNOnBoardingHeader reuseIdentifier]];
    
    [self.collectionView registerNib:[SYNDiscoverSectionHeaderView nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:[SYNDiscoverSectionHeaderView reuseIdentifier]];
    
    [self.collectionView registerNib:[SYNOnBoardingFooter nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:[SYNOnBoardingFooter reuseIdentifier]];
	
	[[SYNGenreManager sharedManager] fetchGenresWithCompletion:^(NSArray *results) {
		[self getRecommendationsFromRemoteWithGenres:results];
	}];
	
    if ([[UIDevice currentDevice] isPad]) {
        [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
    }
	
	if ([[UIDevice currentDevice] isPhone]) {
		self.collectionView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
	}
    
    
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackOnboardingScreenView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
	if ([[UIDevice currentDevice] isPad]) {
		[self updateLayoutForOrientation:toInterfaceOrientation];
	}
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
	return UIBarPositionTopAttached;
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
												  
													  self.groupedRecommendations = groupedRecommendations;
                                                  
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
	} else {
       cell.followButton.selected = [[SYNActivityManager sharedInstance] isSubscribedToUserId:recommendation.uniqueId];
    }
    
    if (indexPath.row == [self numberOfRecommendationsForSection:indexPath.section]-1) {
        cell.bottomBorderView.hidden = YES;
    }
	
    cell.delegate = self;
    
    return cell;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([[UIDevice currentDevice] isPad]) {
        if (section == 0) {
            return CGSizeMake(320, 76);
		} else {
            return CGSizeMake(self.view.frame.size.width, 60);
        }
    } else {
		if (section == 0) {
			return CGSizeMake(320, 51);
		} else {
			return CGSizeMake(320, 42);
		}
	}
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	if (section == [self.groupedRecommendations count]) {
        if (IS_IPHONE) {
            return CGSizeMake(320, 50);
        } else {
            return CGSizeMake(self.view.frame.size.width, 58);
        }
	}
    
	return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
		   viewForSupplementaryElementOfKind:(NSString *)kind
								 atIndexPath:(NSIndexPath *)indexPath {
	
	if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 0) {
			return [collectionView dequeueReusableSupplementaryViewOfKind:kind
													  withReuseIdentifier:[SYNOnBoardingHeader reuseIdentifier]
															 forIndexPath:indexPath];
            
        } else {
            SYNDiscoverSectionHeaderView *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                                 withReuseIdentifier: [SYNDiscoverSectionHeaderView reuseIdentifier]
                                                                                                        forIndexPath: indexPath];
			
			[sectionHeader setTitleText: [self titleForIndexPath:indexPath]];
            
			return sectionHeader;
        }
    } else if (kind == UICollectionElementKindSectionFooter) {
		SYNOnBoardingFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
																		 withReuseIdentifier:[SYNOnBoardingFooter reuseIdentifier]
																				forIndexPath:indexPath];
		footer.delegate = self;
		
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
	
//	[self followControlPressed:socialButton completion:nil];
}

- (void)continueButtonPressed:(UIButton *)button {
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

- (void)updateLayoutForOrientation:(UIDeviceOrientation)orientation {
    
    
    
    if (UIDeviceOrientationIsPortrait(orientation)) {
        self.collectionLayout.minimumInteritemSpacing = 22;
    } else {
        self.collectionLayout.minimumInteritemSpacing = 34;
    }

	[self.collectionView.collectionViewLayout invalidateLayout];
}


- (void)followControlPressed:(UIButton *)button withChannelOwner:(ChannelOwner *)channelOwner completion :(void (^)(void))callbackBlock {

    [super followControlPressed:button withChannelOwner:channelOwner completion:^{
            if ([[SYNActivityManager sharedInstance] isSubscribedToUserId:channelOwner.uniqueId]) {
                
                NSString *text = IS_IPAD ? [NSString stringWithFormat:@"You have successfully followed %@", channelOwner.displayName] : [NSString stringWithFormat:@"Following %@", channelOwner.displayName];
                
                [self presentNotificationWithMessage: text andType:NotificationMessageTypeSuccess];
            } else {
                
                NSString *text = IS_IPAD ? [NSString stringWithFormat:@"You have successfully unfollowed %@", channelOwner.displayName] : [NSString stringWithFormat:@"Unfollowed %@", channelOwner.displayName];

                [self presentNotificationWithMessage: text andType:NotificationMessageTypeSuccess];
            }
        
        if (button.selected) {
            self.followedCount++;
        } else {
            self.followedCount--;
        }

        
    }];
    
}



@end
