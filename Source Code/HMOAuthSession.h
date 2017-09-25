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

#import "HMClient.h"
#import "HMOAuth.h"
#import "HMRequestExecutor.h"

/**
 * The configurator object.
 **/
@interface HMOAuthSesionConfigurator : NSObject

/** ************************************************************************************************ **
 * @name Main Attributes
 ** ************************************************************************************************ **/

/**
 * The API client.
 **/
@property (nonatomic, strong) HMClient *apiClient;

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
@property (nonatomic, strong) HMOAuthConfiguration *oauthConfiguration;

@end

@protocol HMOAuthSessionDelegate;

typedef NS_ENUM(NSUInteger, HMOAuthSesionAccess)
{
    /** The session has no token access. */
    HMOAuthSesionAccessNone,
    
    /** The session has only app token access. */
    HMOAuthSesionAccessApp,
    
    /** The session has a user token access. */
    HMOAuthSesionAccessUser,
};

/**
 * Request executor class using OAuth (user + app tokens).
 **/
@interface HMOAuthSession : NSObject <HMRequestExecutor>

/** ************************************************************************************************ **
 * @name Initializers
 ** ************************************************************************************************ **/

/**
 * Default initializer.
 * @param configuratorBlock The configurator block.
 * @return The initialized instance.
 **/
- (id)initWithConfigurator:(void (^)(HMOAuthSesionConfigurator *configurator))configuratorBlock;

/** ************************************************************************************************ **
 * @name Attributes
 ** ************************************************************************************************ **/

/**
 * The current session access being used.
 **/
@property (nonatomic, assign, readonly) HMOAuthSesionAccess sessionAccess;

/**
 * The oauth object representing app access credentials.
 **/
@property (nonatomic, strong, readonly) HMOAuth *oauthForAppAccess;

/**
 * The oauth object representing user access credentials.
 **/
@property (nonatomic, strong, readonly) HMOAuth *oauthForUserAccess;

/**
 * The managed API client.
 **/
@property (nonatomic, strong, readonly) HMClient *apiClient;

/** ************************************************************************************************ **
 * @name Methods
 ** ************************************************************************************************ **/

/**
 * Performs a block ensuring the validity of the session access tokens.
 * @discussion If a oauth object is about to expire or expired, the session will attepmt to refresh credentials before calling the block.
 **/
- (void)validateOAuth:(void (^)(void))completionBlock;

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

/**
 * Manually configures an oauth for the given session access.
 * @param oauth The oauth token to configure.
 * @param sessionAccess The session access level for the given oauth.
 **/
- (void)configureWithOAuth:(HMOAuth*)oauth forSessionAccess:(HMOAuthSesionAccess)sessionAccess;

/** ************************************************************************************************ **
 * @name Delegates
 ** ************************************************************************************************ **/

@property (nonatomic, weak) id <HMOAuthSessionDelegate> delegate;

@end


/**
 * Delegate object.
 **/
@protocol HMOAuthSessionDelegate <NSObject>

@optional
/**
 * When obtaining and configuring a new oauth token, this method will be called.
 * @param session The session object.
 * @param oauth The oauth token.
 * @param sessionAccess The oauth token session access level.
 **/
- (void)session:(HMOAuthSession*)session didConfigureOAuth:(HMOAuth*)oauth forSessionAccess:(HMOAuthSesionAccess)sessionAccess;

@end
