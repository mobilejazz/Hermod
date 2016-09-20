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
#import "MJApiRequestExecutor.h"
#import "MJApiConfigurationManager.h"

/**
 * Cache managmenet flags.
 **/
typedef NS_ENUM(NSInteger, MJApiClientCacheManagement)
{
    /** Default cache management. */
    MJApiClientCacheManagementDefault,
    
    /** When offline (no reachability to the internet), cache will be used. */
    MJApiClientCacheManagementOffline
};

/**
 * Debug logs flags.
 **/
typedef NS_OPTIONS(NSUInteger, MJApiClientLogLevel)
{
    /** No logs will be done. */
    MJApiClientLogLevelNone         = 0,
    
    /** Requests will be logged (including a curl). */
    MJApiClientLogLevelRequests     = 1 << 0,
    
    /** Responses will be logged. */
    MJApiClientLogLevelResponses    = 1 << 1,
};

typedef NS_OPTIONS(NSUInteger, MJApiClientRequestSerializerType)
{
    /** applicaiton/JSON */
    MJApiClientRequestSerializerTypeJSON = 0,

    /** applicaiton/x-www-form-urlencoded with utf8 charset */
    MJApiClientRequestSerializerTypeFormUrlencoded = 1,
};

typedef NS_OPTIONS(NSUInteger, MJApiClientResponseSerializerType)
{
    /** JSON responses */
    MJApiClientResponseSerializerTypeJSON = 0,
    
    /** RAW responses */
    MJApiClientResponseSerializerTypeRaw = 1,
};

@protocol MJApiClientDelegate;

/* ************************************************************************************************** */
#pragma mark -

/**
 * The configurator object.
 **/
@interface MJApiClientConfigurator : NSObject

/**
 * Automatic API Configuration.
 **/
- (void)configureWithConfiguration:(MJApiConfiguration * _Nonnull)configuration;

/** ************************************************* **
 * @name Configurable properties
 ** ************************************************* **/

/**
 * The host of the API client. Default value is nil.
 **/
@property (nonatomic, strong, readwrite, nonnull) NSString *serverPath;

/**
 * An aditional API route path to be inserted after the host and before the REST arguments. Default value is nil.
 * @discussion Must be prefixed with "/"
 **/
@property (nonatomic, strong, readwrite, nullable) NSString *apiPath;

/**
 * The cache managemenet strategy. Default value is `MJApiClientCacheManagementDefault`.
 **/
@property (nonatomic, assign, readwrite) MJApiClientCacheManagement cacheManagement;

/**
 * The request serializer type. Default value is `MJApiClientRequestSerializerTypeJSON`.
 **/
@property (nonatomic, assign, readwrite) MJApiClientRequestSerializerType requestSerializerType;

/**
 * The response serializer type. Default value is `MJApiClientResponseSerializerTypeJSON`.
 **/
@property (nonatomic, assign, readwrite) MJApiClientResponseSerializerType responseSerializerType;

/**
 * The request timeout interval. Default value is 60 seconds.
 **/
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 * Requests completion block will be executed on the given queue.
 * @discussion If nil, blocks will be executed on the main queue.
 **/
@property (nonatomic, strong, readwrite, nullable) dispatch_queue_t completionBlockQueue;

@end

/* ************************************************************************************************** */
#pragma mark -

/**
 * An API client.
 * This class build on top of AFNetworking a user-friendly interface to manage API requests and responses. 
 * The only constraint is that the backend services must always accept and return application/json HTTP requests and responses.
 **/
@interface MJApiClient : NSObject <MJApiRequestExecutor>

/** ************************************************* **
 * @name Getting the default manager
 ** ************************************************* **/

/**
 * Deprecated initializer.
 * @param serverPath The serverPath. For example: https://www.mydomain.com
 * @param apiPath Additiona API route. For example: /api/v2
 * @return An initialized instance.
 **/
- (instancetype _Nonnull)initWithServerPath:(NSString * _Nonnull)serverPath apiPath:(NSString * _Nullable)apiPath;

/**
 *  Designated initializer.
 *  @param configuratorBlock A MJApiClientConfigurator block
 *  @return The instance initialized
 */
- (instancetype _Nonnull)initWithConfigurator:(void (^_Nonnull)(MJApiClientConfigurator * _Nonnull configurator))configuratorBlock;

/** ************************************************* **
 * @name Configuring the client
 ** ************************************************* **/

/**
 * The server path of the API client.
 **/
@property (nonatomic, strong, readonly, nonnull) NSString *serverPath;

/**
 * An aditional API route path to be inserted after the host and before the REST arguments.
 * @discussion Must be prefixed with "/"
 **/
@property (nonatomic, strong, readonly, nullable) NSString *apiPath;

/**
 * The cache managemenet strategy.
 **/
@property (nonatomic, assign, readonly) MJApiClientCacheManagement cacheManagement;

/**
 * Requests completion block will be executed on the given queue.
 * @discussion If nil, blocks will be executed on the main queue.
 **/
@property (nonatomic, strong, readonly, nullable) dispatch_queue_t completionBlockQueue;

/** ************************************************* **
 * @name Authorization Headers
 ** ************************************************* **/

/**
 * Set a barear token (typically from OAuth access tokens). Replaces the basic authentication header.
 * @param The authorization token.
 * @discussion If nil, this method will remove the bearer token header.
 **/
- (void)setBearerToken:(NSString * _Nullable)token;

/**
 * Set a basic authorization setup. Replaces the bearer token header.
 * @param username The username.
 * @param password The password.
 * @discussion If username or password are nil (or both are nil), this method will remove the basic authentication header.
 **/
- (void)setBasicAuthWithUsername:(NSString * _Nonnull)username password:(NSString * _Nonnull)password;

/**
 * Clears all authorization headers.
 **/
- (void)removeAuthorizationHeaders;

/** ************************************************* **
 * @name HTTP Headers
 ** ************************************************* **/

/**
 * Dictionary containing additional HTTP header parameters. Default is nil.
 **/
@property (nonatomic, strong, nullable) NSDictionary *headerParameters;

/** ************************************************* **
 * @name Localization
 ** ************************************************* **/

/**
 * If YES, automatically configures the Accept-Language HTTP header to the current device language. Default value is YES.
 **/
@property (nonatomic, assign) BOOL insertAcceptLanguageHeader;

/**
 * If YES, it will insert a language parameter inside all body requests. Default value is NO.
 **/
@property (nonatomic, assign) BOOL insertLanguageAsParameter;

/**
 * The name of the body request language parameter. Default value is "language".
 **/
@property (nonatomic, strong, nonnull) NSString *languageParameterName;

/** ************************************************* **
 * @name Requests
 ** ************************************************* **/

/**
 * A dictionary of parameters that are going to be added to all requests. Default is nil.
 * @discussion Global parameters are added before sending the URL request. If duplicated parameter keys, the values in this dictionary will be the final ones.
 **/
@property (nonatomic, strong, nullable) NSDictionary *requestGlobalParameters;

/** ************************************************* **
 * @name Delegate
 ** ************************************************* **/

/**
 * Delegate object.
 **/
@property (nonatomic, weak, nullable) id <MJApiClientDelegate> delegate;

/** ************************************************* **
 * @name Logging
 ** ************************************************* **/

/**
 * The log level of the api client. Default value is `MJApiClientLogLevelNone`.
 **/
@property (nonatomic, assign) MJApiClientLogLevel logLevel;

@end

/* ************************************************************************************************** */
#pragma mark -

/**
 * Delegate of an API client.
 **/
@protocol MJApiClientDelegate <NSObject>

/** ************************************************* **
 * @name Managing errors
 ** ************************************************* **/

@optional
/**
 * By implementing this method, the delegate thas the oportunity to create custom errors depending on the incoming response body or the incoming error.
 * @param apiClient The API client.
 * @param responseBody The response body (can be nil).
 * @param httpResponse The HTTP URL Response.
 * @param error The incoming error (can be nil).
 * @discussion This method is called for every succeed and failed API response. Either the response body is not nil, the error is not nil or both are not nil.
 **/
- (NSError * _Nullable)apiClient:(MJApiClient * _Nonnull)apiClient errorForResponseBody:(id _Nullable)responseBody httpResponse:(NSHTTPURLResponse * _Nonnull)httpResponse incomingError:(NSError * _Nullable)error;

/**
 * Notifies the delegate that an api response has got an error.
 * @param apiClient The API client.
 * @param response The API response with an error.
 **/
- (void)apiClient:(MJApiClient * _Nonnull)apiClient didReceiveErrorInResponse:(MJApiResponse * _Nonnull)response;

@end
