# Hermod
User friendly HTTP client on top of AFNetworking

## Installation
The easiest to import Hermod to your project is by using Cocoa Pods:

```
pod 'Hermod', '~> 1.0.0'
```

## 1. HTTP Client

### 1.1 Definining the instance

To create a new API client you must specify the host domain as well as the API path where all requests will be directed to.

```objective-c
HMClient *client = [[HMClient alloc] initWithConfigurator:^(HMClientConfigurator *configurator) {
    configurator.serverPath = @"http://www.domain.com";
    configurator.apiPath =  @"/api/v1";
}];
```

### 1.2 Creating requests and upload requests

Creating requests with `HMClient` is very easy. Just create an instnace of `HMRequest` and configure it.
```objective-c
HMRequest *request = [HMRequest requestWithPath:@"users/hobbies"];
request.HTTPMethod = HMHTTPMethodPUT;
request.parameters = @{"name": "kitesurfing",
                       "rating": 8,
                     };
```

Requests by default use the `HMHTTPMethodGET`.

To create an upload request, instantiate the `HMUploadRequest` and add an array of `HMUploadTask` objects, one per each upload task. Upload requests by default are `HMHTTPMethodPOST`.

### 1.3 Performing requests

In order to perform requests, `HMClient` provides a protocol called `HMRequestExecutor` that defines the following two methods:

```objective-c
- (void)performRequest:(HMRequest*)request completionBlock:(HMResponseBlock)completionBlock;
- (void)performRequest:(HMRequest*)request apiPath:(NSString*)apiPath completionBlock:(HMResponseBlock)completionBlock;
```

The first method uses the default apiClient's `apiPath`, the second method uses a custom `apiPath`. The response block contains a `HMResponse`. If error, it is going to be encapsulated inside the `HMResponse`.

`HMClient` implements this protocol. Therefore, you can use it directly to perform a request. However, you can build your own request executors and do validation checks and other custom actions in the middle. As a good example of it, `HMClient` provides an OAuth session handler called `HMOAuthSession`. This object, which implements the `HMRequestExecutor` protocol, validates the OAuth state and configures an `HMClient` instance with the good HTTP authentication headers. To know more about this object, see documentation below.

```objective-c
id <HMRequestExecutor> requestExecutor = _myApiClient; 

HMRequest *request = [HMRequest requestWithPath:@"users/reset-password"];
request.httpMethod = HTTPMethodPOST;
request.parameters = @{@"email": email};

[requestExecutor performRequest:request completionBlock:^(HMResponse *response, NSInteger key) {
    if (response.error == nil) 
    {
        NSLog(@"Response object: %@", [response.responseObject description]);
    }
    else 
    {
        NSLog(@"Response error: %@", [response.error description]);
    }
}];
```

### 1.4 Configuring the API Client

#### 1.4.1 Managing the URL Cache

HMClient implements a basic offline simulation via the URL cache. To configure it, use the default init method of `HMClient` and set the `cacheManagement` of the `HMClientConfigurator` to `HMClientCacheManagementOffline`. When configured, the app will use the URL Cache to return already cached respones when being offline. By default the `cacheManagement` is set to `HMClientCacheManagementDefault` (which ignores the URL cache when being offline).

```objective-c
HMClient *apiClient = [[HMClient alloc] initWithConfigurator:^(HMClientConfigurator *configurator) {
    configurator.host = @"http://www.domain.com";
    configurator.apiPath =  @"/api/v1";
    
    // Use the URLCache to return already cached responses when being offline.
    configurator.cacheManagement = HMClientCacheManagementOffline;
}];
```
#### 1.4.2 Selecting request and response serializers

While configuring a `HMClient` instance, it is possible to customize the request and response serializers.

```objective-c
HMClient *apiClient = [[HMClient alloc] initWithConfigurator:^(HMClientConfigurator * _Nonnull configurator) {
    // Here goes the overall configuration
    [...]
    
    // Configuration of request and response serializers
    configurator.requestSerializerType = HMClientRequestSerializerTypeJSON;
    configurator.responseSerializerType = HMClientResponseSerializerTypeJSON;
}];
```
The supported serializers are:

**Request Serializers**
- `HMClientRequestSerializerTypeJSON`: JSON format request (mimetype applicaiton/JSON)
- `HMClientRequestSerializerTypeFormUrlencoded`: URL Encoded request (mimetype applicaiton/x-www-form-urlencoded with utf8 charset)

**Response Serializers**
- `HMClientResponseSerializerTypeJSON`: JSON format response (response object will be `NSDictionary` or `NSArray`)
- `HMClientResponseSerializerTypeRaw`: RAW response (response object will be `NSData`).

By default, request and response serializers are set to JSON format. However, it is possible to change them to the other types.

HMClient only support the listed types above. If there is a need for different type, the library will have to be extended and implemented.

#### 1.4.3 Response dispatch queue

This library is built on top of AFNetworking. Therefore, when performing a request, the response is returned asyncronously in the default `dispatch_queue_t` selected by AFNetworking, which usually is in the main queue.

`HMClient` offers the option to set a custom dispatch_queue_t to return its request's responses in. This can be set globaly o per request.

To set it per request, set a `dispatch_queue_t` inside the `HMRequest`'s `completionBlockQueue` parameter. If not set (nil), then the response block will be execute on the HMClient's global queue.
```objective-c
HMRequest *request = [HMRequest requestWithPath:@"user/12345"];
request.completionBlockQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
```
To set the global queue use the `HMClientConfigurator` object inside the init method. If not set, then the response block will be executed in the default AFNetworking reponse block queue.
```objective-c
HMClient *apiClient = [[HMClient alloc] initWithConfigurator:^(HMClientConfigurator *configurator) {
    configurator.host = @"http://www.domain.com";
    configurator.apiPath =  @"/api/v1";
    
    // Set a custom queue for all response blocks
    configurator.completionBlockQueue = dispatch_queue_create("com.myapp.api.completion-queue", DISPATCH_QUEUE_SERIAL);
}];
```

### 1.5 Error Handling
Use the `HMClientDelegate` object to create server-specific errors and manage them. 

In the following method, it is possible to specify custom errors depending of the content of the HTTP response. If an error is returned, then `HMClient` will assume the request failed and will include the error in its `HMResponse`.

```objective-c
- (NSError*)apiClient:(HMClient*)apiClient errorForResponseBody:(id)responseBody httpResponse:(NSHTTPURLResponse*)httpResponse incomingError:(NSError*)error 
{
    if ([responseBody isKindOfClass:NSDictionary.class]) 
    {
        if (responseBody[@"error_code"]) 
        {
            NSInteger errorCode = [responseBody[@"error_code"] integerValue];
            NSString *message = responseBody[@"error_message"];
            NSDictionary *userInfo = @{CustomApiErrorDomainNameKey: @(errorCode),
                                       NSLocalizedDescriptionKey: message,
                                       };
            error = [NSError errorWithDomain:@"CustomApiErrorDomain" code:errorCode userInfo:userInfo];
        }
    }
    return error;
}
```

Finally, use the method `-apiClient:didReceiveErrorInResponse:` of `HMClientDelegate` to globaly manage errors. Typically, you can use it to log errors, show alerts, and even logout the logged-in user if an unauthorized error.

```objective-c
- (void)apiClient:(HMClient*)apiClient didReceiveErrorInResponse:(HMResponse*)response
{
    // Manage the error of the response.
}
```

### 2. HMOAuthSession (OAuth Support)

In order to support OAuth, `HMClient` has the class `HMOAuthSession`. This class will keep the OAuth session alive and perform the fetch and refresh of tokens. Furthermore, it implements the `HMRequestExecutor` protocol in order to perform requests with OAuth support.

#### 2.1 Configuration

To configure an `HMOAuthSession` just create a new instnace and use the `initWithConfigurator:` method as follows:

```objective-c
HMOAuthSession *oauthSession = [[HMOAuthSession alloc] initWithConfigurator:^(HMOAuthSesionConfigurator *configurator) {
    configurator.apiClient = apiClient; // <-- configured `HMClient` instance
    configurator.apiOAuthPath = @"/api/oauth2/token";
    configurator.clientId = @"client_id";
    configurator.clientSecret = @"client_secret";
}];
```
It is required to provide configured `HMClient` instance, the api path of the OAuth methods, the client ID and client secret.

And that's all. Now the instance is ready to be used:

```objective-c
id <HMRequestExecutor> requestExecutor = _myOauthApiSession; 

HMRequest *request = [HMRequest requestWithPath:@"users/reset-password"];
request.httpMethod = HMHTTPMethodPOST;
request.parameters = @{@"email": email};

[requestExecutor performRequest:request completionBlock:^(HMResponse *response, NSInteger key) {
    if (response.error == nil) 
        NSLog(@"Response object: %@", [response.responseObject description]);
    else 
        NSLog(@"Response error: %@", [response.error description]);
}];
```

The oauth session will take care of getting tokens, configure them into the HTTP headers and renew them if expired.

### 2.2 Token persistence

All tokens received from the server are stored securely automatically inside the Keychain. Consecutive app executions will reuse tokens previously received.

Otherwise, use the method `-configureWithOAuth:forSessionAccess:` to manually set an OAuth token (will be stored inside the Keychain as well).

Use the method `-validateOAuth:` to force a OAuth token validation.

### 2.3 OAuth Login & Logout

Use the method `loginWithUsername:password:completionBlock:` to perform an OAuth user login. Use the method `-logout` to perform an OAuth user logout.

```objective-c
[_oauthSession loginWithUsername:@"username" password:@"password" completionBlock:^(NSError *error) {
    if (!error)
        NSLog(@"OAuth login successful");
    else
        NSLog(@"OAuth login failed with error: %@", error.localizedDescription);
}];
```
### 2.4 App Tokens vs User Tokens

By default `HMOAuthSession` uses tokens in two levels: app and user. This means that whenever a user is not logged in, the session will fetch an app-level token. If the user is logged in, the session will fetch user-level tokens.

The default configuration is set to use app tokens. However, it can be disabled:

```objective-c
HMOAuthSession *oauthSession = [[HMOAuthSession alloc] initWithConfigurator:^(HMOAuthSesionConfigurator *configurator) {
    // Configuration of the oauth session here
    [...]
    
    // Disable app token
    configurator.useAppToken = NO;
}];
```

### 2.5 OAuth Namespace Configuration

If the OAuth server uses a specific namespace configuration for the resposnes including the OAuth tokens, it is possible to configure it accordingly using the `HMOAuthConfiguration` class.

```objective-c
HMOAuthConfiguration *oauthConfiguration = [[HMOAuthConfiguration alloc] init];
oauthConfiguration.expiresInKey = @"expires_in";
oauthConfiguration.refreshTokenKey = @"refresh_token";
oauthConfiguration.accessTokenKey = @"token";
oauthConfiguration.scopeKey = @"scope";
oauthConfiguration.expiryDateBlock = ^NSDate*(id value) {
    NSTimeInterval timeInterval = [value integerValue];
    return [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
};

HMOAuthSession *oauthSession = [[HMOAuthSession alloc] initWithConfigurator:^(HMOAuthSesionConfigurator *configurator) {
    // Configuration of the oauth session here
    [...]
    
    // Custom oauth namespace configuration
    configurator.oauthConfiguration = oauthConfiguration;
}];
```

### 2.6 OAuth delegate

The oauth session class `HMOAuthSession` has a delegate object which must implement the `HMOAuthSessionDelegate`.

```objective-c
- (void)session:(HMOAuthSession*)session didConfigureOAuth:(HMOAuth*)oauth forSessionAccess:(HMOAuthSesionAccess)sessionAccess
{
    // OAuth session access did change
}
```
