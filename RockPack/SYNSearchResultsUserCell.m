//
//  SYNSearchResultsUserCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsUserCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNSearchResultsUserCell

-(void) awakeFromNib
{
    
    self.userNameLabel.font = [UIFont lightCustomFontOfSize:self.userNameLabel.font.pointSize];
    
    // == Round off the image == //
    self.userThumbnailImageView.layer.cornerRadius = self.userThumbnailImageView.frame.size.height * 0.5f;
    self.userThumbnailImageView.clipsToBounds = YES;
}

-(void)setDelegate:(id<SYNSocialActionsDelegate>)delegate
{
    if(_delegate)
    {
        [self.followButton removeTarget:_delegate
                                 action:@selector(followControlPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    
    [super setDelegate:delegate];
    
    
    if(!_delegate)
        return; // can set nil
    
    [self.followButton addTarget:_delegate
                          action:@selector(followControlPressed:)
                forControlEvents:UIControlEventTouchUpInside];
}

@end
