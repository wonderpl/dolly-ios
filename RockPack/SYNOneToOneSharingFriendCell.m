//
//  SYNOneToOneSharingFriendCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOneToOneSharingFriendCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNOneToOneSharingFriendCell

-(void)awakeFromNib
{
    
    self.nameLabel.font = [UIFont lightCustomFontOfSize:self.nameLabel.font.pointSize];
    
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width * 0.5;
    
    
}


- (void) setDisplayName: (NSString*) displayName
{
    self.nameLabel.text = displayName;
}
@end
