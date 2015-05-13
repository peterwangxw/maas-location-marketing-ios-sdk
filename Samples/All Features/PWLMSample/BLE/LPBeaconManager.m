//
//  LPBeaconManager.m
//  PWLocalpoint
//
//  Created by Xiangwei Wang on 4/7/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PWLocalpoint/PWLocalpoint.h>
#import "LPBeaconManager.h"
#import "PubUtils.h"

@import CoreLocation;

#pragma mark - Constant Strings

// iBeacon data JSON file
/* If you beacon mapping file is in remote, please set kPWLPiBeaconRemoteUrl and set both file name(kPWLPiBeaconRemoteUrl) and file type(kPWLPiBeaconLocalFileType) to nil */
static NSString * const kPWLPiBeaconRemoteUrl = @"https://dl.dropboxusercontent.com/u/117922424/beacons.json";
/* If your beacon mapping file is in local, please set file name(kPWLPiBeaconRemoteUrl) and file type(kPWLPiBeaconLocalFileType) and set kPWLPiBeaconRemoteUrl to `nil` */
static NSString * const kPWLPiBeaconLocalFileName = @"beacons";
static NSString * const kPWLPiBeaconLocalFileType = @"json";

// User defauts keys
static NSString * const PWSavedBeaconDataKey = @"PWSavedBeaconDataKey";
static NSString * const PWSavedBeaconDataDateKey = @"PWSavedBeaconDataDateKey";

// iBeacon constants
static NSTimeInterval const PWFetchBeaconInterval = 60 * 60 * 24; // 1 day
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [LPBeaconManager sharedManager];
    });
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _operationQueue = [NSOperationQueue new];
        _operationQueue.name = @"com.phunware.lm.ble-download-queue";
        
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if (kPWLPiBeaconRemoteUrl) {
            [self loadBeaconsFromURL:kPWLPiBeaconRemoteUrl];
        } else {
            [self loadLocalBeaconsFromFile];
        }
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
            id<PWLPZone> zone = [self getLPBeaconZoneByBeaconRegionId:region.identifier];
            [self.proximityZoneManager enteredZone:zone];
            
        } else if (beacon.proximity == CLProximityUnknown) {
            // Exit
            id<PWLPZone> zone = [self getLPBeaconZoneByBeaconRegionId:region.identifier];
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
        // Start detecting if bluetooth is enabled
        
        // Delay monitoring regions so internal localpoint SDK can do it's thing
        if (self.locationManager.monitoredRegions.count + beaconRegionsToMonitor.count >= 20) {
            NSInteger delta = 20 - (weakSelf.locationManager.monitoredRegions.count + beaconRegionsToMonitor.count);
            
            // Determine outside regions
            NSMutableArray *outsideRegions = [NSMutableArray array];
            
            for (CLRegion *region in weakSelf.locationManager.monitoredRegions) {
                if ([region isKindOfClass:[CLCircularRegion class]] && [region.identifier hasPrefix:kPWLPGeofenceIdentifierPrefix]) {
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

- (LPBeaconZone*) getLPBeaconZoneByBeaconRegionId:(NSString*)beaconRegionId {
    NSArray *array = [beaconRegionId componentsSeparatedByString:kPWLPBLERegionIdentifierPrefix];
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
    if (!kPWLPiBeaconLocalFileName || kPWLPiBeaconLocalFileName.length == 0) {
        return;
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:kPWLPiBeaconLocalFileName ofType:kPWLPiBeaconLocalFileType];
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

- (void)loadBeaconsFromURL:(NSString*)beaconURLString {
    if (!beaconURLString || beaconURLString.length == 0) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:beaconURLString];
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
        LPBeaconZone *beaconZone = [LPBeaconZone unpack:beaconObject];
        
        if (beaconZone) {
            [beacons addObject:beaconZone];
        }
    }
    
    return beacons;
}

@end
