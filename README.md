Location Marketing Sample Application for iOS
==================

Version 3.0

This is Phunware's iOS SDK for the Location Marketing module. Visit http://maas.phunware.com/ for more details and to sign up.


Requirements
------------

- iOS 6.0 or greater
- Xcode 5 or greater



Installation
------------

The recommended way to use PWLocalpoint is via [CocoaPods](http://cocoapods.org). Add the following pod to your `Podfile` to use PWLocalpoint:
````
pod 'PWLocalpoint', :git => 'git@github.com:xwang-phunware/maas-location-marketing-ios-sdk.git'
````




Documentation
------------
PWLocalpoint documentation is included in the Documents folder in the repository as both HTML and as a .docset. You can also find the latest documentation here: http://phunware.github.io/maas-location-marketing-ios-sdk/

Here are some resources to help you configure your app for Apple Push Notifications:
- [Apple's documentation](https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Introduction.html)
- [Apple Push Notification services (APNs) Tutorial (1/2)](http://www.raywenderlich.com/32960/apple-push-notification-services-in-ios-6-tutorial-part-1)
- [Apple Push Notification services (APNs) tutorial (2/2)](http://www.raywenderlich.com/32963/apple-push-notification-services-in-ios-6-tutorial-part-2)




Application Setup
-----------------
At the top of your application delegate (.m) file, add the following:

````objective-c
#import <PWLocalpoint/PWLocalpoint.h>
````

Inside your application delegate, you will need to initialize MaaSCore in the application:didFinishLaunchingWithOptions: method. 

````objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // LM Step 1.0(Required):
    // Set a explicit configuration for LM
    [PWLPConfiguration useConfiguration:[PWLPConfiguration defaultConfiguration]];
    
    // LM Step 1.1(Required):
    // Start the standard service
    [PWLocalpoint start];
    // Or start with your custom service
    [PWLocalpoint startWithZoneManagers:@[[LPCustomGeoZoneManager sharedManager]]];
    
    // LM Step 1.2(Required):
    // Notify LM the app finishes launching
    [PWLocalpoint didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}
````

Since PWLocalpoint v3.0, the *application developer* is not responsible with registering for remote notifications with Apple. Apple has three primary methods for handling remote notifications. You will need to implement these in your application delegate, forwarding the results to PWAlerts:

````objective-c
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
````




Custom Local Notification 
--------------

The PWLocalpoint provides the ability to custom the local notification. There is a SDK method that facilitate this: *localpointShouldDisplayLocalNotification:*.

````objective-c
// Custom 'ENTRY' campaign local notification
- (BOOL)localpointShouldDisplayLocalNotification:(PWLPLocalNotification *)notification {
    // Here is an example to customize entry campaign message to add a string 'Welcome. ' at the front of notification title.
    if ([notification.message.campaignType.lowercaseString isEqualToString:PWLPZoneMessageGeofenceEntryCampaignType.lowercaseString]) {
        // Here we only custom the entry campaign
        notification.alertTitle = [LocalNotificationCustomString stringByAppendingString:notification.alertTitle];
    }
    
    // *Important*, this notification will be sent only when it returns 'YES', it will be ingore if it returns 'NO'.
    return YES;
}
````


Attributes Management 
--------------

The PWLocalpoint provides the ability to manager customer's profile attributes. There are some SDK methods in `PWLPAttributeManager` that facilitate this: 
- *fetchProfileAttributeMetadataWithCompletion:*
- *fetchProfileAttributesWithCompletion:*
- *updateProfileAttributes: completion:*



Custom Indentifier Management 
--------------

The PWLocalpoint provides the ability to manager customer identifier. There are some SDK methods in `PWLPAttributeManager` that facilitate this: 
- *fetchCustomIdentifierWithCompletion:*
- *updateCustomIdentifier: completion:*



Listen Zone Events 
--------------

The PWLocalpoint provides two ways to let customer listen the zone events: 
- Start LM service with a custom Geo-Zone manager
    1. Create your own [Geo-Zone manager](https://github.com/xwang-phunware/maas-location-marketing-ios-sdk/blob/master/Samples/Custom%20Listeners/PWLMSample/Listeners/LPCustomGeoZoneManager.m) which extends `PWLPGeoZoneManager` and specifies the own Geo-Zone manager delegate.
    2. Start LM service with it. 
````objective-c
[PWLocalpoint startWithZoneManagers:@[[LPCustomGeoZoneManager sharedManager]]];
````
- Register to listen their notifications


