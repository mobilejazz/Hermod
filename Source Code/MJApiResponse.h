//
// Copyright 2014 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import "MJApiRequest.h"

/**
 * A MJApiResponse object contains the HTTP response from the server.
 **/
@interface MJApiResponse : NSObject

/** ************************************************* **
 * @name Initializers
 ** ************************************************* **/

/**
 * Initializer for error responses.
 * @param request The original request.
 * @param response The HTTP headers response.
 * @param error The error.
 * @return An initialized instance.
 * @discussion The only class that creates api responses is the `MJApiClient`. A developer will never have to create it.
 **/
- (id)initWithRequest:(MJApiRequest*)request httpResponse:(NSHTTPURLResponse*)response error:(NSError*)error;

/**
 * Initializer for succeed responses.
 * @param request The original request.
 * @param response The HTTP headers response.
 * @param responseObject The response object.
 * @return An initialized instance.
 * @discussion The only class that creates api responses is the `MJApiClient`. A developer will never have to create it.
 **/
- (id)initWithRequest:(MJApiRequest*)request httpResponse:(NSHTTPURLResponse*)response responseObject:(id)responseObject;

/** ************************************************* **
 * @name Attributes
 ** ************************************************* **/

/**
 * The original request.
 **/
@property (nonatomic, strong) MJApiRequest *request;

/**
 * The error if something went wrong.
 **/
@property (nonatomic, strong) NSError *error;

/**
 * The http headers response.
 **/
@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;

/**
 * The body response object.
 **/
@property (nonatomic, strong) id responseObject;

@end


