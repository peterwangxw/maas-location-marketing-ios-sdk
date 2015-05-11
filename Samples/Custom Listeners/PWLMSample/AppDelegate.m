//
//  AppDelegate.m
//  PWLPSample
//
//  Created by Xiangwei Wang on 1/26/15.
//  Copyright (c) 2015 Phunware, Inc. All rights reserved.
//

#import "AppDelegate.h"

// Listeners
#import "LPCustomGeoZoneManager.h"
#import "LPCustomProximityZoneManager.h"
#import "LPMessageListener.h"
// #import "LPZoneEventListener.h"
// Commons
#import "PubUtils.h"

@implementation AppDelegate {
    __strong LPMessageListener *messageListener;
    //__strong LPZoneEventListener *zoneEventListener;
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
    // zoneEventListener = [LPZoneEventListener new];
    // [zoneEventListener startListening];
    
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

@end
