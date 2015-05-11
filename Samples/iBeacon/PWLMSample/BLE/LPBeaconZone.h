//
//  LPBeaconZone.h
//  PWLocalpoint
//
//  Created by Xiangwei Wang on 4/7/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import <PWLocalpoint/PWLocalpoint.h>

// Geofence and iBeacon prefix
static NSString * const kPWLPGeofenceIdentifierPrefix = @"PWLP";
static NSString * const kPWLPBLERegionIdentifierPrefix = @"PWLP_BLE";

@import Foundation;
@import CoreLocation;

@interface LPBeaconZone : NSObject<PWLPZone>

/**
 * The identifier of the zone. (read-only)
 * @discussion When working with zone objects, determine equality by comparing their identifier instead of performing pointer-level comparisons.
 */
@property (nonatomic, readonly) NSString *identifier;
/**
 * The name given to the geozone object. (read-only)
 */
@property (nonatomic, readonly) NSString *name;

/**
 * The code assigned to the zone object. (read-only)
 */
@property (nonatomic, readonly) NSString *code;

/**
 * The description assigned to the zone object. (read-only)
 */
@property (nonatomic, readonly) NSString *zoneDescription;

/**
 * A flag that indicates if a check-in can be performed in the zone. (read-only)
 */
@property (nonatomic, readonly) BOOL canCheckIn;

/**
 * A flag that indicates if the user is currently inside the zone. (read-only)
 */
@property (nonatomic, readonly) BOOL inside;

/**
 * A set of tags associated to the zone. (read-only)
 */
@property (nonatomic, readonly) NSSet *tags;

/**
 * The parent of geofence identifier. (read-only)
 */
@property (nonatomic, readonly) NSString *outreachIdentifier;

/**
 * A beacon region. (read-only)
 */
@property (nonatomic, readonly) CLBeaconRegion *beaconRegion;

/**
 * The proximity value associates with this beacon region. (read-only)
 */
@property (nonatomic, readonly) NSInteger proximity;

/**
 * Initialize a `LPBeaconZone` object
 */
- (instancetype)initWithIdentifier:(NSString*)identifier name:(NSString*)name
                              code:(NSString*)code
                   zoneDescription:(NSString*)zoneDescription
                        canCheckIn:(BOOL)canCheckIn
                            inside:(BOOL)inside
                              tags:(NSSet*)tags
                outreachIdentifier:(NSString*)outreachIdentifier
                         proximity:(NSInteger)proximity
                        beaconUUID:(NSString*)uuid
                       beaconMajor:(CLBeaconMajorValue)major
                       beaconMinor:(CLBeaconMinorValue)minor;

/**
 * Initialize a `LPBeaconZone` object
 */
- (instancetype)initWithIdentifier:(NSString*)identifier
                              name:(NSString*)name
                outreachIdentifier:(NSString*)outreachIdentifier
                         proximity:(NSInteger)proximity
                        beaconUUID:(NSString*)uuid
                       beaconMajor:(CLBeaconMajorValue)major
                       beaconMinor:(CLBeaconMinorValue)minor;


+ (instancetype)unpack:(NSDictionary *)dictionary;

@end

/*
 {
 "name": "name goes here",
 "geofenceId": 123,
 "outreachGeofenceId": 456,
 "beacon": {
 "uuid": "36548401-C4CD-49EF-202A-35E5B135801C",
 "major": 15152,
 "minor": 59636
 }
 }
 */