//
//  PWProximityZoneManager.h
//  PWLocalpoint
//
//  Created by Alejandro Mendez on 4/28/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PWLocalpoint/PWLPZoneManagerProtocol.h>

/**
 * The proximity manager is in charge of monitoring beacons and informing about beacon related events by posting notifications and sending messages to its delegate.
 */
@interface PWLPProximityZoneManager : NSObject <PWLPZoneManager>

/**
 * The available zones handled by the zone manager.
 * @discussion This zone manager does not handle any zones so the available zones will always be `nil`.
 */
@property (nonatomic, readonly) NSArray *availableZones;

/**
 * The zones currently being monitored by the zone manager.
 * @discussion This zone manager does not handle any zones so the monitored zones will always be `nil`.
 */
@property (nonatomic, readonly) NSArray *monitoredZones;

/**
 * The delegate object that will receive the callbacks defined in the `PWLPZoneManagerDelegate` protocol.
 * @discusssion The delegate for this zone manager will not receive any callbacks from the Location Marketing SDK.
 */
@property (nonatomic, weak) id<PWLPZoneManagerDelegate> delegate;

/**
 * Starts the zone manager.
 */
- (void)start;

/**
 * Stops the zone manager.
 */
- (void)stop;

/**
 * Used to manually indicate the Location Marketing SDK that the device has entered a zone.
 * @discussion Calling this method is needed so that the Location Marketing SDK can handle any marketting campaigns associated with this zone. This method is intended to be used with zones other than geozones, for example, zones that represent beacon regions or NFC regions. PWLPGeozone objects will be ignored, as their entry and exit events are handled internally by the Location Marketing SDK.
 * @param zone The zone that was entered.
 */
- (void)enteredZone:(id<PWLPZone>)zone;

/**
 * Used to manually indicate the Location Marketing SDK that the device has exited a zone.
 * @discussion Calling this method is needed so that the Location Marketing SDK can handle any marketting campaigns associated with this zone. This method is intended to be used with zones other than geozones, for example, zones that represent beacon regions or NFC regions. PWLPGeozone objects will be ignored, as their entry and exit events are handled internally by the Location Marketing SDK.
 * @param zone The zone that was exited.
 */
- (void)exitedZone:(id<PWLPZone>)zone;


@end
