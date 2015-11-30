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
#import "MJApiOAuth.h"
#import "MJApiRequestExecutor.h"

/**
 * The configurator object.
 **/
@interface MJApiOAuthSesionConfigurator : NSObject

/** ************************************************************************************************ **
 * @name Main Attributes
 ** ************************************************************************************************ **/

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

/**
 * YES to use AppToken and UserToken. NO to use only UserToken. Default value is YES.
 **/
@property (nonatomic, assign) BOOL useAppToken;

/** ************************************************************************************************ **
 * @name Token Validation
 ** ************************************************************************************************ **/

/**
 * A time interval offset used when checking if the token is expired: "expiryDate - now < validTokenOffsetTimeInterval". Default value is 60 seconds.
 **/
@property (nonatomic, assign) NSTimeInterval validTokenOffsetTimeInterval;

/**
 * The oauth object configuration.
 **/
@property (nonatomic, strong) MJApiOAuthConfiguration *oauthConfiguration;

@end

typedef NS_ENUM(NSUInteger, MJApiOAuthSesionAccess)
{
    /** The session has no token access. */
    MJApiOAuthSesionAccessNone,
    
    /** The session has only app token access. */
    MJApiOAuthSesionAccessApp,
    
    /** The session has a user token access. */
    MJApiOAuthSesionAccessUser,
};

/**
 * Request executor class using OAuth (user + app tokens).
 **/
@interface MJApiOAuthSession : NSObject <MJApiRequestExecutor>

/** ************************************************************************************************ **
 * @name Initializers
 ** ************************************************************************************************ **/

/**
 * Default initializer.
 * @param configuratorBlock The configurator block.
 * @return The initialized instance.
 **/
- (id)initWithConfigurator:(void (^)(MJApiOAuthSesionConfigurator *configurator))configuratorBlock;

/** ************************************************************************************************ **
 * @name Attributes
 ** ************************************************************************************************ **/

/**
 * The current session access being used.
 **/
@property (nonatomic, assign, readonly) MJApiOAuthSesionAccess sessionAccess;

/**
 * The oauth object representing app access credentials.
 **/
@property (nonatomic, strong, readonly) MJApiOAuth *oauthForAppAccess;

/**
 * The oauth object representing user access credentials.
 **/
@property (nonatomic, strong, readonly) MJApiOAuth *oauthForUserAccess;

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
