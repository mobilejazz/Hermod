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

#import "MJApiClient.h"
#import "MJApiSessionOAuth.h"
#import "MJApiRequestExecutor.h"

/**
 * This class collects all the information related to configuring an API client together wit the API session management.
 **/
@interface MJApiSessionConfiguration : NSObject

/**
 * The API client.
 **/
- (MJApiClient*)apiClient;

/**
 * The API path for OAuth requests.
 **/
- (NSString*)apiOAuthPath;

/**
 * The client id to be used inside the OAuth.
 **/
- (NSString*)clientId;

/**
 * The client secret to be used inside the OAuth.
 **/
- (NSString*)clientSecret;

@end

/**
 * The configurator object.
 **/
@interface MJApiSessionConfigurator : NSObject

/**
 * The API client.
 **/
@property (nonatomic, strong) MJApiClient *apiClient;

/**
 * The API path for OAuth requests. For example: "/api/v1/oauth/token".
 **/
@property (nonatomic, copy) NSString *apiOAuthPath;

/**
 * The client id to be used inside the OAuth.
 **/
@property (nonatomic, copy) NSString *clientId;

/**
 * The client secret to be used inside the OAuth.
 **/
@property (nonatomic, copy) NSString *clientSecret;

@end

typedef NS_ENUM(NSUInteger, MJApiSessionAccess)
{
    /** The session has no token access. */
    MJApiSessionAccessNone,
    
    /** The session has only app token access. */
    MJApiSessionAccessApp,
    
    /** The session has a user token access. */
    MJApiSessionAccessUser,
};

/**
 * This class manages the OAuth session of an API client (MJApiClient).
 **/
@interface MJApiSession : NSObject <MJApiRequestExecutor>

/** ************************************************************************************************ **
 * @name Initializers
 ** ************************************************************************************************ **/

/**
 * Default initializer.
 * @param configuratorBlock The configurator block.
 * @return The initialized instance.
 **/
- (id)initWithConfigurator:(void (^)(MJApiSessionConfigurator *configurator))configuratorBlock;

/** ************************************************************************************************ **
 * @name Attributes
 ** ************************************************************************************************ **/

/**
 * The current session access being used.
 **/
@property (nonatomic, assign, readonly) MJApiSessionAccess sessionAccess;

/**
 * The oauth object representing app access credentials.
 **/
@property (nonatomic, strong, readonly) MJApiSessionOAuth *oauthForAppAccess;

/**
 * The oauth object representing user access credentials.
 **/
@property (nonatomic, strong, readonly) MJApiSessionOAuth *oauthForUserAccess;

/**
 * The managed API client.
 **/
@property (nonatomic, strong, readonly) MJApiClient *apiClient;

/** ************************************************************************************************ **
 * @name Methods
 ** ************************************************************************************************ **/

/**
 * Performs a block ensuring the validity of the session access tokens.
 * @discussion If a oauth object is about to expire or expired, the session will attepmt to refresh credentials before calling the block.
 **/
- (void)validateOAuth:(void (^)())completionBlock;

/**
 * Deletes the user and app token.
 **/
- (void)logout;

/**
 * Perform a login via plain authentication.
 * @param username The username.
 * @param password The password.
 * @param completionBlock The completion block.
 * @discussion After calling this method with a successfull login, the session configures itself.
 **/
- (void)loginWithUsername:(NSString*)username password:(NSString*)password completionBlock:(void (^)(NSError *error))completionBlock;

@end
