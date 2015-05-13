//
//  MessageDeepLinkHandler.h
//  PWLMSample
//
//  Created by Xiangwei Wang on 5/13/15.
//  Copyright (c) 2015 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageDeepLinkHandler : NSObject <UIAlertViewDelegate>

/**
 Message deep linking processor
 @param content A launch option dictionary or loacal notification
 @discussion This method will directly open the message detail view controller if the parameter is launch option dictionary. If it's local notification, to  check application state first, present a UIAlert to let use choose if it's in foreground, or else go to message detail view controller.
 */
- (void)process:(id)content;

@end
