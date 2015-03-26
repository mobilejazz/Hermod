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
#import "MJApiUploadRequest.h"
#import "MJApiResponse.h"
#import "MJApiRequestGroup.h"

#define LOG_REQUESTS (1 && DEBUG)

typedef NS_OPTIONS(NSUInteger, MJApiClientLogLevel)
{
    MJApiClientLogLevelNone         = 0,
    MJApiClientLogLevelRequests     = 1 << 0,
    MJApiClientLogLevelResponses    = 1 << 1,
};

typedef void (^MJApiResponseBlock)(MJApiResponse *response, NSInteger key);

@protocol MJApiClientDelegate;

/**
 * An API client.
 * This class build on top of AFNetworking a user-friendly interface to manage API requests and responses. 
 * The only constraint is that the backend services must always accept and return application/json HTTP requests and responses.
 **/
@interface MJApiClient : NSObject

/** ************************************************************************************************ **
 * @name Getting the default manager
 ** ************************************************************************************************ **/

/**
 * Default initializer.
 * @param host The host.
 * @return An initialized instance.
 **/
- (id)initWithHost:(NSString*)host;

/** ************************************************************************************************ **
 * @name Configuring the client
 ** ************************************************************************************************ **/

/**
 * The host of the API client.
 **/
@property (nonatomic, strong, readonly) NSString *host;

/**
 * An aditional API route path to be inserted after the host and before the REST arguments.
 **/
@property (nonatomic, strong) NSString *apiPath;

/** ************************************************************************************************ **
 * @name Authorization Headers
 ** ************************************************************************************************ **/

/**
 * Set a barear token (typically from OAuth access tokens).
 * @param The authorization token.
 **/
- (void)setBearerToken:(NSString*)token;

/**
 * Set a basic authorization setup.
 * @param username The username.
 * @param password The password.
 **/
- (void)setBasicAuthWithUsername:(NSString*)username password:(NSString*)password;

/**
 * Clears all authorization headers.
 **/
- (void)removeAuthorizationHeaders;

/** ************************************************************************************************ **
 * @name Delegate
 ** ************************************************************************************************ **/

/**
 * Delegate object.
 **/
@property (nonatomic, weak) id <MJApiClientDelegate> delegate;

/** ************************************************************************************************ **
 * @name Managing Requests
 ** ************************************************************************************************ **/

/**
 * Performs an API request and call the completion block when finish.
 * @param request The API request.
 * @param completionBlock A completion block.
 * @return The task identifier.
 **/
- (NSInteger)performRequest:(MJApiRequest*)request completionBlock:(MJApiResponseBlock)completionBlock;

/**
 * Performs an API request and call the completion block when finish.
 * @param request The API request.
 * @param apiPath A custom API path (to be used instead of the default one).
 * @param completionBlock A completion block.
 * @return The task identifier.
 **/
- (NSInteger)performRequest:(MJApiRequest*)request apiPath:(NSString*)apiPath completionBlock:(MJApiResponseBlock)completionBlock;

/**
 * Cancel the request for the given identifier.
 * @param identifier The request identifier.
 **/
- (void)cancelRequestWithIdentifier:(NSInteger)identifier;

/**
 * Suspends the request for the given identifier.
 * @param identifier The request identifier.
 **/
- (void)suspendRequestWithIdentifier:(NSInteger)identifier;

/**
 * Resumes the request for the given identifier.
 * @param identifier The request identifier.
 **/
- (void)resumeRequestWithIdentifier:(NSInteger)identifier;

/**
 * Cancels all requests.
 **/
- (void)cancelAllRequests;

/**
 * Suspends all requests.
 **/
- (void)suspendAllRequests;

/**
 * Resumes all supspended requests.
 **/
- (void)resumeAllRequests;

/** ************************************************************************************************ **
 * @name Logging
 ** ************************************************************************************************ **/

/**
 * The log level of the api client. Default value is `MJApiClientLogLevelNone`.
 **/
@property (nonatomic, assign) MJApiClientLogLevel logLevel;

@end


/**
 * Delegate of an API client.
 **/
@protocol MJApiClientDelegate <NSObject>

@optional
- (NSError*)apiClient:(MJApiClient*)apiClient errorForResponseBody:(NSDictionary*)responseBody incomingError:(NSError*)error;

@end



