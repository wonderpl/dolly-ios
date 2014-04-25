//
//  SYNMoodViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 16/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNMoodRootViewController.h"
#import "SYNMoodCell.h"
#import "UIFont+SYNFont.h"
#import "SYNFadingFlowLayout.h"
#import "SYNDeviceManager.h"
#import "Mood.h"
#import "VideoInstance.h"
#import "UINavigationBar+Appearance.h"
#import "UIColor+SYNColor.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNVideoPlayerAnimator.h"
#import "SYNSearchResultsVideoCell.h"
#import "SYNMoodOverlayViewController.h"
#import "SYNTrackingManager.h"
#import "SYNMasterViewController.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNStaticModel.h"

static const float largeAmountOfRows = 10000;
static const float watchButtonAnimationTime = 0.4;
static const float xAxis = 77;

@interface SYNMoodRootViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topWatchConstraint;
@property (nonatomic, weak) IBOutlet UICollectionView *moodCollectionView;
@property (nonatomic, weak) IBOutlet UILabel *iWantToLabel;
@property (strong, nonatomic) IBOutlet UIButton *watchButton;
@property (nonatomic, strong) NSArray *moods;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topTitleConstraint;
@property (nonatomic, readonly) Mood* currentMood;
@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;
@property (nonatomic, strong) NSArray* randomVideoArray;
@property (nonatomic, strong) __block NSNumber* randomVideoIndex;
@property (nonatomic, strong) NSArray* videosArray;

@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;
@property (strong, nonatomic) IBOutlet UIImageView *moodBackground;
@property (nonatomic, assign) CGPoint scrollingPoint, endPoint;
@property (nonatomic, strong) NSTimer *scrollingTimer;
@property (strong, nonatomic) IBOutlet UIView *divider;
@property (strong, nonatomic) IBOutlet UIButton *chooseAnotherButton;

@property (nonatomic, assign) BOOL userScrolling;

@end


@implementation SYNMoodRootViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.moods = @[];
    
    // Setup mood collection view
    [self.moodCollectionView registerClass:[SYNMoodCell class]
                forCellWithReuseIdentifier:NSStringFromClass([SYNMoodCell class])];
    [self.videoCollectionView registerNib:[SYNSearchResultsVideoCell nib]
               forCellWithReuseIdentifier:[SYNSearchResultsVideoCell reuseIdentifier]];
    
    
    self.iWantToLabel.font = [UIFont regularCustomFontOfSize: self.iWantToLabel.font.pointSize];
    self.iWantToLabel.textColor = [UIColor dollyMoodColor];
    
    self.moodCollectionView.scrollsToTop = NO;
    
    [self loadMoods];
    
    [self getUpdatedMoods];
    
    self.watchButton.layer.cornerRadius = 15.5f;
    self.watchButton.layer.masksToBounds = YES;
    
    [self.watchButton.titleLabel setFont:[UIFont regularCustomFontOfSize:15]];
    
    self.watchButton.layer.borderWidth = 1.5f;
    self.watchButton.layer.borderColor = [[UIColor dollyMoodColor] CGColor];
    
    self.chooseAnotherButton.layer.cornerRadius = 17.0f;
    self.chooseAnotherButton.layer.masksToBounds = YES;
    
    [self.chooseAnotherButton.titleLabel setFont:[UIFont regularCustomFontOfSize:15]];
    self.chooseAnotherButton.layer.borderWidth = 1.5f;
    self.chooseAnotherButton.layer.borderColor = [[UIColor dollyMoodColor] CGColor];
    
    
    if (!IS_IPHONE_5) {
        self.topTitleConstraint.constant -= 24.0f;
        self.topWatchConstraint.constant += 34.0f;
    }
    
    NSIndexPath *centerIndexPath = [NSIndexPath indexPathForItem:10 inSection:0];
    
    if (self.moods.count>0) {
        [self.moodCollectionView scrollToItemAtIndexPath:centerIndexPath
                                        atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                animated:YES];
    }
    
    self.randomVideoArray = @[];
    self.videosArray = @[];
    self.randomVideoIndex = 0;
	
}

- (void)viewWillAppear:(BOOL)animated {
	appDelegate.masterViewController.tabsView.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
	appDelegate.masterViewController.tabsView.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	

	[[SYNTrackingManager sharedManager] trackMoodMinderScreenView];
}

#pragma mark - Getting Mood Objects

- (void)loadMoods {
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Mood"];
    
    NSError* error;
    self.moods = [appDelegate.mainManagedObjectContext executeFetchRequest:fetchRequest
                                                                     error:&error];
    if(self.moods == 0) {
        //TODO: No moods what do??
    }
    
    [self.moodCollectionView reloadData];
    
}

-(void) getUpdatedMoods {
    [appDelegate.networkEngine getMoodsWithCompletionHandler:^(id responce) {
        
        if(![responce isKindOfClass:[NSDictionary class]])
            return;
        
        if([appDelegate.mainRegistry registerMoodsFromDictionary:responce
                                               withExistingMoods:self.moods]) {
            [self loadMoods];
            [self scrollSlowly];
            
        }
    } errorHandler:^(id error) {
    }];
}

#pragma mark - Control Callbacks
- (IBAction)watchButtonTapped:(id)sender {
	[[SYNTrackingManager sharedManager] trackIPhoneMoodWatchSelected:self.currentMood.name];
	
	[self watchVideo];
}


- (void)watchVideo {
    self.watchButton.userInteractionEnabled = NO;
    
	__weak typeof(self) weakSelf = self;
    
    __block int rand = 0;
	
    [appDelegate.oAuthNetworkEngine getRecommendationsForUserId: appDelegate.currentUser.uniqueId
                                                  andEntityName: kVideoInstance
                                                         params: @{@"mood":self.currentMood.uniqueId}
                                              completionHandler: ^(id response) {
												  
												  __strong typeof(self) strongSelf = weakSelf;
                                                  
                                                  if(![response isKindOfClass:[NSDictionary class]])
                                                      return;
                                                  
                                                  if(![appDelegate.searchRegistry registerVideoInstancesFromDictionary:response
                                                                                                            withViewId:self.viewId])
                                                      return;
												  
												  NSArray *videoInstances = response[@"videos"][@"items"];
												  NSArray *videoInstanceIds = [videoInstances valueForKey:@"id"];
												  
                                                  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VideoInstance entityName]];
												  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId IN %@", videoInstanceIds];
												  [fetchRequest setPredicate:predicate];
                                                  
                                                  NSArray* videosArray = [appDelegate.searchManagedObjectContext executeFetchRequest:fetchRequest
                                                                                                                               error:NULL];
												  
                                                  if (![videosArray count]) {
                                                      // implement
                                                  }
												  
												  NSArray *sortedVideos = [strongSelf sortedVideoInstances:videosArray inIdOrder:videoInstanceIds];
                                                  
                                                  
												  if (sortedVideos.count > 0) {
                                                      rand = floorf((NSInteger)arc4random_uniform(sortedVideos.count)-1);
                                                      
                                                      if (rand > sortedVideos.count) {
                                                          rand = 0;
                                                      }
													  
													  if (IS_IPHONE) {
														  SYNPagingModel *model = [[SYNStaticModel alloc] initWithItems:sortedVideos];
														  UIViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:model
																																	 selectedIndex:rand];
														  viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
														  [strongSelf presentViewController:viewController animated:YES completion:nil];
													  }
                                                  }
                                                  
                                                  strongSelf.watchButton.userInteractionEnabled = YES;
                                                  
                                              } errorHandler:^(id error) {
                                                  
                                              }];
}

#pragma mark - UICollectionView Data Source Stubs

// To be implemented by subclasses
- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section {
    
    if (collectionView == self.moodCollectionView) {
        return self.moods.count > 0 ? largeAmountOfRows : 0;
        
    }
    return self.randomVideoArray.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    if (cv == self.moodCollectionView) {
        SYNMoodCell *moodCell = [self.moodCollectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([SYNMoodCell class])
                                                                                   forIndexPath: indexPath];
        
        Mood* mood = self.moods [indexPath.item % self.moods.count];
        
        
        if (IS_IPAD) {
            
            if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
                moodCell.titleLabel.font = [UIFont regularCustomFontOfSize:(20.0f)];
            } else {
                moodCell.titleLabel.font = [UIFont regularCustomFontOfSize:(18.0f)];
            }
        }
        moodCell.titleLabel.text = mood.name;
        
        
        return moodCell;
        
    }
    
    if (cv == self.videoCollectionView) {
        SYNSearchResultsVideoCell *videoCell = [cv dequeueReusableCellWithReuseIdentifier:[SYNSearchResultsVideoCell reuseIdentifier]
                                                                             forIndexPath:indexPath];
        videoCell.videoInstance = (VideoInstance*)(self.randomVideoArray[indexPath.item]);
        videoCell.ownerThumbnailButton.userInteractionEnabled = NO;
        videoCell.ownerThumbnailButton.userInteractionEnabled = NO;
        videoCell.channelNameButton.userInteractionEnabled = NO;
        videoCell.delegate = self;
        return videoCell;
        
    }
    return nil;
}


- (void) collectionView: (UICollectionView *) cv
didSelectItemAtIndexPath: (NSIndexPath *)indexPath {
    
    if (cv == self.moodCollectionView) {
        if (self.currentMood == self.moods [indexPath.item % self.moods.count]) {
			
			[[SYNTrackingManager sharedManager] trackMoodSelected:self.currentMood.name];
			
            if (IS_IPHONE) {
				[self watchVideo];
            } else {
                [self showVideoForIndexPath:indexPath];
            }
        }
    }
    
    if (cv == self.videoCollectionView) {
        
        self.videoCollectionView.userInteractionEnabled = NO;
        
        if (IS_IPHONE) {
            NSLog(@"This should never be called");
            return;
        }
		
		[[SYNTrackingManager sharedManager] trackIPadMoodVideoSelected:self.currentMood.name];
        
        [self showVideoForIndexPath:indexPath];
        
    }
    
}


- (void) showVideoForIndexPath: (NSIndexPath *)indexPath {
    //Dont create the video player unless there is a video
    if (self.videosArray<=0) {
        return;
    }
	
	SYNPagingModel *model = [[SYNStaticModel alloc] initWithItems:self.videosArray];
	UIViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:model
																			   selectedIndex:[self.randomVideoIndex intValue]];
    
    SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
    animator.delegate = self;
    animator.cellIndexPath = indexPath;
    self.videoPlayerAnimator = animator;
    viewController.transitioningDelegate = animator;
    [self presentViewController:viewController animated:YES completion:^{
        self.videoCollectionView.userInteractionEnabled = YES;
    }];
}

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	return (SYNSearchResultsVideoCell *)[self.videoCollectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - ScrollView Delegate (Override to avoid tab bar animating)

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	self.userScrolling = YES;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // override
    
    [self showWatchButton];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    
    if (!decelerate) {
        [self showWatchButton];
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // override
//    [self showWatchButton];
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    // override
    self.watchButton.hidden = YES;
    self.videoCollectionView.hidden = YES;
    self.chooseAnotherButton.hidden = YES;
    
    if (self.scrollingTimer) {
        [self.scrollingTimer invalidate];
    }
    
}

- (void)viewWillLayoutSubviews
{
    
    [super viewWillLayoutSubviews];
    
    if (IS_IPAD) {
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            
            self.moodCollectionView.frame = CGRectMake(117+xAxis, 253, 215, self.moodCollectionView.frame.size.height);
            self.iWantToLabel.frame = CGRectMake(-5+xAxis, 373, self.iWantToLabel.frame.size.width, self.iWantToLabel.frame.size.height);
            self.videoCollectionView.frame = CGRectMake(413+xAxis, 136, 436, 459);
            self.chooseAnotherButton.frame = CGRectMake(94+xAxis, 662, self.chooseAnotherButton.frame.size.width, self.chooseAnotherButton.frame.size.height);            
            self.moodBackground.frame = CGRectMake(1+xAxis, 225, 311, self.moodBackground.frame.size.height);
            self.titleLabel.font = [UIFont systemFontOfSize:23];
            self.divider.frame = CGRectMake(311+xAxis, 0, 1, 768);
            
            
        } else {
            
            self.videoCollectionView.frame = CGRectMake(245+xAxis, 248, 436, 459);
            self.chooseAnotherButton.frame = CGRectMake(64+xAxis, 800, self.chooseAnotherButton.frame.size.width, self.chooseAnotherButton.frame.size.height);
            self.moodCollectionView.frame = CGRectMake(120+xAxis, 372, 131, self.moodCollectionView.frame.size.height);
            self.iWantToLabel.frame = CGRectMake(-25+xAxis, 492, self.iWantToLabel.frame.size.width, self.iWantToLabel.frame.size.height);
            self.moodBackground.frame = CGRectMake(1+xAxis, 340, 254, self.moodBackground.frame.size.height);
            self.titleLabel.font = [UIFont systemFontOfSize:19];
            
            self.divider.frame = CGRectMake(255+xAxis, 64, 1, 960);
        }
        [self setDividerGradient];
    }
}


- (void)showWatchButton {
    
    self.watchButton.hidden = NO;
    self.chooseAnotherButton. hidden = NO;
    self.watchButton.alpha = 0.0f;
    self.chooseAnotherButton.alpha = 0.0f;
    
    [UIView animateWithDuration:watchButtonAnimationTime animations:^{
        self.watchButton.alpha = 1.0f;
        self.chooseAnotherButton.alpha = 1.0f;

    }];
    
    if (IS_IPAD) {
		if (self.userScrolling) {
			[[SYNTrackingManager sharedManager] trackIPadScrolledToMood:self.currentMood.name];
		}
        
        [self showRandomVideoInstance];
    } else {
		if (self.userScrolling) {
			[[SYNTrackingManager sharedManager] trackIPhoneScrolledToMood:self.currentMood.name];
		}
	}
    
}


#pragma mark - Orientation

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    
    [self.moodCollectionView reloadData];
    [self.videoCollectionView reloadData];
}


-(void)setMoods:(NSArray *)moods {
    _moods = moods;
    
    if(moods.count > 0) {
        [self.moodCollectionView reloadData];
        
        // center the moods list to the middle
        [self.moodCollectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForItem:(largeAmountOfRows/2) inSection:0] atScrollPosition: UICollectionViewScrollPositionCenteredVertically animated: NO];
    }
}

-(Mood*)currentMood {
    
    CGPoint point = CGPointMake(self.moodCollectionView.frame.size.width * 0.5f,
                                self.moodCollectionView.frame.size.height * 0.5f + self.moodCollectionView.contentOffset.y);
    
    NSIndexPath* indexPath = [self.moodCollectionView indexPathForItemAtPoint:point];
    
    Mood* cMood = self.moods [indexPath.item % self.moods.count];
    
    
    return cMood;
}


- (NSArray *)sortedVideoInstances:(NSArray *)videoInstances inIdOrder:(NSArray *)videoInstanceIds {
	NSMutableArray *sortedVideoInstances = [NSMutableArray array];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:videoInstances
														   forKeys:[videoInstances valueForKey:@"uniqueId"]];
	
	for (NSString *videoInstanceId in videoInstanceIds) {
		[sortedVideoInstances addObject:dictionary[videoInstanceId]];
	}
	
	return sortedVideoInstances;
}

- (void) setDividerGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    gradient.frame = screenRect;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor dollyMediumGray] CGColor],[(id)[UIColor whiteColor] CGColor], nil];
    [self.divider.layer setSublayers:@[gradient]];
}

#pragma mark - Scrolling animation logic
- (void)scrollSlowly {
    if (self.moods.count>1) {
        [self.moodCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:largeAmountOfRows/4 inSection:0] atScrollPosition:       UICollectionViewScrollPositionCenteredVertically animated:NO];
    } else  {
        return;
    }
    
    // 30 is the middle of the cell
    //this ensures the animation ends with the ell entered
    self.endPoint = CGPointMake(0, self.moodCollectionView.bounds.origin.y+floorf(arc4random()%6+5)*40);

    //Start off screen
    self.scrollingPoint = CGPointMake(0, self.moodCollectionView.bounds.origin.y);
    self.scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(scrollSlowlyToPoint) userInfo:nil repeats:YES];
}

- (void)scrollSlowlyToPoint {
    self.moodCollectionView.bounds = CGRectMake(self.scrollingPoint.x, self.scrollingPoint.y, self.moodCollectionView.bounds.size.width, self.moodCollectionView.bounds.size.height);
    self.videoCollectionView.hidden = YES;
    if (self.scrollingPoint.y>= self.endPoint.y &&(int)self.scrollingPoint.y%40 == 0) {
        [self.scrollingTimer invalidate];
        
        self.scrollingTimer = nil;
        self.chooseAnotherButton. hidden = NO;
        if (IS_IPAD) {
            [self showRandomVideoInstance];
        } else {
            [self showWatchButton];
        }
        
        [self.moodCollectionView.collectionViewLayout invalidateLayout];
    }
    self.scrollingPoint = CGPointMake(self.scrollingPoint.x, self.scrollingPoint.y+2.5);
}
- (IBAction)chooseAnotherTapped:(id)sender {
	[[SYNTrackingManager sharedManager] trackMoodChooseAnother:self.currentMood.name];
	
    [self showRandomVideoInstance];
}


- (void) showRandomVideoInstance {
    
    
    __weak typeof(self) weakSelf = self;
    
    self.videoCollectionView.hidden = YES;
    
    [appDelegate.oAuthNetworkEngine getRecommendationsForUserId: appDelegate.currentUser.uniqueId
                                                  andEntityName: kVideoInstance
                                                         params: @{@"mood":self.currentMood.uniqueId}
                                              completionHandler: ^(id response) {
                                                  
                                                  
                                                  if(![response isKindOfClass:[NSDictionary class]])
                                                      return;
                                                  
                                                  if(![appDelegate.searchRegistry registerVideoInstancesFromDictionary:response
                                                                                                            withViewId:self.viewId])
                                                      return;
                                                  
                                                  NSArray *videoInstances = response[@"videos"][@"items"];
                                                  NSArray *videoInstanceIds = [videoInstances valueForKey:@"id"];
                                                  
                                                  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VideoInstance entityName]];
                                                  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId IN %@", videoInstanceIds];
                                                  [fetchRequest setPredicate:predicate];
                                                  
                                                  NSArray* videosArray = [appDelegate.searchManagedObjectContext executeFetchRequest:fetchRequest
                                                                                                                               error:NULL];
                                                  
                                                  if (![videosArray count]) {
                                                      // implement
                                                  }
                                                  
                                                  NSArray *sortedVideos = [weakSelf sortedVideoInstances:videosArray inIdOrder:videoInstanceIds];
                                                  weakSelf.videosArray = sortedVideos;
                                                  if (sortedVideos.count > 0) {
                                                      

                                                      weakSelf.randomVideoIndex = [NSNumber numberWithUnsignedInt: floorf(arc4random_uniform(sortedVideos.count)-1)];
                                                      
                                                      if (weakSelf.randomVideoIndex.intValue > sortedVideos.count) {
                                                          weakSelf.randomVideoIndex = 0;
                                                      }
                                                      
                                                      weakSelf.randomVideoArray = @[[sortedVideos objectAtIndex:self.randomVideoIndex.intValue]];
                                                      
                                                      [weakSelf.videoCollectionView reloadData];
                                                      
                                                          weakSelf.videoCollectionView.hidden = NO;
                                                      [self showInboarding];

                                                  } else {
                                                      weakSelf.videosArray = nil;
                                                      [weakSelf.videoCollectionView reloadData];
                                                      weakSelf.videoCollectionView.hidden = NO;
                                                  }
                                                  
                                                  weakSelf.chooseAnotherButton.userInteractionEnabled = YES;
                                                  
                                              } errorHandler:^(id error) {
                                                  
                                              }];
    
}


- (void) showInboarding {
    if (IS_IPAD) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey: kUserDefaultsMoodFirstTime]) {
            SYNMoodOverlayViewController* moodOverlay = [[SYNMoodOverlayViewController alloc] init];
            [moodOverlay addToViewController:appDelegate.masterViewController];
            [[NSUserDefaults standardUserDefaults] setBool: YES
                                                    forKey: kUserDefaultsMoodFirstTime];
        }
    }
}


// TODO: profile/channel delegates
- (void) profileButtonPressedForCell:(UICollectionViewCell *)cell {
    
}

-(void) channelButtonPressedForCell:(UICollectionViewCell *)cell {
    
}
- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return YES;
}
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}
- (IBAction)goBack:(id)sender {
	
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
