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

#import "MJApiConstants.h"

/**
 * A MJApiRequest object contains all the needed information to perform a HTTP request.
 **/
@interface MJApiRequest : NSObject <NSCopying, NSCoding>

/** ************************************************* **
 * @name Initializers
 ** ************************************************* **/

/**
 * Default instance creator. This method creates an API request with the given path.
 * @param format A formated string with the path of the request.
 * @return An initialized instance with the given path.
 */
+ (instancetype)requestWithPath:(NSString*)format, ...;

/** ************************************************* **
 * @name Configuration of the request
 ** ************************************************* **/

/**
 * The HTTP method used for in the URL request. Default value is `HTTPMethodGET`.
 **/
@property (nonatomic, assign) HTTPMethod httpMethod;

/**
 * REST path of the request.
 **/
@property (nonatomic, strong) NSString *path;

/**
 * The dictionary parameters.
 **/
@property (nonatomic, strong) NSDictionary *parameters;

/** ************************************************* **
 * @name Identifying the request
 ** ************************************************* **/

/**
 * Returns a unique hash identifier for the current api request.
 * @discussion This method can be used to get an unique hash string for each configured request.
 **/
- (NSString*)identifier;

/** ************************************************* **
 * @name Debugging
 ** ************************************************* **/

/**
 * This parameter is automatically set by the MJApiClient after creating the corresponding NSURLRequest.
 * @discussion This value can be used to debug the created request.
 **/
@property (nonatomic, strong) NSURLRequest *finalURLRequest;

@end
