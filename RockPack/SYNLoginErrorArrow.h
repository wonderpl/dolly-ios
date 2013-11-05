//
//  SYNLoginErrorArrow.h
//  rockpack
//
//  Created by Michael Michailidis on 13/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface SYNLoginErrorArrow : UIView {
    UIImageView* backgroundImageView;
    UILabel* messageLabel;
}


-(void)setMessage:(NSString*)message;
-(id)initWithDefault;
+(id)withMessage:(NSString*)message;
@end
