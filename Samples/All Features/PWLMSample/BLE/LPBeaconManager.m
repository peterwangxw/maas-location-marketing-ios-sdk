//
//  LPBeaconManager.m
//  Localpoint
//
//  Created by Illya Busigin on 1/28/15.
//
//

#import <PWLocalpoint/PWLocalpoint.h>
#import "LPBeaconManager.h"

@import CoreLocation;

// Constant Strings
NSString * const kPWGeofenceIdentifierPrefix = @"LP";
NSString * const kPWRegionIdentifierPrefix = @"LP_BLE_";
NSString * const PWSavedBeaconDataKey = @"PWSavedBeaconDataKey";
NSString * const PWSavedBeaconDataDateKey = @"PWSavedBeaconDataDateKey";
NSTimeInterval const PWFetchBeaconInterval = 60 * 60 * 24; // 1 day

static int maxRequestInterval = 900;
static NSDate *lastSendTime = nil;

@interface LPBeaconManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) PWLPProximityZoneManager *proximityZoneManager;

@end

@implementation LPBeaconManager

#pragma mark - NSObject

+ (void)load {
    // Instantiate the singleton
    [LPBeaconManager sharedManager];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _operationQueue = [NSOperationQueue new];
        _operationQueue.name = @"com.phunware.lp.ble-download-queue";
        
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([_locationManager respondsToSelector:NSSelectorFromString(@"requestAlwaysAuthorization")]) {
            [_locationManager performSelector:NSSelectorFromString(@"requestAlwaysAuthorization") withObject:nil afterDelay:0];
        }
        
#warning Replace this string with the proper URL!
        /**
        NSString *beaconURLString = @"https://www.digbypoc.com/Customers/AE/ae_beacons.json";
        [self loadBeaconsFromURL:[NSURL URLWithString:beaconURLString]];
         **/
        [self loadLocalBeaconsFromFile];
    }
    
    return self;
}

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static LPBeaconManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [LPBeaconManager new];
    });
    
    return sharedManager;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    LPBeaconZone *pwBeacon = [self covertRegionToPWBeacon:region];
    if (!pwBeacon)
        return;
    
    for (CLBeacon *beacon in beacons) {
        if (beacon.proximity == pwBeacon.proximity) {
            if (lastSendTime) {
                if (fabs([lastSendTime timeIntervalSinceNow]) < maxRequestInterval)
                    return;
            }
            lastSendTime = [NSDate date];
            
            // Entry
            id<PWLPZone> zone = [self parseBLERegionId:region.identifier];
            [self.proximityZoneManager enteredZone:zone];
            
        } else if (beacon.proximity == CLProximityUnknown) {
            // Exit
            id<PWLPZone> zone = [self parseBLERegionId:region.identifier];
            [self.proximityZoneManager exitedZone:zone];
            [self.locationManager stopRangingBeaconsInRegion:region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

#pragma mark - Public

- (void)startMonitorBeaconsInGeofence:(NSString*)outreachGeofenceId {
    NSArray *clBeacons = [self getBeaconsInGeofence:outreachGeofenceId];
    
    if (clBeacons && clBeacons.count > 0) {
        [self startMonitoringRegions:clBeacons delay:1];
    }
}

- (void)stopMonitorBeaconsInGeofence:(NSString*)outreachGeofenceId {
    NSArray *clBeacons = [self getBeaconsInGeofence:outreachGeofenceId];
    
    if (clBeacons && clBeacons.count > 0) {
        for (CLBeaconRegion *beacon in clBeacons) {
            [self.locationManager stopMonitoringForRegion:beacon];
        }
    }
}

#pragma mark - Internal

- (NSArray*)getBeaconsInGeofence:(NSString*)outreachGeofenceId {
    NSMutableArray *clBeacons = [NSMutableArray new];
    for (LPBeaconZone *pwBeacon in self.localBeacons) {
        if ([pwBeacon.outreachIdentifier isEqualToString:outreachGeofenceId]) {
            [clBeacons addObject:pwBeacon.beaconRegion];
        }
    }
    return clBeacons;
}

- (LPBeaconZone*)covertRegionToPWBeacon:(CLBeaconRegion*)region {
    for (LPBeaconZone *pwBeacon in self.localBeacons) {
        if ([pwBeacon.beaconRegion isEqual:region]) {
            return pwBeacon;
        }
    }
    
    return nil;
}

- (void)startMonitoringRegions:(NSArray *)beaconRegionsToMonitor delay:(NSTimeInterval)delay {
    __weak __typeof(self)weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Delay monitoring regions so internal localpoint SDK can do it's thing
        if (self.locationManager.monitoredRegions.count + beaconRegionsToMonitor.count >= 20) {
            NSInteger delta = 20 - (weakSelf.locationManager.monitoredRegions.count + beaconRegionsToMonitor.count);
            
            // Determine outside regions
            NSMutableArray *outsideRegions = [NSMutableArray array];
            
            for (CLRegion *region in weakSelf.locationManager.monitoredRegions) {
                if ([region isKindOfClass:[CLCircularRegion class]] && [region.identifier hasPrefix:kPWGeofenceIdentifierPrefix]) {
                    if (![(CLCircularRegion*)region containsCoordinate:weakSelf.locationManager.location.coordinate]) {
                        [outsideRegions addObject:region];
                    }
                }
            }
            
            if (outsideRegions.count >= delta) {
                while (delta > 0) {
                    [weakSelf.locationManager stopMonitoringForRegion:[outsideRegions lastObject]];
                    delta--;
                }
            } else {
                // Remove all outside regions
                for (CLRegion *region in outsideRegions) {
                    [weakSelf.locationManager stopMonitoringForRegion:region];
                    
                    delta--;
                }
                
                // TO DO: Trim out delta# regions (which ones ?)
            }
        }
        
        if (beaconRegionsToMonitor.count > 0) {
            [weakSelf monitorBeacons:beaconRegionsToMonitor];
        }
    });
}

- (void)monitorBeacons:(NSArray *)beacons {
    // Register for region monitoring
    for (CLBeaconRegion *beacon in beacons) {
        [self.locationManager startMonitoringForRegion:beacon];
    }
}

- (LPBeaconZone*) parseBLERegionId:(NSString*)regionId {
    NSArray *array = [regionId componentsSeparatedByString:kPWRegionIdentifierPrefix];
    if (array.count == 2) {
        NSString *identifier = [array objectAtIndex:1];
        
        for (LPBeaconZone *zone in self.localBeacons) {
            if ([zone.identifier isEqualToString:identifier]) {
                return zone;
            }
        }
    }
    
    return nil;
}

#pragma mark - Beacons

- (void)loadLocalBeaconsFromFile {

    NSString *path = [[NSBundle mainBundle] pathForResource:@"beacons" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSError *error = nil;
    NSArray *beaconObjects = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"Error loading beacons.json!");
    } else {
        NSArray *beacons = [self loadBeaconsFromObjectArray:beaconObjects];
        
        self.localBeacons = beacons;
    }
}

- (void)loadBeaconsFromURL:(NSURL *)url {
    if (!url) {
        [self loadLocalBeaconsFromFile];
        return;
    }
    
    // Check the last time beacon information was downloaded
    NSDate *lastDownloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:PWSavedBeaconDataDateKey];
    
    if ([lastDownloadDate timeIntervalSinceNow] > PWFetchBeaconInterval && lastDownloadDate != nil) {
        // The file we have is still good
        [self loadBeaconsFromUserDefaultsOrFile];
        return;
    }

    __weak __typeof(self)weakSelf = self;
    
    // Build the request
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    // Send the request and default to a local file if an error occurs
    [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            [weakSelf loadBeaconsFromUserDefaultsOrFile];
        } else {
            NSError *error = nil;
            NSArray *beaconObjects = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (error) {
                [weakSelf loadBeaconsFromUserDefaultsOrFile];
            } else {
                NSArray *beacons = [self loadBeaconsFromObjectArray:beaconObjects];
                weakSelf.localBeacons = beacons;
                
                // Save the beacons the NSUserDefaults
                [[NSUserDefaults standardUserDefaults] setObject:beaconObjects.copy forKey:PWSavedBeaconDataKey];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:PWSavedBeaconDataDateKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }];
}

- (void)loadBeaconsFromUserDefaultsOrFile {
    NSArray *savedBeacons = [[NSUserDefaults standardUserDefaults] objectForKey:PWSavedBeaconDataKey];
    
    if (savedBeacons) {
        NSArray *beacons = [self loadBeaconsFromObjectArray:savedBeacons];
        self.localBeacons = beacons;
    } else {
        [self loadLocalBeaconsFromFile];
    }
}

- (NSArray *)loadBeaconsFromObjectArray:(NSArray *)beaconObjects {
    NSMutableArray *beacons = [NSMutableArray array];
    
    for (NSDictionary *beaconObject in beaconObjects) {
        LPBeaconZone *beacon = [LPBeaconZone new];
        beacon.name = beaconObject[@"name"];
        beacon.identifier = beaconObject[@"geofenceId"];
        beacon.outreachIdentifier = beaconObject[@"outreachGeofenceId"];
        beacon.proximity = [beaconObject[@"proximity"] integerValue];
        
        NSDictionary *beaconData = beaconObject[@"beacon"];
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconData[@"uuid"]];
        
        if (!uuid) {
            NSLog(@"Error unpacking UUID! -> %@", beaconData[@"uuid"]);
            continue;
        }
        
        beacon.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                      major:[beaconData[@"major"] integerValue]
                                                                      minor:[beaconData[@"minor"] integerValue]
                                                                 identifier:beacon.identifier];
        [beacons addObject:beacon];
    }
    
    return beacons;
}

@end
