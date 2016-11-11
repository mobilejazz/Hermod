//
// Copyright 2015 Mobile Jazz SL
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

#import "HMConstants.h"

/**
 * An object that includes the definition of an API.
 **/
@interface HMConfiguration : NSObject

/**
 * @property The host. For example: www.mydomain.com
 **/
@property (nonatomic, strong) NSString *host;

/**
 * @property The scheme. For example: https
 **/
@property (nonatomic, strong) NSString *scheme;

/**
 * @property The port. For example: 80
 **/
@property (nonatomic, assign) NSInteger port;

/**
 * @property The API path. For example: api/v1
 **/
@property (nonatomic, strong) NSString *path;

/**
 * @property Additional information.
 **/
@property (nonatomic, strong) NSDictionary *apiInfo;

/**
 * Returns the "scheme://host:port" string.
 **/
- (NSString *)serverPath;

/**
 * Returns the "scheme://host:port/path" string.
 **/
- (NSString *)apiPath;

@end

/**
 * API Configuration from PLIST file.
 *
 * - The PLIST must contain a dictionary as root object.
 * - Root object must contain dictionaries. Use "development", "staging" and "production" as default environment keys. Other environment keys might be used as well.
 * - Each environment dictionary must contain a string entry keyed by "host".
 * - Optionally add keys for "scheme", "port" and "path", otherwise default values will be used.
 * - Finally, add other keys that will be listed in the `apiInfo` property of `HMEnvironment`.
 *
 **/
@interface HMConfigurationManager : NSObject

/**
 * Default initializer. 
 * @param fileName The fileName of the PLIST.
 * @return An initialized instance.
 **/
- (id)initWithPlistFileName:(NSString *)fileName;

/**
 * @property The file name of the PLIST.
 **/
@property (nonatomic, strong, readonly) NSString *fileName;

/**
 * Returns the API configuration instance for the given environment.
 *
 *  - Use `HMEnvironmentStaging` for key "staging"
 *  - Use `HMEnvironmentProduction` for key "production"
 *  - Use `HMEnvironmentDevelopment` for key "development"
 *  - Use custom keys to get custom specified environments.
 **/
- (HMConfiguration *)configurationForEnvironment:(HMEnvironment *)environment;

@end
