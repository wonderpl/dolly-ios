//
//  SYNImplicitSharingController.m
//  rockpack
//
//  Created by Michael Michailidis on 06/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNImplicitSharingController.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"
#import "SYNFacebookManager.h"
#import "SYNOAuthNetworkEngine.h"
#import "AppConstants.h"

@interface SYNImplicitSharingController ()

@end

@implementation SYNImplicitSharingController




+(id)controllerWithBlock:(ImplicitSharingCompletionBlock)block
{
    SYNImplicitSharingController* instance = [[self alloc] init];
    instance.completionBlock = block;
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // ====
    
    self.textLabel.font = [UIFont lightCustomFontOfSize:self.textLabel.font.pointSize];
    
    [self.textLabel sizeToFit];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = self.view.frame.size.width * 0.5f - textLabelFrame.size.width * 0.5f;
    
    self.textLabel.frame = CGRectIntegral(textLabelFrame);
    
    
}

-(IBAction)autopostButtonPressed:(UIButton*)sender
{
    if(sender.selected) // button is pressed twice
        return;
    
    // at this point we should be guaranteed to have a FB account
    
    sender.selected = YES;
    
    
    
    __weak SYNImplicitSharingController* wself = self;
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    BOOL isYesButton = (sender == self.yesButton);
    
    if(!isYesButton) // NO button pressed, dismiss and save the setting
    {
        
        appDelegate.currentUser.facebookAccount.noautopostValue = YES;
        
        [appDelegate saveContext: YES];
        
        [self dismiss];
        
        // the completion block is a recursive call that will check again for the need to display this panel,
        // the noautopostValue needs to be set to YES first so as to not be called again.
        if(self.completionBlock)
            self.completionBlock(NO);
        
        return;
    }
    else
    {
        void(^ErrorBlock)(id) = ^(id error){
            
            [wself switchAutopostViewToYes:!isYesButton];
        };
        
        
        
        [[SYNFacebookManager sharedFBManager] openSessionWithPermissionType:kFacebookPermissionTypePublish onSuccess:^{
            
            __weak SYNAppDelegate* wAppDelegate = appDelegate;
            
            
            FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
            
            [wAppDelegate.oAuthNetworkEngine connectFacebookAccountForUserId:appDelegate.currentUser.uniqueId
                                                          andAccessTokenData:accessTokenData
                                                           completionHandler:^(id no_responce) {
                                                               
                        // Shortcut for not reposting an existing value
                                                               
                        if(appDelegate.currentUser.facebookAccount.flagsValue & ExternalAccountFlagAutopostStar) {
                                                                   
                            if(self.completionBlock)
                                self.completionBlock(YES);
                            
                            [self dismiss];
                                                                   
                            return;
                        }
                                                               
                        [appDelegate.oAuthNetworkEngine setFlag:@"facebook_autopost_star"
                                                      withValue:isYesButton
                                                       forUseId:appDelegate.currentUser.uniqueId
                                              completionHandler:^(id no_response) {
                                                  
                                                  
                                                                                                  
                                            [wself switchAutopostViewToYes:isYesButton];
                                                                                                  
                                            if(isYesButton)
                                                [wAppDelegate.currentUser setFlag:ExternalAccountFlagAutopostStar toExternalAccount:kFacebook];
                                            else
                                                [wAppDelegate.currentUser unsetFlag:ExternalAccountFlagAutopostStar toExternalAccount:kFacebook];
                                                                                                  
                                                [wAppDelegate saveContext:YES];
                                                  
                                                  
                                                  
                                                if(self.completionBlock)
                                                    self.completionBlock(YES);
                                                                                                  
                                                [self dismiss];
                                                                                                  
                                        } errorHandler:ErrorBlock];
                                                                  
                                                                  
                    } errorHandler:ErrorBlock];
            
            
        } onFailure:ErrorBlock];
    }
    
    
}

-(void)dismiss
{
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
}

-(void)switchAutopostViewToYes:(BOOL)value
{
    self.yesButton.selected = value;
    self.notNowButton.selected = !value;
}

@end
