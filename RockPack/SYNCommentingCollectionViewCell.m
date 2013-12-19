//
//  SYNCommentingCollectionViewCell.m
//  dolly
//
//  Created by Michael Michailidis on 06/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCommentingCollectionViewCell.h"
#import "Comment.h"
#import "UIButton+WebCache.h"
#import "UIFont+SYNFont.h"
#import "SYNCommentingViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface SYNCommentingCollectionViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;

@property (nonatomic) BOOL cellOpenForDeletion;

@end

@implementation SYNCommentingCollectionViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarButton.layer.cornerRadius = self.avatarButton.frame.size.height * 0.5f;
    
    self.nameLabel.font = [UIFont regularCustomFontOfSize:self.nameLabel.font.pointSize];
    
    self.commentTextView.font = [SYNCommentingCollectionViewCell commentFieldFont];
    
    
    self.timeLabel.font = [UIFont regularCustomFontOfSize:self.timeLabel.font.pointSize];
    
    self.commentTextView.textContainerInset = UIEdgeInsetsZero;
    
    self.avatarButton.layer.cornerRadius = self.avatarButton.frame.size.height * 0.5;
    self.avatarButton.clipsToBounds = YES;
    
    self.loader.hidden = YES;
    
    self.mainElements = @[self.avatarButton, self.nameLabel, self.commentTextView];
    
    
    // == Gesture Recognisers == //
    
    
    
    
    [self.deleteButton.titleLabel setFont:[UIFont lightCustomFontOfSize:19]];
    
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    self.deleting = NO;
    
    
    
}

- (void) setDelegate:(SYNCommentingViewController *)delegate
{
    if(_delegate)
    {
        [self.deleteButton removeTarget:_delegate
                                 action:@selector(deleteButtonPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    
    _delegate = delegate;
    
    if(!_delegate)
        return;
    
    [self.deleteButton addTarget:_delegate
                          action:@selector(deleteButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
}

- (void) setComment:(Comment *)comment
{
    _comment = comment;
    
    if(!_comment)
        return;
    
    NSString* commentText = _comment.commentText;
    
    self.nameLabel.text = _comment.displayName;
    
    self.commentTextView.text = commentText;
    
    self.datePosted = _comment.dateAdded;
    
    [self.avatarButton setImageWithURL: [NSURL URLWithString: comment.thumbnailUrl]
                              forState: UIControlStateNormal
                      placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarProfile"]
                               options: SDWebImageRetryFailed];
    
    
    // set the textColor again due to an iOS7 bug
    self.commentTextView.textColor = self.nameLabel.textColor;
}

- (void) setLoading:(BOOL)loading
{
    _loading = loading;
    
    if(_loading)
    {
        self.timeLabel.hidden = YES;
        self.loader.hidden = YES;
        [self.loader startAnimating];
    }
    else
    {
        self.timeLabel.hidden = NO;
        [self.loader stopAnimating];
        self.loader.hidden = YES;
    }
    
    for (UIView* element in self.mainElements)
        element.alpha = _loading ? 0.7f : 1.0f ;
    
}

+(UIFont*)commentFieldFont
{
    return [UIFont regularCustomFontOfSize:12.0f];
}

+(CGRect)commentFieldFrame
{
    return CGRectMake(48.0f, 28.0f, 213.0f, 18.0f);
}

#pragma mark - Parsing Date

-(void)setDatePosted:(NSDate *)datePosted
{
    _datePosted = datePosted;
    
    // find difference from today
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [timeZone secondsFromGMTForDate: datePosted];
    datePosted = [NSDate dateWithTimeInterval: seconds
                                    sinceDate: datePosted];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSUInteger componentflags =
    NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit;
    NSDateComponents *components = [calendar components: componentflags
                                               fromDate: datePosted
                                                 toDate: [NSDate date]
                                                options: 0];
    
    NSString *dateDifferenceString;
    
    if (components.year > 0)
        dateDifferenceString = [NSString stringWithFormat: @"%i year%@", components.year, (components.year > 1 ? @"s" : @"")];
    else if (components.month > 0)
         dateDifferenceString =  [NSString stringWithFormat: @"%i month%@", components.month, (components.month > 1 ? @"s" : @"")];
    else if (components.day > 0)
         dateDifferenceString =  [NSString stringWithFormat: @"%i day%@", components.day, (components.day > 1 ? @"s" : @"")];
    else if (components.hour > 0)
         dateDifferenceString =  [NSString stringWithFormat: @"%i hour%@", components.hour, (components.hour > 1 ? @"s" : @"")];
    else if (components.minute > 0)
         dateDifferenceString =  [NSString stringWithFormat: @"%i min%@ ago", components.minute, (components.minute > 1 ? @"s" : @"")];
    else
        dateDifferenceString = @"now";
    
    self.timeLabel.text = [NSString stringWithString: dateDifferenceString];
}

#pragma mark - Gesture Recogniser

- (void)gestureRecogniserCallback:(UISwipeGestureRecognizer*)recogniser
{
    if(recogniser.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        
        if(self.cellOpenForDeletion)
            return;
        
        self.cellOpenForDeletion = YES;
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect cRect = self.containerView.frame;
            cRect.origin.x = -(self.deleteButton.frame.size.width);
            self.containerView.frame = cRect;
            
        }];
    }
    else
    {
      
        
        if(!self.cellOpenForDeletion)
            return;
        
        self.cellOpenForDeletion = NO;
        
        [UIView animateWithDuration:0.3f animations:^{
            
            CGRect cRect = self.containerView.frame;
            cRect.origin.x = 0;
            self.containerView.frame = cRect;
            
        }];
    }
    
    
}

- (void) setDeleting:(BOOL)deleting
{
    if(deleting)
    {
        self.deleteButton.enabled = NO;
        [self.deleteButton setTitle:@"" forState:UIControlStateNormal];
    }
    else
    {
        self.deleteButton.enabled = YES;
        [self.deleteButton setTitle:NSLocalizedString(@"Delete ?", nil) forState:UIControlStateNormal];
        
    }
}

- (void) setDeletable:(BOOL)deletable
{
    _deletable = deletable;
    if (_deletable)
    {
        self.rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(gestureRecogniserCallback:)];
        
        [self.rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
        
        self.rightSwipe.delegate = self;
        
        [self.containerView addGestureRecognizer:self.rightSwipe];
        
        self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(gestureRecogniserCallback:)];
        
        [self.leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
        
        self.leftSwipe.delegate = self;
        
        
        [self.containerView addGestureRecognizer:self.leftSwipe];
    }
    else
    {
        
        [self clearSwipeGestureRecognisers];
    }
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    [self clearSwipeGestureRecognisers];
    
    self.loading = NO;
    self.deleting = NO;
    
    // "close" the cell from Delete mode if it was there
    CGRect cRect = self.containerView.frame;
    cRect.origin.x = 0.0f;
    self.containerView.frame = cRect;
    
    
}

- (void) clearSwipeGestureRecognisers
{
    for (UIGestureRecognizer* recogniser in self.containerView.gestureRecognizers)
    {
        
        [self.containerView removeGestureRecognizer:recogniser];
    }
}

@end
