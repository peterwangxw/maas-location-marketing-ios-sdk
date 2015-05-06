//
//  PWBeacon.h
//  Localpoint
//
//  Created by Illya Busigin on 1/28/15.
//
//

#import <PWLocalpoint/PWLocalpoint.h>

@import Foundation;
@import CoreLocation;

@interface LPBeaconZone : NSObject<PWLPZone>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *outreachIdentifier;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic) NSInteger proximity;

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