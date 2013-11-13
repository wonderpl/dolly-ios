//
// OWFacebookActivity.m
// OWActivityViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "OWActivityViewController.h"
#import "OWFacebookActivity.h"
#import "SYNAppDelegate.h"
#import "SYNMasterViewController.h"

@implementation OWFacebookActivity

- (id) init
{
    self = [super initWithTitle: NSLocalizedStringFromTable(@"activity.Facebook.title", @"OWActivityViewController", @"Facebook")
                          image: [UIImage imageNamed: @"ShareFacebookButton"]
                    actionBlock: nil];
    
    if (!self)
    {
        return nil;
    }
    
    __typeof(&*self) __weak weakSelf = self;
    self.actionBlock = ^(OWActivity *activity, OWActivityViewController *activityViewController) {
        
        UIViewController *presenter = activityViewController.presentingController;
        NSDictionary *userInfo = weakSelf.userInfo ? weakSelf.userInfo : activityViewController.userInfo;
        
        NSString *text = userInfo[@"text_facebook"];
        
        // Fallback to standard message if email specific message not available
        if ([text isEqualToString: @""])
        {
            text = userInfo[@"text"];
        }
        
        [activityViewController dismissViewControllerAnimated: YES
                                                   completion: ^{
                                                       [weakSelf  shareFromViewController: presenter
                                                                                     text: text
                                                                                      url: userInfo[@"url"]
                                                                                    image: userInfo[@"image"]
                                                                                  isOwner: userInfo[@"owner"]
                                                                                  isVideo: userInfo[@"video"]];
                                                   }];
    };
    
    return self;
}


- (void) shareFromViewController: (UIViewController *) viewController
                            text: (NSString *) text url: (NSURL *) url
                           image: (UIImage *) image
                         isOwner: (NSNumber *) isOwner
                         isVideo: (NSNumber *) isVideo
{
    FBAppCall *appCall = nil;
    
    NSString *facebookNamespace = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"FacebookNamespace"];
    
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    
    FBOpenGraphActionShareDialogParams *params = [[FBOpenGraphActionShareDialogParams alloc] init];
    
    if (isVideo.boolValue)
    {
        [action setObject: [url absoluteString]
                   forKey: @"other"];
        
        params.action = action;
        params.previewPropertyName = @"other";
        params.actionType = [NSString stringWithFormat: @"%@:share", facebookNamespace];
    }
    else
    {
        [action setObject: [url absoluteString]
                   forKey: @"channel"];
        
        params.action = action;
        params.previewPropertyName = @"channel";
        
        if (isOwner.boolValue == TRUE)
        {
            params.actionType = [NSString stringWithFormat: @"%@:create", facebookNamespace];
            //            params.actionType = @"rockpack-dev:create";
        }
        else
        {
            params.actionType = [NSString stringWithFormat: @"%@:share", facebookNamespace];
            //            params.actionType = @"rockpack-dev:share";
        }
    }
    
    // Show the Share dialog if available
    if (([FBDialogs canPresentShareDialogWithOpenGraphActionParams: params] == TRUE))
    {
        appCall = [FBDialogs presentShareDialogWithOpenGraphAction: [params action]
                                                        actionType: [params actionType]
                                               previewPropertyName: [params previewPropertyName]
                                                       clientState: nil
                                                           handler: ^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                               if (error)
                                                               {
                                                                   NSLog(@"Error: %@", error.description);
                                                               }
                                                               else
                                                               {
                                                                   NSLog(@"Success!");
                                                                   [self updateAPIRater];
                                                               }
                                                           }];
        
        SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
    }
    
    //    else
    //    {
    //        // Try the Share dialog if available
    //        appCall = [FBDialogs presentShareDialogWithLink: url
    //                                                   name: nil
    //                                                caption: text
    //                                            description: nil
    //                                                picture: nil
    //                                            clientState: nil
    //                                                handler: ^(FBAppCall *call, NSDictionary *results, NSError *error) {
    //                                                    if (error) {
    //                                                        NSLog(@"Error: %@", error.description);
    //                                                    } else {
    //                                                        NSLog(@"Success!");
    //                                                    }
    //                                                }];
    //    }
    
    // If neither of the above methods worked, then try the old way...
    if (appCall == nil)
    {
        // OK, just default to LCD
        SLComposeViewController *facebookViewComposer = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeFacebook];
        
        // Add a completion handler so that we can check
        facebookViewComposer.completionHandler = ^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone)
            {
                [self updateAPIRater];
            }
        };
        
        viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        
        if (text)
        {
            [facebookViewComposer setInitialText: text];
        }
        
        if (url)
        {
            [facebookViewComposer addURL: url];
        }
        
        [viewController presentViewController: facebookViewComposer
                                     animated: YES
                                   completion: ^{
                                       SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
                                       
                                       [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
                                   }];
    }
}


@end
