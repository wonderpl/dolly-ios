//
//  SYNReportConcernTableViewController.h
//  rockpack
//
//  Created by Nick Banks on 08/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

typedef void (^SYNCancelReportBlock)(void);
typedef void (^SYNSendReportBlock)(NSString *reportString);
typedef void (^SYNSelectedReportBlock)(void);
typedef void (^SYNReportCompletedBlock)(void);

@interface SYNReportConcernTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


- (void) reportConcernFromView: (UIButton *) presentingButton
              inViewController: (UIViewController *) viewController
         popOverArrowDirection: (UIPopoverArrowDirection) direction
                    objectType: (NSString *) objectType
                      objectId: (NSString *) objectId
                completedBlock: (SYNReportCompletedBlock) completedBlock;

@end
