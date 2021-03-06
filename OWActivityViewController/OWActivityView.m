//
// OWActivityView.h
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

@implementation OWActivityView

- (id) initWithFrame: (CGRect) frame activities: (NSArray *) activities
{
    self = [super initWithFrame: frame];
    
    if (self)
    {
        self.clipsToBounds = NO;
        _activities = activities;
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        NSInteger index = 0;
        
        for (OWActivity *activity in _activities)
        {
            
            
            CGFloat colSize = (IS_IPAD) ? 100.0f : 100.0f;
            
            
            UIView *view = [self viewForActivity: activity
                                           index: index // used as a tag...
                                               x: index * colSize
                                               y: 0];
            
            [self addSubview: view];
            
            index++;
        }
        
    }
    
    return self;
}


- (UIView *) viewForActivity: (OWActivity *) activity index: (NSInteger) index x: (NSInteger) x y: (NSInteger) y
{
    
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    
    if(!activity.enabled)
    {
        // Leave button interactive
        // button.userInteractionEnabled = NO;
        button.alpha = 0.1;
    }
    
    button.frame = CGRectMake(x, y , 60.0f, 60.0f);
    button.tag = index;
    
    [button	addTarget: self
               action: @selector(buttonPressed:)
     forControlEvents: UIControlEventTouchUpInside];
    
    [button setBackgroundImage: activity.image
                      forState: UIControlStateNormal];
    
    button.accessibilityLabel = activity.title;
    
    
    return button;
}



#pragma mark -
#pragma mark Button action

- (void) cancelButtonPressed
{
    [_activityViewController dismissViewControllerAnimated: YES
                                                completion: nil];
}


- (void) buttonPressed: (UIButton *) button
{
    OWActivity *activity = _activities [button.tag];
    
    activity.activityViewController = _activityViewController;
    
    // Bit of a hack, but basically ignore all button presses until we have a valid userInfo (which will happen on return from the simultaneous network call)
    
    if (activity.actionBlock && self.activityViewController.userInfo)
    {
        activity.actionBlock(activity, _activityViewController);
    }
}



@end
