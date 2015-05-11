//
//  LPBeaconZone.m
//  PWLocalpoint
//
//  Created by Xiangwei Wang on 4/7/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import "LPBeaconZone.h"

// iBeacon data JSON keys
static NSString * const kPWLPiBeaconIdentifierJSONKey = @"beaconId";
static NSString * const kPWLPiBeaconNameJSONKey = @"name";
static NSString * const kPWLPiBeaconOutreachGeofenceIdJSONKey = @"outreachGeofenceId";
static NSString * const kPWLPiBeaconProximityJSONKey = @"proximity";
static NSString * const kPWLPiBeaconBeaconJSONKey = @"beacon";
static NSString * const kPWLPiBeaconBeaconUUIDJSONKey = @"uuid";
static NSString * const kPWLPiBeaconBeaconMajorJSONKey = @"major";
static NSString * const kPWLPiBeaconBeaconMinorJSONKey = @"minor";

@implementation LPBeaconZone

- (instancetype)initWithIdentifier:(NSString*)identifier name:(NSString*)name code:(NSString*)code zoneDescription:(NSString*)zoneDescription canCheckIn:(BOOL)canCheckIn inside:(BOOL)inside tags:(NSSet*)tags outreachIdentifier:(NSString*)outreachIdentifier proximity:(NSInteger)proximity beaconUUID:(NSString*)uuid beaconMajor:(CLBeaconMajorValue)major beaconMinor:(CLBeaconMinorValue)minor {
    
    self = [super init];
    if(self) {
        NSUUID *mUUID = [[NSUUID alloc] initWithUUIDString:uuid];
        if (!mUUID) {
            return nil;
        }
        
        _identifier = [identifier copy];
        _name = [name copy];
        _code = [code copy];
        _zoneDescription = [zoneDescription copy];
        _canCheckIn = canCheckIn;
        _inside = inside;
        _tags = [tags copy];
        _outreachIdentifier = outreachIdentifier;
        _proximity = proximity;
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:mUUID
                                                                major:major
                                                                minor:minor
                                                           identifier:[kPWLPBLERegionIdentifierPrefix stringByAppendingString:_identifier]];
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString*)identifier name:(NSString*)name outreachIdentifier:(NSString*)outreachIdentifier proximity:(NSInteger)proximity beaconUUID:(NSString*)uuid beaconMajor:(CLBeaconMajorValue)major beaconMinor:(CLBeaconMinorValue)minor {
    
    self = [self initWithIdentifier:identifier
                               name:name
                               code:nil
                    zoneDescription:nil
                         canCheckIn:NO
                             inside:NO
                               tags:nil
                 outreachIdentifier:outreachIdentifier
                          proximity:proximity
                         beaconUUID:uuid
                        beaconMajor:major
                        beaconMinor:minor];
    return self;
}

#pragma mark - Packing

+ (instancetype)unpack:(NSDictionary *)dictionary
{
    LPBeaconZone *beaconZone = nil;
    BOOL error = NO;
    
    NSString *identifier, *name, *outreachIdentifier, *uuid;
    NSInteger proximity, major, minor;
    
    @try {
        if ([dictionary[kPWLPiBeaconIdentifierJSONKey] isKindOfClass:[NSString class]]) {
            identifier = dictionary[kPWLPiBeaconIdentifierJSONKey];
        }
        if ([dictionary[kPWLPiBeaconNameJSONKey] isKindOfClass:[NSString class]]) {
            name = dictionary[kPWLPiBeaconNameJSONKey];
        }
        if ([dictionary[kPWLPiBeaconOutreachGeofenceIdJSONKey] isKindOfClass:[NSString class]]) {
            outreachIdentifier = dictionary[kPWLPiBeaconOutreachGeofenceIdJSONKey];
        }
        if ([dictionary[kPWLPiBeaconProximityJSONKey] isKindOfClass:[NSNumber class]]) {
            proximity = [dictionary[kPWLPiBeaconProximityJSONKey] integerValue];
        }
        if ([dictionary[kPWLPiBeaconBeaconJSONKey][kPWLPiBeaconBeaconUUIDJSONKey] isKindOfClass:[NSString class]]) {
            uuid = dictionary[kPWLPiBeaconBeaconJSONKey][kPWLPiBeaconBeaconUUIDJSONKey];
        }
        if ([dictionary[kPWLPiBeaconBeaconJSONKey][kPWLPiBeaconBeaconMajorJSONKey] isKindOfClass:[NSNumber class]]) {
            major = [dictionary[kPWLPiBeaconBeaconJSONKey][kPWLPiBeaconBeaconMajorJSONKey] integerValue];
        }
        if ([dictionary[kPWLPiBeaconBeaconJSONKey][kPWLPiBeaconBeaconMinorJSONKey] isKindOfClass:[NSNumber class]]) {
            minor = [dictionary[kPWLPiBeaconBeaconJSONKey][kPWLPiBeaconBeaconMinorJSONKey] integerValue];
        }
    }
    @catch (NSException *exception) {
        error = YES;
    }
    
    if (!error) {
        beaconZone = [[LPBeaconZone alloc] initWithIdentifier:identifier name:name outreachIdentifier:outreachIdentifier proximity:proximity beaconUUID:uuid beaconMajor:major beaconMinor:minor];
    }
    
    return beaconZone;
}

- (void)checkIn {
    
}

@end


