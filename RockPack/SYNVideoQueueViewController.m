//
//  SYNVideoQueueViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoQueueViewController.h"
#import "SYNVideoQueueView.h"
#import "SYNVideoSelection.h"
#import "SYNVideoQueueCell.h"
#import "Video.h"
#import "VideoInstance.h"
#import "AppConstants.h"
#import "SYNSoundPlayer.h"

@interface SYNVideoQueueViewController ()

@property (nonatomic, readonly) SYNVideoQueueView* videoQueueView;

@end

@implementation SYNVideoQueueViewController

@dynamic videoQueueView;

@synthesize delegate;

-(void)loadView
{
    SYNVideoQueueView* videoQView = [[SYNVideoQueueView alloc] init];
    videoQView.videoQueueCollectionView.dataSource = self;
    videoQView.videoQueueCollectionView.delegate = self;
    self.view = videoQView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDelegate Methods

- (NSInteger) collectionView: (UICollectionView *) cv numberOfItemsInSection: (NSInteger) section {
    
    return SYNVideoSelection.sharedVideoSelectionArray.count;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    SYNVideoQueueCell *videoQueueCell = [cv dequeueReusableCellWithReuseIdentifier: @"VideoQueueCell"
                                                                      forIndexPath: indexPath];
    
    VideoInstance *videoInstance = [SYNVideoSelection.sharedVideoSelectionArray objectAtIndex: indexPath.item];
    
    // Load the image asynchronously
    videoQueueCell.VideoImageViewImage = videoInstance.video.thumbnailURL;
    
    cell = videoQueueCell;
    
    return cell;
}

- (BOOL) collectionView: (UICollectionView *) cv didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath
{
    
    BOOL handledInAbstractView = YES;
    
    DebugLog (@"Selecting image well cell does nothing");
    
    return handledInAbstractView;
}

-(SYNVideoQueueView*)videoQueueView
{
    return (SYNVideoQueueView*)self.view;
}

#pragma mark - Delegate

-(void)setDelegate:(id<SYNVideoQueueDelegate>)del
{
    delegate = del;
    
    [self.videoQueueView.deleteButton addTarget:self action: @selector(clearVideoQueue) forControlEvents: UIControlEventTouchUpInside];
    
    [self.videoQueueView.channelButton addTarget:self.delegate action: @selector(createChannelFromVideoQueue) forControlEvents: UIControlEventTouchUpInside];
}

- (void) clearVideoQueue
{
    
    
    [self.videoQueueView showMessage:YES];
    
    self.videoQueueView.channelButton.enabled = NO;
    self.videoQueueView.channelButton.selected = NO;
    self.videoQueueView.deleteButton.enabled = NO;
    
    [SYNVideoSelection.sharedVideoSelectionArray removeAllObjects];
    
    [self.videoQueueView.videoQueueCollectionView reloadData];
}

-(void)reloadData
{
    [self.videoQueueView.videoQueueCollectionView reloadData];
    
}


#pragma mark - Animation Methods

- (void) showVideoQueue: (BOOL) animated
{
    [self hideShowVideoQueue:YES animated:animated];
}


- (void) hideVideoQueue: (BOOL) animated
{
    [self hideShowVideoQueue:NO animated:animated];
    
    
}


-(void)hideShowVideoQueue:(BOOL)show animated:(BOOL)animated
{
    CGRect videoQueueViewFrame = self.videoQueueView.frame;
    if(show)
        videoQueueViewFrame.origin.y -= kVideoQueueEffectiveHeight;
    else
        videoQueueViewFrame.origin.y += kVideoQueueEffectiveHeight;
    
    if (animated)
    {
        [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             
                             
                             self.videoQueueView.frame = videoQueueViewFrame;
                         }
                         completion: ^(BOOL finished) {
                             
                         }];
    }
    else
    {
        self.videoQueueView.frame = videoQueueViewFrame;
    }
}

- (void) addVideoToQueue: (VideoInstance *) videoInstance
{
    [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundSelect];
    
    
    
    if (SYNVideoSelection.sharedVideoSelectionArray.count == 0)
    {
        self.videoQueueView.channelButton.enabled = YES;
        self.videoQueueView.channelButton.selected = YES;
        self.videoQueueView.deleteButton.enabled = YES;
        
        [self.videoQueueView showMessage:NO];
    }
    
    
    [SYNVideoSelection.sharedVideoSelectionArray addObject: videoInstance];
    
    [self.videoQueueView addVideoToQueue:videoInstance];
}

-(void)setHighlighted:(BOOL)value
{
    if (value)
    {
        self.videoQueueView.backgroundImageView.image = [UIImage imageNamed: @"PanelVideoQueueHighlighted.png"];
    }
    else
    {
        self.videoQueueView.backgroundImageView.image = [UIImage imageNamed: @"PanelVideoQueue.png"];
    }
}

@end
