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




Application Setup (Required)
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
    // LM Step 3.0(Required):
    // Notify LM the app fail to register for remote notification
    [PWLocalpoint didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // LM Step 4.0(Required):
    // Notify LM the app receives a remote notificaiton
    [PWLocalpoint didReceiveRemoteNotification:userInfo];
}
````



Localpoint Delegete *PWLocalpointDelegate* (Optional)
--------------

The PWLocalpoint gives the chance to respond to important changes and custom local notification:

- Register *PWLocalpointDelegate* protocol in your `AppDelegate.h`

````objective-c
#import <UIKit/UIKit.h>
#import <PWLocalpoint/PWLocalpoint.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PWLocalpointDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
````

- Custom Local Notification via *localpointShouldDisplayLocalNotification*

````objective-c
// Custom 'ENTRY' campaign local notification
- (BOOL)localpointShouldDisplayLocalNotification:(PWLPLocalNotification *)notification {
    // Here is an example to customize entry campaign message to add a string 'Welcome. ' at the front of notification title.
    if ([notification.message.campaignType.lowercaseString isEqualToString:PWLPZoneMessageGeofenceEntryCampaignType.lowercaseString]) {
        // Here we only custom the entry campaign
        notification.alertTitle = [@"Welcome. " stringByAppendingString:notification.alertTitle];
    }
    
    // *Important*, this notification will be sent only when it returns 'YES', it will be ingore if it returns 'NO'.
    return YES;
}
````

- Listen SDK status changes via *localpointFailedToStartWithError*

````objective-c
// Custom 'ENTRY' campaign local notification
- (void)localpointFailedToStartWithError:(NSError *)error {
    NSLog(@"Start Localpoint SDK with error: %@", error);
}
````


Custom Zone Managers (Optional)
--------------

The PWLocalpoint provides the ability to custom zone managers. Here is a example of custom PWLPGeoZoneManager:
- Create your own custom manager [LPCustomGeoZoneManager.h](https://github.com/xwang-phunware/maas-location-marketing-ios-sdk/blob/master/Samples/Custom%20Listeners/PWLMSample/Listeners/LPCustomGeoZoneManager.h) / [LPCustomGeoZoneManager.m](https://github.com/xwang-phunware/maas-location-marketing-ios-sdk/blob/master/Samples/Custom%20Listeners/PWLMSample/Listeners/LPCustomGeoZoneManager.m)

- Start Localpoint with your custom manager: 
````objective-c
[PWLocalpoint startWithZoneManagers:@[[LPCustomGeoZoneManager sharedManager]]];
````

- So it's getting easy to access the geofence zones by the following methods:
````objective-c
// Get available geozones
[PWLocalpoint sharedManager].availableZones;
// Get zones currently being monitored
[PWLocalpoint sharedManager].monitoredZones;
````

- And the delegate methods in your custom zone manager will be notified properly:
````objective-c
@implementation LPZoneManagerDelegate

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didEnterZone:(id<PWLPZone>)zone {
    
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didExitZone:(id<PWLPZone>)zone {
    
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didAddZones:(NSArray *)zones {
    
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didModifyZones:(NSArray *)zones {
    
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didDeleteZones:(NSArray *)zoneIdentifiers {
    
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didCheckInForZone:(id<PWLPZone>)zone {
    
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager failedCheckInForZone:(id<PWLPZone>)zone error:(NSError *)error {
    
}

@end
````




Attributes Management (Optional)
--------------

The PWLocalpoint provides the ability to manager customer's profile attributes. There are some SDK methods in `PWLPAttributeManager` that facilitate this: 
- *fetchProfileAttributeMetadataWithCompletion:*  <!-- Fetch all attribute metadata -->
- *fetchProfileAttributesWithCompletion:*  <!-- Fetch assicated attributes for the device -->
- *updateProfileAttributes: completion:*  <!-- Update attributes for the assicated device -->



Custom Indentifier Management (Optional) 
--------------

The PWLocalpoint provides the ability to manager customer identifier. There are some SDK methods in `PWLPAttributeManager` that facilitate this: 
- *fetchCustomIdentifierWithCompletion:*  <!-- Fetch assicated custom identifier -->
- *updateCustomIdentifier: completion:*  <!-- Update custom identifier -->



Alternative Listen Zone Events (Optional) 
--------------

The PWLocalpoint posts the corresponding notification once enter a zone, exit a zone or zone changes, app developer can register to receive zone notifications, and here is an example class [LPZoneEventListener.h](https://github.com/xwang-phunware/maas-location-marketing-ios-sdk/blob/master/Samples/Custom%20Listeners/PWLMSample/Listeners/LPZoneEventListener.h) / [LPZoneEventListener.m](https://github.com/xwang-phunware/maas-location-marketing-ios-sdk/blob/master/Samples/Custom%20Listeners/PWLMSample/Listeners/LPZoneEventListener.m) 



Listen Message Events (Optional) 
--------------

The PWLocalpoint posts the corresponding notification once message received or modified, app developer can register to receive zone notifications, and here is an example class, and here is an example class [LPMessageListener.h](https://github.com/xwang-phunware/maas-location-marketing-ios-sdk/blob/master/Samples/Custom%20Listeners/PWLMSample/Listeners/LPMessageListener.h) / [LPMessageListener.m](https://github.com/xwang-phunware/maas-location-marketing-ios-sdk/blob/master/Samples/Custom%20Listeners/PWLMSample/Listeners/LPMessageListener.m) 

