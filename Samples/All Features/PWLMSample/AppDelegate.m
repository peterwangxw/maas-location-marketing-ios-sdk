//
//  AppDelegate.m
//  PWLPSample
//
//  Created by Xiangwei Wang on 1/26/15.
//  Copyright (c) 2015 Phunware, Inc. All rights reserved.
//

#import "AppDelegate.h"

// Messages
#import "MessagesManager.h"
#import "MessagesTableViewController.h"
#import "MessageDetailViewController.h"
// Listeners
#import "LPMessageListener.h"
#import "LPZoneEventListener.h"
#import "LPCustomGeoZoneManager.h"
#import "LPCustomProximityZoneManager.h"
// Commons
#import "LPUIAlertView.h"
#import "PubUtils.h"

// Identifiers
static NSString *const PWMainStoryBoardName = @"Main";
static NSString *const MessageDetailViewControllerIdentifier = @"MessageDetailViewController";
static NSString *const MessagesTableViewControllerIdentifier = @"MessagesTableViewController";

@implementation AppDelegate {
    __strong LPMessageListener *messageListener;
    __strong LPZoneEventListener *zoneEventListener;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // LM Step 1.0(Required):
    // Set a explicit configuration for LM
    [PWLPConfiguration useConfiguration:[PWLPConfiguration defaultConfiguration]];
    
    // LM Step 1.1(Required):
    // Start the service
    [PWLocalpoint startWithZoneManagers:@[[LPCustomGeoZoneManager sharedManager],
                                          [LPCustomProximityZoneManager sharedManager]]];
    
    // LM Step 1.2(Required):
    // Notify LM the app finishes launching
    [PWLocalpoint didFinishLaunchingWithOptions:launchOptions];
    
    // LM Step 1.3(Optional):
    // Start listen message events
    messageListener = [LPMessageListener new];
    [messageListener startListening];
    
    // LM Step 1.4(Optional):
    // Start listen zone events
    // If you custom `PWLPGeoZoneManager` and specified your own delegate at step 1.1, it's no need to listen the events any more.
    zoneEventListener = [LPZoneEventListener new];
    [zoneEventListener startListening];
    
    // LM Step 1.5.0(Optional):
    // Handle message deep link
    [self handleMessageDeepLink:launchOptions];
    
    // LM Step 1.6(Optional):
    // Refresh badge on app icon and tabbar
    [[MessagesManager sharedManager] refreshBadgeCounter];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // LM Step 2.0(Required):
    // Notify LM the app succeed to register for remote notification
    [PWLocalpoint didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    // LM Step 2.1(Optional):
    // Check push notification settings and remind user if it's disabled
    [self checkNotificationSetting];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // LM Step 3.2(Required):
    // Notify LM the app fail to register for remote notification
    [PWLocalpoint didFailToRegisterForRemoteNotificationsWithError:error];
    
    // LM Step 3.1(Optional):
    // Check push notification settings and remind user if it's disabled
    [self checkNotificationSetting];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // LM Step 4.0(Required):
    // Notify LM the app receives a remote notificaiton
    [PWLocalpoint didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // LM Step 5.0(Optional):
    // Display local notification as UIAlert when the app is running in foreground
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
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
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

#pragma mark - UIAlertViewDelegate & Handle Displayed Alerts

// LM Step 5.1(Optional):
// Handle the local notification by youself
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

#pragma mark - PWLocalpointDelegate & Custom Local Notification

// LM Step 6.0(Optional):
- (BOOL)localpointShouldDisplayLocalNotification:(PWLPLocalNotification *)notification {
    // Sample 1: custom entry local notification
    // Here is an example to customize ENTRY local notification to add the prefix 'Welcome. '
    if ([notification.message.campaignType isEqualToString:PWLPZoneMessageGeofenceEntryCampaignType]) {
        notification.alertTitle = [NSString stringWithFormat:NSLocalizedString(@"CustomLocalNotificationPrefix", @"Notification prefix"),notification.alertTitle];
    }
    
    // Sample 2: stop sending any local notification if push notification is disabled
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        if ([UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone) {
            return NO;
        }
    }
    
    // Return 'YES' to send this notification, the application:didReceiveLocalNotification: is about to be called
    // Return 'NO' to ingore this local notification, the application:didReceiveLocalNotification: won't be called
    return YES;
}

#pragma mark - Message Deep Linking

// LM Step 1.5.1(Optional): Message Deep Linking
// Check if there is deep link message identifier in the user info
- (void)handleMessageDeepLink:(NSDictionary*)userInfo {
    // Get message identifier from the userInfo dictionary
    NSString *messageId = [[PWLPZoneMessageManager sharedManager] parseMessageIdentifier:userInfo];
    
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

// LM Step 1.5.2(Optional): Message Deep Linking
// Find the message detail view controller and display message detail
- (void)pushMessageDetailViewControllerWithMessage:(PWLPZoneMessage*)message {
    // Try to get message detail view controller from story board
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:PWMainStoryBoardName bundle:nil];
    MessageDetailViewController *messageDetailController = [storyboard instantiateViewControllerWithIdentifier:MessageDetailViewControllerIdentifier];
    // Set the message to display in the message detail view controller
    messageDetailController.message = message;
    
    // Find the message list view controller in the tabbar
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
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

#pragma mark - Private

// LM Step 2.3(Optional):
// Warning user when notification setting is disabled
- (void)checkNotificationSetting {
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        if ([UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone) {
            [PubUtils displayWarning:NSLocalizedString(@"RemindOfEnablePushNotificationSettings", @"Remind to enable pusn notification")];
        }
    }
}

@end
