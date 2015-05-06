//
//  PWBeaconManager.h
//  Localpoint
//
//  Created by Illya Busigin on 1/28/15.
//
//

@import Foundation;
#import "LPBeaconZone.h"

extern NSString * const kPWBeaconManagerDidEnterRegionNotification;
extern NSString * const kPWBeaconManagerDidExitRegionNotification;
extern NSString * const kPWBeacon;
extern NSString * const kPWRegion;

@interface LPBeaconManager : NSObject

@property (nonatomic, strong) NSArray *localBeacons;

+ (instancetype)sharedManager;

- (void)startMonitorBeaconsInGeofence:(NSString*)outreachGeofenceId;

- (void)stopMonitorBeaconsInGeofence:(NSString*)outreachGeofenceId;

@end