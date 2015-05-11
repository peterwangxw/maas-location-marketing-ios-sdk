//
//  LPBeaconManager.h
//  PWLocalpoint
//
//  Created by Xiangwei Wang on 4/7/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import "LPBeaconZone.h"

@import Foundation;

@interface LPBeaconManager : NSObject

/**
 * The beacons need to be monitored
 */
@property (nonatomic, strong) NSArray *localBeacons;

/**
 * A shared instance of `LPBeaconManager`
 */
+ (instancetype)sharedManager;


/**
 * Start monitoring the beacons associated with a geofence location
 * @param outreachGeofenceId The geofence indentifier in which the beacons needs to start monitoring
 */
- (void)startMonitorBeaconsInGeofence:(NSString*)outreachGeofenceId;


/**
 * Stop monitoring the beacons associated with a geofence location
 * @param outreachGeofenceId The geofence indentifier in which the beacons needs to stop monitory
 */
- (void)stopMonitorBeaconsInGeofence:(NSString*)outreachGeofenceId;

@end