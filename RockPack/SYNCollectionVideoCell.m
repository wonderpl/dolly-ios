//
//  SYNCollectionVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 06/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCollectionVideoCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import <UIImageView+WebCache.h>

@implementation SYNCollectionVideoCell 


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
    [self.likeControl setTitle: NSLocalizedString(@"like", @"Label for follow button on SYNAggregateVideoItemCell")
                      andCount: 0];
    
    self.shareControl.title = NSLocalizedString(@"share", @"Label for share button on SYNAggregateVideoItemCell");
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];

    
}

#pragma mark - Social Callbacks

- (IBAction) likeControlPressed: (SYNSocialButton *) socialButton
{
    [self.delegate likeControlPressed: socialButton];
}

- (IBAction) addControlPressed: (SYNSocialButton *) socialButton
{
    [self.delegate addControlPressed: socialButton];
}

- (IBAction) shareControlPressed: (SYNSocialButton *) socialButton
{
    [self.delegate shareControlPressed: socialButton];
}


- (IBAction)commentControlPressed:(SYNSocialButton*) socialButton {
    
    [self.delegate commentControlPressed: socialButton];
    
}

#pragma mark - Set Video Instance

- (void) setVideoInstance: (VideoInstance *) videoInstance
{
    _videoInstance = videoInstance;
    
    self.shareControl.dataItemLinked = _videoInstance;
    self.addControl.dataItemLinked = _videoInstance;
    self.likeControl.dataItemLinked = _videoInstance;
    self.commentControl.dataItemLinked = _videoInstance;
    
    if (!_videoInstance)
        return;
    
    // == timestamp == //
    
    NSInteger durationSeconds = videoInstance.video.durationValue;
    
    NSMutableString* timeStampString = [[NSMutableString alloc] init];
    NSInteger minutes = (NSInteger)(durationSeconds / 60.0f);
    
    if(minutes < 10)
        [timeStampString appendString:@"0"];
    
    [timeStampString appendFormat:@"%i", minutes];
    
    [timeStampString appendString:@":"];
    
    NSInteger seconds = durationSeconds % 60;
    
    if(seconds < 10)
        [timeStampString appendString:@"0"];
    
    [timeStampString appendFormat:@"%i", seconds];
    
    self.timeStampLabel.text = [NSString stringWithString:timeStampString];
    
    [self.imageView setImageWithURL: [NSURL URLWithString: videoInstance.thumbnailURL]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                            options: SDWebImageRetryFailed];
    
    
    
    self.likeControl.selected = videoInstance.starredByUserValue;
    
    [self.likeControl setTitle: NSLocalizedString(@"like", @"Label for follow button on SYNAggregateVideoItemCell")
                      andCount: videoInstance.video.starCountValue];
    

    self.titleLabel.text = videoInstance.title;
}

#pragma mark - Set delegate


-(void)setDelegate:(id<SYNSocialActionsDelegate>)delegate
{
    _delegate = delegate;
    
    //set an extra delete delegate
    [self.deleteButton addTarget:_delegate
                          action:@selector(deleteVideoInstancePressed:)
                   forControlEvents:UIControlEventTouchUpInside];

}

-(void) setUpVideoTap
{
    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showVideo)];
    [self.imageView addGestureRecognizer: self.tap];

}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIColor *overLayColor = [UIColor colorWithRed: (57.0f / 255.0f)
                                            green: (57.0f / 255.0f)
                                             blue: (57.0f / 255.0f)
                                            alpha: 0.5f];
    
    [self.overlayView setBackgroundColor:overLayColor];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.overlayView setBackgroundColor:[UIColor clearColor]];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self.overlayView setBackgroundColor:[UIColor clearColor]];
}

-(void)showVideo
{
    [self.delegate videoButtonPressed:self];
}


@end
