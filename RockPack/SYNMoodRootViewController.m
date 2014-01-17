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
#import "SYNCarouselVideoPlayerViewController.h"
#import "SYNDeviceManager.h"
#import "Mood.h"
#import "UINavigationBar+Appearance.h"
#import "UIColor+SYNColor.h"
#include <stdlib.h>


#define LARGE_AMOUNT_OF_ROWS 10000
#define WATCH_BUTTON_ANIMATION_TIME 1.5f

@interface SYNMoodRootViewController ()

@property (nonatomic, strong) NSArray *moods;
@property (nonatomic, weak) IBOutlet UICollectionView *moodCollectionView;
@property (nonatomic, weak) IBOutlet UILabel *iWantToLabel;
@property (strong, nonatomic) IBOutlet UIButton *watchButton;

@property (nonatomic, readonly) Mood* currentMood;
@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;
@end


@implementation SYNMoodRootViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.moods = @[];
    
    // Setup mood collection view
    [self.moodCollectionView registerClass:[SYNMoodCell class]
                forCellWithReuseIdentifier:NSStringFromClass([SYNMoodCell class])];
    

    self.iWantToLabel.font = [UIFont regularCustomFontOfSize: self.iWantToLabel.font.pointSize];
    
    
    self.moodCollectionView.scrollsToTop = NO;
    
    [self loadMoods];
    
    [self getUpdatedMoods];
    
    [self.navigationController.navigationBar setBackgroundTransparent:YES];
    self.navigationController.title = @"";
    [self.navigationItem setTitle:@""];

    self.watchButton.layer.cornerRadius = 18.0f;
    self.watchButton.layer.masksToBounds = YES;
    
    self.watchButton.layer.borderWidth = 1.5f;
    self.watchButton.layer.borderColor = [[UIColor dollyMoodColor] CGColor];
    
    
    
    
    if (!IS_IPHONE_5) {
        //TODO: need to move views for 3.5
    }
    
//TODO: animate the initial scrolling
    
//    int randomRow = arc4random() % 10;
//
//    NSLog(@"rand : %d", randomRow);
//
//    
//    [UIView animateWithDuration:3.0f animations:^{
//        
//        [self.moodCollectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForRow:randomRow inSection:0]
//                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
//                                                animated:YES];
//
//    } completion:^(BOOL finished) {
//        
//    }];
    

}

#pragma mark - Getting Mood Objects

- (void) loadMoods
{
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Mood"];
    
    NSError* error;
    self.moods = [appDelegate.mainManagedObjectContext executeFetchRequest:fetchRequest
                                                                     error:&error];
    if(self.moods == 0)
    {
        
    }
    
    [self.moodCollectionView reloadData];
    
    
}

-(void) getUpdatedMoods
{
    [appDelegate.networkEngine getMoodsWithCompletionHandler:^(id responce) {
        
        if(![responce isKindOfClass:[NSDictionary class]])
            return;
        
        if([appDelegate.mainRegistry registerMoodsFromDictionary:responce
                                               withExistingMoods:self.moods])
        {
            [self loadMoods];
        }
        
        
        
    } errorHandler:^(id error) {
        
        
        
    }];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([[SYNDeviceManager sharedInstance] isPortrait] && IS_IPAD)
    {
        [self positionElementsForInterfaceOrientation:UIDeviceOrientationPortrait];
    }
    
}

#pragma mark - Control Callbacks
- (IBAction)watchButtonTapped:(id)sender
{
    [appDelegate.oAuthNetworkEngine getRecommendationsForUserId: appDelegate.currentUser.uniqueId
                                                  andEntityName: kVideoInstance
                                                         params: @{@"mood":self.currentMood.uniqueId}
                                              completionHandler: ^(id responce) {
                                                  
                                                  if(![responce isKindOfClass:[NSDictionary class]])
                                                      return;
                                                  
                                                  if(![appDelegate.searchRegistry registerVideoInstancesFromDictionary:responce
                                                                                                            withViewId:self.viewId])
                                                      return;
                                                  
                                                  
                                                  NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kVideoInstance];
                                                  
                                                  NSError* error;
                                                  
                                                  NSArray* videosArray = [appDelegate.mainManagedObjectContext executeFetchRequest:fetchRequest
                                                                                                             error:&error];
                                                  
                                                  
                                                  if(videosArray.count == 0)
                                                  {
                                                      // implement
                                                  }
                                                  
                                                  UIViewController* viewController = [SYNCarouselVideoPlayerViewController viewControllerWithVideoInstances:videosArray selectedIndex:0];
                                                  
                                                  [self presentViewController:viewController animated:YES completion:nil];
                                                  
                                              } errorHandler:^(id error) {
                                                  
                                                  
                                              }];
}


#pragma mark - UICollectionView Data Source Stubs

// To be implemented by subclasses
- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    return self.moods.count > 0 ? LARGE_AMOUNT_OF_ROWS : 0;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNMoodCell *moodCell = [self.moodCollectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([SYNMoodCell class])
                                                                               forIndexPath: indexPath];
    
    Mood* mood = self.moods [indexPath.item % self.moods.count];
    
    moodCell.titleLabel.text = mood.name;
    
    return moodCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // == first of last item
    if (indexPath.row == 0 || (indexPath.row % self.moods.count == self.moods.count-1)) {
        return CGSizeMake(self.moodCollectionView.frame.size.width, (IS_IPAD ? 35.0f :35.0f));
    }

    return CGSizeMake(self.moodCollectionView.frame.size.width, (IS_IPAD ? 40.0f :40.0f));
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *)indexPath
{
    

}

#pragma mark - ScrollView Delegate (Override to avoid tab bar animating)


-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // override
    
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // override
    [self stoppedScrolling];

}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    // override
    self.watchButton.hidden = YES;

}

- (void)stoppedScrolling
{
    // done, do whatever
    
    self.watchButton.hidden = NO;
    self.watchButton.alpha = 0.0f;
    
    [UIView animateWithDuration:WATCH_BUTTON_ANIMATION_TIME animations:^{
        self.watchButton.alpha = 1.0f;
    }];

}


#pragma mark - Orientation

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [self.moodCollectionView reloadData];
//    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    
//    if(IS_IPAD)
//    {
//        [self positionElementsForInterfaceOrientation:toInterfaceOrientation];
//    }
    
}

- (void) positionElementsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
//    CGRect correctBGImageFrame = self.backgroundImageView.frame;
//    
//    if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
//    {
//        correctBGImageFrame.origin.y = (self.view.frame.size.height * 0.5f) - (correctBGImageFrame.size.height * 0.5f);
//        
//    }
//    else // Landscape
//    {
//        correctBGImageFrame.origin.y = 64.0f;
//        
//        
//    }
//    
//    // == Set the Background Image == //
//    self.backgroundImageView.frame = correctBGImageFrame;
//    CGRect moodFrame = self.moodCollectionView.frame;
//    moodFrame.origin.y = correctBGImageFrame.origin.y;
//    self.moodCollectionView.frame = moodFrame;
//    
//    
//    // == Set the Label == //
//    CGRect labelFrame = self.iWantToLabel.frame;
//    labelFrame.origin.y = (self.backgroundImageView.frame.size.height * 0.5f) - (labelFrame.size.height * 0.5f) + correctBGImageFrame.origin.y;
//    self.iWantToLabel.frame = labelFrame;
    
}

-(void)setMoods:(NSArray *)moods
{
    _moods = moods;
    
    if(moods.count > 0)
    {
        [self.moodCollectionView reloadData];
        
        // center the moods list to the middle
        [self.moodCollectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForItem:(LARGE_AMOUNT_OF_ROWS/2) inSection:0]
                                        atScrollPosition: UICollectionViewScrollPositionCenteredVertically
                                                animated: NO];
    }
}

-(Mood*)currentMood
{
    
    CGPoint point = CGPointMake(self.moodCollectionView.frame.size.width * 0.5f,
                                self.moodCollectionView.frame.size.height * 0.5f + self.moodCollectionView.contentOffset.y);
    
    NSIndexPath* indexPath = [self.moodCollectionView indexPathForItemAtPoint:point];
    
    Mood* cMood = self.moods [indexPath.item % self.moods.count];
    
    
    return cMood;
}

@end
