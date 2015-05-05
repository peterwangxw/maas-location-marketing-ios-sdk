//
//  AppInfoViewController.m
//  PWLPSample
//
//  Created by Xiangwei Wang on 1/26/15.
//  Copyright (c) 2015 Phunware, Inc. All rights reserved.
//

#import <PWLocalpoint/PWLocalpoint.h>

#import "AppInfoViewController.h"

static NSString *const MaxMonitorRegionRadius = @"50,000";

@implementation AppInfoViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Device
    self.deviceID.text = [PWLPDevice sharedInstance].identifier;
    self.deviceOS.text = [[UIDevice currentDevice] systemVersion];
    
    // SDK
    PWLPConfiguration *cfg = [PWLPConfiguration defaultConfiguration];
    self.brand.text = cfg.brand;
    self.appId.text = cfg.identifier;
    self.server.text = cfg.environment;
    self.sdkVersion.text = [PWLPVersion version];
    self.searchRadius.text = MaxMonitorRegionRadius;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
