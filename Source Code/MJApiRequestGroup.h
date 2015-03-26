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

@class MJApiClient;

/**
 * A request group allows the developer to group performed requests and then cancel, suspend or resume the tasks.
 * Typically, this class is created to assign one instance to each `UIViewController` and add to the group all requests created on the view controller. Then, when the view controller disappears, appears or is deallocated, the group can suspend, resume or cancel all grouped requests.
 **/
@interface MJApiRequestGroup : NSObject

/** ********************************************************************************* **
 * @name Initializers
 ** ********************************************************************************* **/

/**
 * Default initializer.
 * @param apiClient The api client.
 * @return An initialized instance.
 **/
- (id)initWithApiClient:(MJApiClient*)apiClient;

/** ********************************************************************************* **
 * @name Attributes
 ** ********************************************************************************* **/

/**
 * The api client.
 **/
@property (nonatomic, strong) MJApiClient *apiClient;

/** ********************************************************************************* **
 * @name Managing requests
 ** ********************************************************************************* **/

/**
 * Add a new request for the given identifier.
 * @param key The key of a performed api request.
 **/
- (void)addPerformedRequestWithKey:(NSInteger)key;

/**
 * Cancel all requests in the group.
 **/
- (void)cancel;

/**
 * Suspend all requests in the group.
 **/
- (void)suspend;

/**
 * Resume all suspended all requests in the group.
 **/
- (void)resume;

@end
