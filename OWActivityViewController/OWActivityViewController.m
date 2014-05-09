//
// OWActivityViewController.m
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

#import "OWActivityView.h"
#import "OWActivityViewController.h"

@interface OWActivityViewController ()


@end

@implementation OWActivityViewController




- (id) initWithViewController: (UIViewController *) viewController
                   activities: (NSArray *) activities
{
    self = [super init];
    
    if (self)
    {
        self.presentingController = viewController;
        
        self.view.frame = CGRectMake(0, 0, 255.0f, 66.0f);
        
        _activities = activities;
        
        _activityView = [[OWActivityView alloc] initWithFrame: CGRectMake(0, 0, 255.0f, 61.0f)
                                                   activities: activities];
        
        
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _activityView.activityViewController = self;
        
        [self.view addSubview: _activityView];
    }
    
    return self;
}


- (void) dismissViewControllerAnimated: (BOOL) flag completion: (void(^)(void)) completion
{
    completion();
}


//This handles the tap outside
- (void) dismissViewControllerOnTouch
{
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}


- (void) presentFromRootViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    [rootViewController addChildViewController: self];
    [rootViewController.view addSubview: self.view];
    [self didMoveToParentViewController: rootViewController];
}


- (void) didMoveToParentViewController: (UIViewController *) parent
{
    [super didMoveToParentViewController: parent];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [UIView animateWithDuration: 0.2
                         animations: ^{
                             _backgroundView.alpha = 0.4;
                             
                             CGRect frame = _activityView.frame;
                             frame.origin.y = self.view.frame.size.height - 50.0f;
                             _activityView.frame = frame;
                         }];
    }
}





- (void) viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark -
#pragma mark Helpers

- (void) performBlock: (void (^)(void)) block afterDelay: (NSTimeInterval) delay
{
    block = [block copy];
    
    [self performSelector: @selector(runBlockAfterDelay:)
               withObject: block
               afterDelay: delay];
}


- (void) runBlockAfterDelay: (void (^)(void)) block
{
    if (block != nil)
    {
        block();
    }
}


#pragma mark -
#pragma mark Orientation

- (NSUInteger) supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}




@end
