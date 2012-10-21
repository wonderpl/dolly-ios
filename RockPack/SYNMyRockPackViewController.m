//
//  SYNMyRockPackViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNMyRockPackViewController.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"
#import "SYNVideoDB.h"
#import "SYNSelectionDB.h"
#import "SYNSelection.h"
#import "SYNMyRockpackCell.h"

@interface SYNMyRockPackViewController ()

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *biogs;
@property (nonatomic, strong) IBOutlet UILabel *placeholderText;
@property (nonatomic, strong) IBOutlet UILabel *wallpackTitle;
@property (nonatomic, strong) IBOutlet UILabel *biogTitle;
@property (nonatomic, strong) IBOutlet UILabel *biogBody;
@property (nonatomic, strong) IBOutlet UILabel *coolFactor;
@property (nonatomic, strong) IBOutlet UILabel *scary;
@property (nonatomic, strong) IBOutlet UILabel *cute;
@property (nonatomic, strong) IBOutlet UILabel *strength;
@property (nonatomic, strong) IBOutlet UILabel *superPowers;
@property (nonatomic, strong) IBOutlet UIView *infoView;
@property (nonatomic, strong) IBOutlet UIImageView *wallpackImage;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView;
@property (nonatomic, strong) SYNVideoDB *videoDB;
@property (nonatomic, strong) SYNSelectionDB *selectionDB;


@end

@implementation SYNMyRockPackViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.videoDB = [SYNVideoDB sharedVideoDBManager];
    self.selectionDB = [SYNSelectionDB sharedSelectionDBManager];
    
    self.placeholderText.font = [UIFont rockpackFontOfSize: 24.0f];
    self.wallpackTitle.font = [UIFont boldRockpackFontOfSize: 28.0f];
    self.biogTitle.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.biogBody.font = [UIFont rockpackFontOfSize: 17.0f];
    self.coolFactor.font = [UIFont rockpackFontOfSize: 15.0f];
    self.scary.font = [UIFont rockpackFontOfSize: 15.0f];
    self.cute.font = [UIFont rockpackFontOfSize: 15.0f];
    self.strength.font = [UIFont rockpackFontOfSize: 15.0f];
    self.superPowers.font = [UIFont rockpackFontOfSize: 15.0f];
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNMyRockpackCell"
                                             bundle: nil];
    
    [self.thumbnailView registerNib: thumbnailCellNib
         forCellWithReuseIdentifier: @"MyRockpackCell"];

    self.titles = @[@"Alex (Madagascar)",
                    @"Lady Gaga",
                    @"Justin Bieber",
                    @"James Bond",
                    @"Miley Cyrus",
                    @"Star Wars: Clone Wars",
                    @"Jay-Z",
                    @"Lionel Messi",
                    @"Sulley (Monsters Inc.)",
                    @"The Hulk"];
    
    self.biogs  = @[@"Alex is a not-so-ferocious African lion, who calls himself the king of the zoo. Alex was born in Africa, but lost most of his hunting instincts living the easy life in Central Park Zoo! He's friends with animals lower down the food-chain, but old habits can kick in when he's hungry!",
                    @"In a pop-world of imitators and copy-cats, Lady Gaga stands out as a true original. Gaga has written her own mega-hits such a 'Bad Romance' and 'Born This Way', but she's equally famous for her creative and kooky dress-sense! She's a pioneer in both music and fashion.",
                    @"Justin Bieber is a man who needs little introduction; singer-songwriter, pop-star, entrepreneur, actor and all-around teenage heartthrob, Bieber's  tens of millions of fans adore him, and his army of loyal 'believers' make him one of the biggest names in pop today!",
                    @"His name is Bond; James Bond. Known also by code name 007, Bond is a top MI6 agent with a licence to kill, a knack for gadgets and, ahem, a way with women. Having appeared in 12 novels and 23 movies since his debut in 1953, he's a long-standing icon of British cool.",
                    @"Miley Cyrus is best known for starring in the Hannah Montana TV series, where she plays a girl living a double life as both an ordinary teenage and a pop superstar. Just like Cyrus then, who lives a double life as both a singer and an actress; that really is the best of both worlds!",
                    @"Star Wars: Clone Wars was a short TV series, shown on Cartoon Network back in 2003. The story took place in the time between the films Attack of the Clones and Revenge of the Sith and told more of Anakin and Obi-Wan's backstory, as well as lots of epic battle scenes!",
                    @"From underground rapper to global hip-hop superstar Jay-Z is a great example of what can be done with talent and hard work. Among his many achievements lie 19 UK top 40 hits, a successful clothing line, running a baseball team, and marrying Beyonce!",
                    @"25 year old Lionel Messi is a living legend. In 2011 to 2012 he scored 73 goals, a world record for most goals ever scored in a single season. Once told he'd never be a profession footballer, he beat the odds and has gone on to become one of the greatest football players of all time.",
                    @"Sulley is a long-time friend of cute, green monster Mike Kowalski. Very big and very blue, Sulley was the top scarer of Monsters, Inc. and can be terrifying when he needs to be. Mostly though, he has a warm heart. and fights hard to protect Boo from danger.",
                    @"The brawn to Bruce Banner's brain, the Hulk was created when Banner got exposed to gamma radiation when saving a teen from a gamma bomb explosion. He may be giant and green, and he may have some anger management issues but he still still fights for the good guys!"];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    if (self.selectionDB.selections.count == 0)
    {
        self.placeholderText.hidden = FALSE;
        self.infoView.hidden = TRUE;
    }
    else
    {
        self.placeholderText.hidden = TRUE;
        self.infoView.hidden = FALSE;
        
        int adjustedIndex = self.selectionDB.wallpackIndex % 10;
        
        self.wallpackTitle.text = self.selectionDB.selectionTitle;
        
        NSString *imageName = [NSString stringWithFormat: @"LargeWallpack_%d.jpg", adjustedIndex];
        self.wallpackImage.image = [UIImage imageNamed: imageName];
        
        self.biogTitle.text = [self.titles objectAtIndex: adjustedIndex];
        self.biogBody.text = [self.biogs objectAtIndex: adjustedIndex];
        
        [self.thumbnailView reloadData];
    }
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.selectionDB.selections.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNMyRockpackCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"MyRockpackCell"
                                                            forIndexPath: indexPath];
    
    SYNSelection *selection = [self.selectionDB.selections objectAtIndex: indexPath.row];
    
    UIImage *image = [self.videoDB thumbnailForIndex: selection.index
                                          withOffset: selection.offset];
    cell.imageView.image = image;
    
//    NSString *imageName = [NSString stringWithFormat: @"Wallpack_%d.png", selection.index];
//    UIImage *image = [UIImage imageNamed: imageName];
//    cell.imageView.image = image;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    NSLog (@"Selecting image well cell does nothing");
}


@end
