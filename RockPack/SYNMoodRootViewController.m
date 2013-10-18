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

@interface SYNMoodRootViewController ()

@property (nonatomic, strong) NSArray *optionNames;
@property (nonatomic, weak) IBOutlet UICollectionView *moodCollectionView;
@property (nonatomic, weak) IBOutlet UILabel *mainLabel;

@end


@implementation SYNMoodRootViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: We need to get this list via an API
    self.optionNames = [@[@"Laugh", @"Learn", @"Be Inspired", @"Get Healthy", @"Work Out", @"Get Cultured", @"Just Listen", @"Cook", @"Look Beautiful", @"", @"", @"Idle Times", @"Gamer Heaven", @"Random Stuff", @"Editor's Pick", @"Cars, Planes & Trains", @"Nerd Up"] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    // Setup mood collection view
    [self.moodCollectionView registerNib: [UINib nibWithNibName: @"SYNMoodCell" bundle: nil]
              forCellWithReuseIdentifier: @"SYNMoodCell"];
    
    self.mainLabel.font = [UIFont regularCustomFontOfSize: self.mainLabel.font.pointSize];
}


#pragma mark - UICollectionView Data Source Stubs

// To be implemented by subclasses
- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    return self.optionNames.count;
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
    
    moodCell.label.text = self.optionNames [indexPath.item];
    
    return moodCell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}


@end
