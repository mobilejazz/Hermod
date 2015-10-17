//
//  MJApiRequestExecutor.h
//  ApiClient
//
//  Created by Joan Martin on 17/10/15.
//  Copyright © 2015 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MJApiResponse;
@class MJApiRequest;

typedef void (^MJApiResponseBlock)(MJApiResponse *response);

/**
 * The main request executor interface.
 **/
@protocol MJApiRequestExecutor <NSObject>

/** ************************************************* **
 * @name Managing Requests
 ** ************************************************* **/

/**
 * Performs an API request and call the completion block when finish.
 * @param request The API request.
 * @param completionBlock A completion block.
 * @return The task identifier.
 **/
- (void)performRequest:(MJApiRequest*)request completionBlock:(MJApiResponseBlock)completionBlock;

/**
 * Performs an API request and call the completion block when finish.
 * @param request The API request.
 * @param apiPath A custom API path (to be used instead of the default one).
 * @param completionBlock A completion block.
 * @return The task identifier.
 **/
- (void)performRequest:(MJApiRequest*)request apiPath:(NSString*)apiPath completionBlock:(MJApiResponseBlock)completionBlock;

@end
