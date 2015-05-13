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
#import "MessageDeepLinkHandler.h"
#import "MessagesTableViewController.h"
#import "MessageDetailViewController.h"
// Listeners
#import "LPMessageListener.h"
#import "LPZoneEventListener.h"
#import "LPCustomGeoZoneManager.h"
#import "LPCustomProximityZoneManager.h"
// Commons
#import "PubUtils.h"

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
    [[MessageDeepLinkHandler new] process:launchOptions];
    
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
    // LM Step 3.0(Required):
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
    // Display local notification as UIAlert when the app is running in foreground or deep linking
    [[MessageDeepLinkHandler new] process:notification];
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

- (void)localpointFailedToStartWithError:(NSError *)error {
    NSLog(@"Start Localpoint SDK with error: %@", error);
}

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
