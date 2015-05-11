//
//  LPCustomGeoZoneManager.h
//  PWLMSample
//
//  Created by Xiangwei Wang on 5/11/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PWLocalpoint/PWLocalpoint.h>

/**
 This manager is in charge of monitoring geozones and informing about geozone related events by posting notifications and sending messages to its delegate.
 */
@interface LPCustomGeoZoneManager : PWLPGeoZoneManager

+ (instancetype)sharedManager;

@end
