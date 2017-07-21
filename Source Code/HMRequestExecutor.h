//
//  HMRequestExecutor.h
//  ApiClient
//
//  Created by Joan Martin on 17/10/15.
//  Copyright © 2015 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMResponse;
@class HMRequest;

typedef void (^HMResponseBlock)(HMResponse *response);

/**
 * The main request executor interface.
 **/
@protocol HMRequestExecutor <NSObject>

/** ************************************************* **
 * @name Managing Requests
 ** ************************************************* **/

/**
 * Performs an API request and call the completion block when finish.
 * @param request The API request.
 * @param completionBlock A completion block.
 **/
- (void)performRequest:(HMRequest*)request completionBlock:(HMResponseBlock)completionBlock;

/**
 * Performs an API request and call the completion block when finish.
 * @param request The API request.
 * @param apiPath A custom API path (to be used instead of the default one).
 * @param completionBlock A completion block.
 **/
- (void)performRequest:(HMRequest*)request apiPath:(NSString*)apiPath completionBlock:(HMResponseBlock)completionBlock;

@end
