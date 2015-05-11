//
//  LPCustomProximityZoneManager.m
//  PWLMSample
//
//  Created by Xiangwei Wang on 5/11/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import "LPCustomProximityZoneManager.h"
#import "PubUtils.h"

@interface LPProximityZoneManagerDelegate : NSObject <PWLPZoneManagerDelegate>

@end

@implementation LPProximityZoneManagerDelegate

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didEnterZone:(id<PWLPZone>)zone {
    [PubUtils toast:[NSString stringWithFormat:@"Entered proximity zone: [%@]%@", [zone identifier], [zone name]]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didExitZone:(id<PWLPZone>)zone {
    [PubUtils toast:[NSString stringWithFormat:@"Exited proximity zone: [%@]%@", [zone identifier], [zone name]]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didAddZones:(NSArray *)zones {
    [PubUtils toast:[NSString stringWithFormat:@"Added %ld proximity zones", (unsigned long)zones.count]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didModifyZones:(NSArray *)zones {
    [PubUtils toast:[NSString stringWithFormat:@"Modified %ld proximity zones", (unsigned long)zones.count]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didDeleteZones:(NSArray *)zoneIdentifiers {
    [PubUtils toast:[NSString stringWithFormat:@"Modified %ld proximity zones", (unsigned long)zoneIdentifiers.count]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didCheckInForZone:(id<PWLPZone>)zone {
    [PubUtils toast:[NSString stringWithFormat:@"Checkin proximity zone: [%@]%@", [zone identifier], [zone name]]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager failedCheckInForZone:(id<PWLPZone>)zone error:(NSError *)error {
    [PubUtils toast:[NSString stringWithFormat:@"Failed Checkin proximity zone: [%@]%@", [zone identifier], [zone name]]];
}

@end


@interface LPCustomProximityZoneManager()

@property (nonatomic) LPProximityZoneManagerDelegate *geoZoneManagerDelegate;

@end

@implementation LPCustomProximityZoneManager

+ (instancetype)sharedManager {
    static LPCustomProximityZoneManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [LPCustomProximityZoneManager new];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _geoZoneManagerDelegate = [LPProximityZoneManagerDelegate new];
        self.delegate = _geoZoneManagerDelegate;
    }
    return self;
}

@end
