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

/**
 * API Environment variable type.
 **/
typedef NSString HMEnvironment;

/** Production environment **/
extern HMEnvironment * const HMEnvironmentProduction;
/** Staging environment **/
extern HMEnvironment * const HMEnvironmentStaging;
/** Development environment **/
extern HMEnvironment * const HMEnvironmentDevelopment;

/**
 * Enumeration containing all HTTP methods.
 **/
typedef NS_ENUM(NSUInteger, HMHTTPMethod)
{
    /** Undefined HTTP method **/
    HMHTTPMethodUNDEFINED = 0,
    
    /** HTTP GET method **/
    HMHTTPMethodGET,
    
    /** HTTP POST method **/
    HMHTTPMethodPOST,
    
    /** HTTP PUT method **/
    HMHTTPMethodPUT,
    
    /** HTTP DELETE method **/
    HMHTTPMethodDELETE,
    
    /** HTTP HEAD method **/
    HMHTTPMethodHEAD,
    
    /** HTTP PATCH method **/
    HMHTTPMethodPATCH,
};

/**
 * Use this method to convert from NSSString to HMHTTPMethod.
 **/
HMHTTPMethod HMHTTPMethodFromNSString(NSString *string);

/**
 * Use this method to convert from HMHTTPMethod to NSString.
 **/
NSString* NSStringFromHMHTTPMethod(HMHTTPMethod method);

/**
 * List of HTTP status codes.
 **/
typedef NS_ENUM(NSUInteger, HMHTTPStatusCode)
{
    //
    // 1XX Informational
    //
    // Request received, continuing process.
    //
    // This class of status code indicates a provisional response, consisting only of the Status-Line and optional headers, and
    // is terminated by an empty line. Since HTTP/1.0 did not define any 1xx status codes, servers must not send a 1xx response
    // to an HTTP/1.0 client except under experimental conditions.
    //
    
    HMHTTPStatusCode100Continue              = 100,
    HMHTTPStatusCode101SwitchingProtocols    = 101,
    HMHTTPStatusCode102Processing            = 102,
    
    //
    // 2XX Success
    //
    // This class of status codes indicates the action requested by the client was received, understood, accepted and processed
    // successfully.
    //
    
    HMHTTPStatusCode200Ok                    = 200,
    HMHTTPStatusCode201Created               = 201,
    HMHTTPStatusCode202Accepted              = 202,
    HMHTTPStatusCode203NonAuthoritativeInformation = 203,
    HMHTTPStatusCode204NoContent             = 204,
    HMHTTPStatusCode205ResetContent          = 205,
    HMHTTPStatusCode206PartialContent        = 206,
    HMHTTPStatusCode207MultiStatus           = 207,
    HMHTTPStatusCode208AlreadyReported       = 208,
    HMHTTPStatusCode226IMUsed                = 226,
    
    //
    // 3XX Redirection
    //
    // This class of status code indicates the client must take additional action to complete the request. Many of these status
    // codes are used in URL redirection.
    //
    // A user agent may carry out the additional action with no user interaction only if the method used in the second request
    // is GET or HEAD. A user agent should not automatically redirect a request more than five times, since such redirections
    // usually indicate an infinite loop.
    //
    
    HMHTTPStatusCode300MultipleChoices       = 300,
    HMHTTPStatusCode301MovedPermanently      = 301,
    HMHTTPStatusCode302Found                 = 302,
    HMHTTPStatusCode303SeeOther              = 303,
    HMHTTPStatusCode304NotModified           = 304,
    HMHTTPStatusCode305UseProxy              = 305,
    HMHTTPStatusCode306SwitchProxy           = 306,
    HMHTTPStatusCode307TemporaryRedirect     = 307,
    HMHTTPStatusCode308PermanentRedirect     = 308,
    
    //
    // 4XX Client Error
    //
    // The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a
    // HEAD request, the server should include an entity containing an explanation of the error situation, and whether it is a
    // temporary or permanent condition. These status codes are applicable to any request method. User agents should display any
    // included entity to the user.
    //
    
    HMHTTPStatusCode400BadRequest            = 400,
    HMHTTPStatusCode401Unauthorized          = 401,
    HMHTTPStatusCode402PaymentRequired       = 402,
    HMHTTPStatusCode403Forbidden             = 403,
    HMHTTPStatusCode404NotFound              = 404,
    HMHTTPStatusCode405MethodNotAllowed      = 405,
    HMHTTPStatusCode406NotAcceptable         = 406,
    HMHTTPStatusCode407ProxyAuthenticationRequired = 407,
    HMHTTPStatusCode408RequestTimeout        = 408,
    HMHTTPStatusCode409Conflict              = 409,
    HMHTTPStatusCode410Gone                  = 410,
    HMHTTPStatusCode411LengthRequired        = 411,
    HMHTTPStatusCode412PreconditionFailed    = 412,
    HMHTTPStatusCode413RequestEntityTooLarge = 413,
    HMHTTPStatusCode414RequestURITooLong     = 414,
    HMHTTPStatusCode415UnsupportedMediaType  = 415,
    HMHTTPStatusCode416RequestedRangeNotSatisfiable = 416,
    HMHTTPStatusCode417ExpectationFailed     = 417,
    HMHTTPStatusCode418ImATeapot             = 418,
    HMHTTPStatusCode419AuthenticationTimeout = 419,
    HMHTTPStatusCode420MethodFailure         = 420,
    HMHTTPStatusCode422UnprocessableEntity   = 422,
    HMHTTPStatusCode423Locked                = 423,
    HMHTTPStatusCode424FailedDependency      = 424,
    HMHTTPStatusCode426UpgradeRequired       = 426,
    HMHTTPStatusCode428PreconditionRequired  = 428,
    HMHTTPStatusCode429TooManyRequests       = 429,
    HMHTTPStatusCode431RequestHeaderFieldsTooLarge = 431,
    HMHTTPStatusCode440LoginTimeout          = 440,
    HMHTTPStatusCode444NoResponse            = 444,
    HMHTTPStatusCode449RetryWith             = 449,
    HMHTTPStatusCode450BlockedByWindowsParentalControls = 450,
    HMHTTPStatusCode451UnavailableForLegalReasons = 451,
    HMHTTPStatusCode451Redirect              = 451,
    HMHTTPStatusCode494RequestHeaderTooLarge = 494,
    HMHTTPStatusCode495CertError             = 495,
    HMHTTPStatusCode497HTTPtoHTTPS           = 497,
    HMHTTPStatusCode498TokenExpiredOrInvalid = 498,
    HMHTTPStatusCode499ClientClosedRequest   = 499,
    HMHTTPStatusCode499TokenRequired         = 499,
    
    //
    // 5XX Server Error
    //
    // The server failed to fulfill an apparently valid request.
    //
    // Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has encountered
    // an error or is otherwise incapable of performing the request. Except when responding to a HEAD request, the server should
    // include an entity containing an explanation of the error situation, and indicate whether it is a temporary or permanent
    // condition. Likewise, user agents should display any included entity to the user. These response codes are applicable to any
    // request method.
    //
    
    HMHTTPStatusCode500InternalServerError   = 500,
    HMHTTPStatusCode501NotImplemented        = 501,
    HMHTTPStatusCode502BadGateway            = 502,
    HMHTTPStatusCode503ServiceUnavailable    = 503,
    HMHTTPStatusCode504GatewayTimeout        = 504,
    HMHTTPStatusCode505HTTPVersionNotSupported = 505,
    HMHTTPStatusCode506VariantAlsoNegotiates = 506,
    HMHTTPStatusCode507InsufficientStorage   = 507,
    HMHTTPStatusCode508LoopDetected          = 508,
    HMHTTPStatusCode509BandwidthLimitExceeded = 509,
    HMHTTPStatusCode510NotExtended           = 510,
    HMHTTPStatusCode511NetworkAuthenticationRequired = 511,
    HMHTTPStatusCode598NetworkREadTimeoutError = 598,
    HMHTTPStatusCode599NetworkConnectTimeoutError = 599,
};
