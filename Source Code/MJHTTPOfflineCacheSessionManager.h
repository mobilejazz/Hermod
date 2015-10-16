//
//  MJHTTPSessionManager.h
//  ApiClient
//
//  Created by Paolo Tagliani on 07/08/15.
//  Copyright (c) 2015 Mobile Jazz. All rights reserved.
//

#import "AFHTTPSessionManager.h"

/**
 *  This session manager basically ovverride the GET method and add
 *  support for offline caching and server side cache
 */

@interface MJHTTPOfflineCacheSessionManager : AFHTTPSessionManager

/**
 *  Creates the default shared operation manager
 *
 *  @return the shared operation manager
 */
+ (instancetype)sharedOperationManager;

/**
 *  Creates an operation manager
 *
 *  @return an operation manager
 */
- (instancetype)init;

@end
