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
 * Enumeration containing all HTTP methods.
 **/
typedef NS_ENUM(NSUInteger, HTTPMethod)
{
    /** Undefined HTTP method **/
    HTTPMethodUNDEFINED = 0,
    
    /** HTTP GET method **/
    HTTPMethodGET,
    
    /** HTTP POST method **/
    HTTPMethodPOST,
    
    /** HTTP PUT method **/
    HTTPMethodPUT,
    
    /** HTTP DELETE method **/
    HTTPMethodDELETE,
    
    /** HTTP HEAD method **/
    HTTPMethodHEAD,
    
    /** HTTP PATCH method **/
    HTTPMethodPATCH,
};

/**
 * Use this method to convert from NSSString to HTTPMethod.
 **/
HTTPMethod HTTPMethodPairFromNSString(NSString *string);

/**
 * Use this method to convert from HTTPMethod to NSString.
 **/
NSString* NSStringFromHTTPMethod(HTTPMethod method);

/**
 * List of HTTP status codes.
 **/
typedef NS_ENUM(NSUInteger, HTTPStatusCode)
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
    
    HTTPStatusCode100Continue              = 100,
    HTTPStatusCode101SwitchingProtocols    = 101,
    HTTPStatusCode102Processing            = 102,
    
    //
    // 2XX Success
    //
    // This class of status codes indicates the action requested by the client was received, understood, accepted and processed
    // successfully.
    //
    
    HTTPStatusCode200Ok                    = 200,
    HTTPStatusCode201Created               = 201,
    HTTPStatusCode202Accepted              = 202,
    HTTPStatusCode203NonAuthoritativeInformation = 203,
    HTTPStatusCode204NoContent             = 204,
    HTTPStatusCode205ResetContent          = 205,
    HTTPStatusCode206PartialContent        = 206,
    HTTPStatusCode207MultiStatus           = 207,
    HTTPStatusCode208AlreadyReported       = 208,
    HTTPStatusCode226IMUsed                = 226,
    
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
    
    HTTPStatusCode300MultipleChoices       = 300,
    HTTPStatusCode301MovedPermanently      = 301,
    HTTPStatusCode302Found                 = 302,
    HTTPStatusCode303SeeOther              = 303,
    HTTPStatusCode304NotModified           = 304,
    HTTPStatusCode305UseProxy              = 305,
    HTTPStatusCode306SwitchProxy           = 306,
    HTTPStatusCode307TemporaryRedirect     = 307,
    HTTPStatusCode308PermanentRedirect     = 308,
    
    //
    // 4XX Client Error
    //
    // The 4xx class of status code is intended for cases in which the client seems to have erred. Except when responding to a
    // HEAD request, the server should include an entity containing an explanation of the error situation, and whether it is a
    // temporary or permanent condition. These status codes are applicable to any request method. User agents should display any
    // included entity to the user.
    //
    
    HTTPStatusCode400BadRequest            = 400,
    HTTPStatusCode401Unauthorized          = 401,
    HTTPStatusCode402PaymentRequired       = 402,
    HTTPStatusCode403Forbidden             = 403,
    HTTPStatusCode404NotFound              = 404,
    HTTPStatusCode405MethodNotAllowed      = 405,
    HTTPStatusCode406NotAcceptable         = 406,
    HTTPStatusCode407ProxyAuthenticationRequired = 407,
    HTTPStatusCode408RequestTimeout        = 408,
    HTTPStatusCode409Conflict              = 409,
    HTTPStatusCode410Gone                  = 410,
    HTTPStatusCode411LengthRequired        = 411,
    HTTPStatusCode412PreconditionFailed    = 412,
    HTTPStatusCode413RequestEntityTooLarge = 413,
    HTTPStatusCode414RequestURITooLong     = 414,
    HTTPStatusCode415UnsupportedMediaType  = 415,
    HTTPStatusCode416RequestedRangeNotSatisfiable = 416,
    HTTPStatusCode417ExpectationFailed     = 417,
    HTTPStatusCode418ImATeapot             = 418,
    HTTPStatusCode419AuthenticationTimeout = 419,
    HTTPStatusCode420MethodFailure         = 420,
    HTTPStatusCode422UnprocessableEntity   = 422,
    HTTPStatusCode423Locked                = 423,
    HTTPStatusCode424FailedDependency      = 424,
    HTTPStatusCode426UpgradeRequired       = 426,
    HTTPStatusCode428PreconditionRequired  = 428,
    HTTPStatusCode429TooManyRequests       = 429,
    HTTPStatusCode431RequestHeaderFieldsTooLarge = 431,
    HTTPStatusCode440LoginTimeout          = 440,
    HTTPStatusCode444NoResponse            = 444,
    HTTPStatusCode449RetryWith             = 449,
    HTTPStatusCode450BlockedByWindowsParentalControls = 450,
    HTTPStatusCode451UnavailableForLegalReasons = 451,
    HTTPStatusCode451Redirect              = 451,
    HTTPStatusCode494RequestHeaderTooLarge = 494,
    HTTPStatusCode495CertError             = 495,
    HTTPStatusCode497HTTPtoHTTPS           = 497,
    HTTPStatusCode498TokenExpiredOrInvalid = 498,
    HTTPStatusCode499ClientClosedRequest   = 499,
    HTTPStatusCode499TokenRequired         = 499,
    
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
    
    HTTPStatusCode500InternalServerError   = 500,
    HTTPStatusCode501NotImplemented        = 501,
    HTTPStatusCode502BadGateway            = 502,
    HTTPStatusCode503ServiceUnavailable    = 503,
    HTTPStatusCode504GatewayTimeout        = 504,
    HTTPStatusCode505HTTPVersionNotSupported = 505,
    HTTPStatusCode506VariantAlsoNegotiates = 506,
    HTTPStatusCode507InsufficientStorage   = 507,
    HTTPStatusCode508LoopDetected          = 508,
    HTTPStatusCode509BandwidthLimitExceeded = 509,
    HTTPStatusCode510NotExtended           = 510,
    HTTPStatusCode511NetworkAuthenticationRequired = 511,
    HTTPStatusCode598NetworkREadTimeoutError = 598,
    HTTPStatusCode599NetworkConnectTimeoutError = 599,
};
