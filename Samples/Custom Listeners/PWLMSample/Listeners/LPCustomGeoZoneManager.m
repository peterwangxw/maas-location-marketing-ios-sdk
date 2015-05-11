//
//  LPCustomGeoZoneManager.m
//  PWLMSample
//
//  Created by Xiangwei Wang on 5/11/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import "LPCustomGeoZoneManager.h"
#import "PubUtils.h"

@interface LPZoneManagerDelegate : NSObject <PWLPZoneManagerDelegate>

@end

@implementation LPZoneManagerDelegate

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didEnterZone:(id<PWLPZone>)zone {
    [PubUtils toast:[NSString stringWithFormat:@"Entered geo zone: [%@]%@", [zone identifier], [zone name]]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didExitZone:(id<PWLPZone>)zone {
    [PubUtils toast:[NSString stringWithFormat:@"Exited geo zone: [%@]%@", [zone identifier], [zone name]]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didAddZones:(NSArray *)zones {
    [PubUtils toast:[NSString stringWithFormat:@"Added %ld geo zones", (unsigned long)zones.count]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didModifyZones:(NSArray *)zones {
    [PubUtils toast:[NSString stringWithFormat:@"Modified %ld geo zones", (unsigned long)zones.count]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didDeleteZones:(NSArray *)zoneIdentifiers {
    [PubUtils toast:[NSString stringWithFormat:@"Modified %ld geo zones", (unsigned long)zoneIdentifiers.count]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager didCheckInForZone:(id<PWLPZone>)zone {
    [PubUtils toast:[NSString stringWithFormat:@"Checkin geo zone: [%@]%@", [zone identifier], [zone name]]];
}

- (void)zoneManager:(id<PWLPZoneManager>)zoneManager failedCheckInForZone:(id<PWLPZone>)zone error:(NSError *)error {
    [PubUtils toast:[NSString stringWithFormat:@"Failed Checkin geo zone: [%@]%@", [zone identifier], [zone name]]];
}

@end


@interface LPCustomGeoZoneManager()

@property (nonatomic) LPZoneManagerDelegate *geoZoneManagerDelegate;

@end

@implementation LPCustomGeoZoneManager

+ (instancetype)sharedManager {
    static LPCustomGeoZoneManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [LPCustomGeoZoneManager new];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _geoZoneManagerDelegate = [LPZoneManagerDelegate new];
        self.delegate = _geoZoneManagerDelegate;
    }
    return self;
}

@end



