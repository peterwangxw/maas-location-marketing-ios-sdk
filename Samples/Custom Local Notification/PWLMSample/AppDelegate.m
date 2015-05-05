//
//  AppDelegate.m
//  PWLPSample
//
//  Created by Xiangwei Wang on 1/26/15.
//  Copyright (c) 2015 Phunware, Inc. All rights reserved.
//

#import "AppDelegate.h"

// Commons
#import "SampleDefines.h"
#import "LPUIAlertView.h"

@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // LM Step 1.0(Required):
    // Set a explicit configuration for LM
    [PWLPConfiguration useConfiguration:[PWLPConfiguration defaultConfiguration]];
    
    // LM Step 1.1(Required):
    // Start the service
    [PWLocalpoint start];
    
    // LM Step 1.2(Required):
    // Notify LM the app finishes launching
    [PWLocalpoint didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // LM Step 2.0(Required):
    // Notify LM the app succeed to register for remote notification
    [PWLocalpoint didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // LM Step 3.2(Required):
    // Notify LM the app fail to register for remote notification
    [PWLocalpoint didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // LM Step 4.0(Required):
    // Notify LM the app receives a remote notificaiton
    [PWLocalpoint didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // LM Step 5.0(Optional):
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
            cancelButton = AlertOKButtonName;
            viewButton = AlertViewButtonName;
        } else {
            // Or else just display an 'OK' button
            cancelButton = AlertOKButtonName;
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

@end
