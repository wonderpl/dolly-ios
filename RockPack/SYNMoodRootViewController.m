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

#define LARGE_AMOUNT_OF_ROWS 10000

@interface SYNMoodRootViewController ()

@property (nonatomic, strong) NSArray *optionNames;
@property (nonatomic, weak) IBOutlet UICollectionView *moodCollectionView;
@property (nonatomic, weak) IBOutlet UILabel *iWantToLabel;

@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;

@end


@implementation SYNMoodRootViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // TODO: We need to get this list via an API
    self.optionNames = [@[@"Laugh", @"Learn", @"Be Inspired", @"Get Healthy", @"Work Out", @"Get Cultured", @"Just Listen", @"Cook", @"Look Beautiful", @"Twerk", @"Idle Times", @"Gamer Heaven", @"Random Stuff", @"Editor's Pick", @"Cars, Planes & Trains", @"Nerd Up"] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    // Setup mood collection view
    [self.moodCollectionView registerNib: [UINib nibWithNibName: @"SYNMoodCell" bundle: nil]
              forCellWithReuseIdentifier: @"SYNMoodCell"];
    

    self.iWantToLabel.font = [UIFont regularCustomFontOfSize: self.iWantToLabel.font.pointSize];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.moodCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(LARGE_AMOUNT_OF_ROWS/2) inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                            animated:NO];
}


#pragma mark - UICollectionView Data Source Stubs

// To be implemented by subclasses
- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    return LARGE_AMOUNT_OF_ROWS;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNMoodCell *moodCell = [self.moodCollectionView dequeueReusableCellWithReuseIdentifier: @"SYNMoodCell"
                                                                               forIndexPath: indexPath];
    
    NSString* currentOptionName = self.optionNames [indexPath.item % self.optionNames.count];
    moodCell.label.text = currentOptionName;
    
    
    return moodCell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog (@"Selected");

}

- (void) positionBackgroundImageForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGRect correctBGImageFrame = self.backgroundImageView.frame;
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        correctBGImageFrame.origin.y = (self.view.frame.size.height * 0.5f) - (correctBGImageFrame.size.height * 0.5f);
    }
    else // Landscape
    {
        correctBGImageFrame.origin.y = 64.0f;
        
        
    }
    self.backgroundImageView.frame = correctBGImageFrame;
    
}

#pragma mark - Orientation

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(IS_IPAD)
    {
        [self positionBackgroundImageForInterfaceOrientation:toInterfaceOrientation];
    }
    
}


@end
