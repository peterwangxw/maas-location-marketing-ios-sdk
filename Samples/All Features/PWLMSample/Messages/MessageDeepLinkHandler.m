//
//  MessageDeepLinkHandler.m
//  PWLMSample
//
//  Created by Xiangwei Wang on 5/13/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PWLocalpoint/PWLocalpoint.h>

#import "MessageDeepLinkHandler.h"
#import "PubUtils.h"

#import "MessagesTableViewController.h"
#import "MessageDetailViewController.h"

// Identifiers
static NSString *const PWMainStoryBoardName = @"Main";
static NSString *const MessageDetailViewControllerIdentifier = @"MessageDetailViewController";
static NSString *const MessagesTableViewControllerIdentifier = @"MessagesTableViewController";

/**
 UIAlertView helper class
 */
@interface LPUIAlertView : UIAlertView

@property (nonatomic) NSString *messageId;

@end

@implementation LPUIAlertView

@end


@implementation MessageDeepLinkHandler

#pragma mark - Public

- (void)process:(id)content {
    if (!content) {
        return;
    }
    
    if ([content isKindOfClass:[UILocalNotification class]]) {
        [self processLocalNotification:content];
    } else if ([content isKindOfClass:[NSDictionary class]]) {
        [self processLaunchWithOptions:content];
    }
}

#pragma mark - Internal

/**
 Process the application receives a local notification.
 @param notification A local notification
 @discussion When a notificaiton arrives, directly show it as a UIAlert if the app is running in forground, or else execute deep linking.
 */
- (void)processLocalNotification:(UILocalNotification *)notification {
    
    // Display local notification as UIAlert when the app is running in foreground
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSString *title = nil;
        NSString *body = nil;
        if ([notification respondsToSelector:@selector(alertTitle)]) {
            // It's for iOS 8.2+
            title = notification.alertTitle;
            body = notification.alertBody;
        } else {
            body = notification.alertBody;
        }
        
        // Prepare the buttons on Alert view
        NSString *cancelButton = nil;
        NSString *viewButton = nil;
        NSString *messageId = [[PWLPZoneMessageManager sharedManager] parseMessageIdentifier:notification.userInfo];
        if (messageId) {
            // Display 'OK' and 'View' button on the alert view if there is message related
            cancelButton = @"OK";
            viewButton = @"View";
        } else {
            // Or else just display an 'OK' button
            cancelButton = @"OK";
            viewButton = nil;
        }
        
        // Use the customized 'UIAlertView' that it's easy to pass the message ID
        LPUIAlertView *alert = [[LPUIAlertView alloc] initWithTitle:title
                                                            message:body
                                                           delegate:self
                                                  cancelButtonTitle:cancelButton
                                                  otherButtonTitles:viewButton, nil];
        alert.messageId = messageId;
        
        [alert show];
    } else {
        [self processLaunchWithOptions:notification.userInfo];
    }
}

/**
 Process the application launches with a loacl/remote notification.
 @param launchOptions A dictionary
 */
- (void)processLaunchWithOptions:(NSDictionary*)launchOptions {
    // Get message identifier from the userInfo dictionary
    NSString *messageId = [[PWLPZoneMessageManager sharedManager] parseMessageIdentifier:launchOptions];
    
    if (!messageId) {
        // No message to deep link
        return;
    }
    
    // Start to display loading indicator
    [PubUtils showLoading];
    
    [[PWLPZoneMessageManager sharedManager] fetchMessageWithIdentifier:messageId completion:^(PWLPZoneMessage *message, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Stop displaying loading indicator
            [PubUtils dismissLoading];
            
            if (message) {
                // Go to display the specific message in message detail view controller
                [self pushMessageDetailViewControllerWithMessage:message];
            } else if (error) {
                // To do something to handle the error.
                [PubUtils displayError:error];
            }
        });
    }];
}

- (void)pushMessageDetailViewControllerWithMessage:(PWLPZoneMessage*)message {
    // Try to get message detail view controller from story board
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:PWMainStoryBoardName bundle:nil];
    MessageDetailViewController *messageDetailController = [storyboard instantiateViewControllerWithIdentifier:MessageDetailViewControllerIdentifier];
    // Set the message to display in the message detail view controller
    messageDetailController.message = message;
    
    // Find the message list view controller in the tabbar
    UITabBarController *tabBar = (UITabBarController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    NSInteger indexOfController = 0;
    for (UIViewController *controller in tabBar.viewControllers) {
        UIViewController *tabRootController = nil;
        UIViewController *tabVisibleController = nil;
        if ([controller isKindOfClass:[UINavigationController class]]) {
            tabRootController = [(UINavigationController*)controller viewControllers].firstObject;
            tabVisibleController = [(UINavigationController*)controller visibleViewController];
        } else {
            tabRootController = controller;
            tabVisibleController = controller;
        }
        
        // Check every visible view controller to find message list/detail view controller
        if ([tabRootController isKindOfClass:[MessagesTableViewController class]]) {
            if ([tabVisibleController isKindOfClass:[MessageDetailViewController class]]) {
                // It's message detail view controller, it's to reload it with the current message
                tabBar.selectedIndex = indexOfController;
                ((MessageDetailViewController*)tabVisibleController).message = message;
                [tabVisibleController viewDidLoad];
            } else {
                // It's message list view controller, it's to `push` a message detail view controller
                tabBar.selectedIndex = indexOfController;
                [(UINavigationController *)tabBar.selectedViewController pushViewController:messageDetailController animated:YES];
            }
        }
        
        indexOfController ++;
    }
}

#pragma mark - UIAlertViewDelegate & Handle Displayed Alerts

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView isKindOfClass:[LPUIAlertView class]]) {
        // It's only handle the customized 'LPUIAlertView'
        if (buttonIndex == 1) {
            [[PWLPZoneMessageManager sharedManager] fetchMessageWithIdentifier:((LPUIAlertView*)alertView).messageId completion:^(PWLPZoneMessage *message, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (message) {
                        // Show message detail in message detail view controller
                        [self pushMessageDetailViewControllerWithMessage:message];
                    } else if (error) {
                        // Hand the error by youself
                        [PubUtils displayError:error];
                    }
                });
            }];
        }
    }
}

@end
