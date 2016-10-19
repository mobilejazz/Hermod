# MJApiClient
User friendly API client on top of AFNetworking

## Installation
The easiest to import MJApiClient to your project is by using Cocoa Pods:

```
pod 'MJApiClient', :git => 'https://github.com/mobilejazz/MJApiClient.git', :tag => '0.3.9'
```

## 1. API Client

### 1.1 Definining the instance

To create a new API client you must specify the host domain as well as the API path where all requests will be directed to.

```objective-c
MJApiClient *apiClient = [[MJApiClient alloc] initWithConfigurator:^(MJAPiClientConfigurator *configurator) {
    configurator.serverPath = @"http://www.domain.com";
    configurator.apiPath =  @"/api/v1";
}];
```

### 1.2 Creating requests and upload requests

Creating requests with **MJApiClient** is very easy. Just create an instnace of `MJApiRequest` and configure it.
```objective-c
MJApiRequest *apiRequest = [MJApiRequest requestWithPath:@"users/hobbies"];
apiRequest.HTTPMethod = HTTPMethodPUT;
apiRequest.parameters = @{"name": "kitesurfing",
                          "rating": 8,
                        };
```

Requests by default use the `HTTPMethodGET`.

To create an upload request, instantiate the `MJApiUploadRequest` and add an array of `MJApiUploadTask` objects, one per each upload task. Upload requests by default are `HTTPMethodPOST`.

### 1.3 Performing requests

In order to perform requests, MJApiClient provides a protocol called `MJApiRequestExecutor` that defines the following two methods:

```objective-c
- (void)performRequest:(MJApiRequest*)request completionBlock:(MJApiResponseBlock)completionBlock;
- (void)performRequest:(MJApiRequest*)request apiPath:(NSString*)apiPath completionBlock:(MJApiResponseBlock)completionBlock;
```

The first method uses the default apiClient's `apiPath`, the second method uses a custom `apiPath`. The response block contains a `MJApiResponse`. If error, it is going to be encapsulated inside the `MJApiResponse`.

`MJApiClient` implements this protocol. Therefore, you can use it directly to perform a request. However, you can build your own request executors and do validation checks and other custom actions in the middle. As a good example of it, MJApiClient provides an OAuth session handler called `MJApiOAuthSession`. This object, which implements the `MJApiRequestExecutor` protocol, validates the OAuth state and configures an `MJApiClient` instance with the good HTTP authentication headers. To know more about this object, see documentation below.

```objective-c
id <MJApiRequestExecutor> requestExecutor = _myApiClient; 

MJApiRequest *request = [MJApiRequest requestWithPath:@"users/reset-password"];
request.httpMethod = HTTPMethodPOST;
request.parameters = @{@"email": email};

[requestExecutor performRequest:request completionBlock:^(MJApiResponse *response, NSInteger key) {
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

MJApiClient implements a basic offline simulation via the URL cache. To configure it, use the default init method of `MJApiClient` and set the `cacheManagement` of the `MJAPiClientConfigurator` to `MJApiClientCacheManagementOffline`. When configured, the app will use the URL Cache to return already cached respones when being offline. By default the `cacheManagement` is set to `MJApiClientCacheManagementDefault` (which ignores the URL cache when being offline).

```objective-c
MJApiClient *apiClient = [[MJApiClient alloc] initWithConfigurator:^(MJAPiClientConfigurator *configurator) {
    configurator.host = @"http://www.domain.com";
    configurator.apiPath =  @"/api/v1";
    
    // Use the URLCache to return already cached responses when being offline.
    configurator.cacheManagement = MJApiClientCacheManagementOffline;
}];
```
#### 1.4.2 Selecting request and response serializers

While configuring a MJApiClient instance, it is possible to customize the request and response serializers.

```objective-c
MJApiClient *apiClient = [[MJApiClient alloc] initWithConfigurator:^(MJApiClientConfigurator * _Nonnull configurator) {
    // Here goes the overall configuration
    [...]
    
    // Configuration of request and response serializers
    configurator.requestSerializerType = MJApiClientRequestSerializerTypeJSON;
    configurator.responseSerializerType = MJApiClientResponseSerializerTypeJSON;
}];
```
The supported serializers are:

**Request Serializers**
- `MJApiClientRequestSerializerTypeJSON`: JSON format request (mimetype applicaiton/JSON)
- `MJApiClientRequestSerializerTypeFormUrlencoded`: URL Encoded request (mimetype applicaiton/x-www-form-urlencoded with utf8 charset)

**Response Serializers**
- `MJApiClientResponseSerializerTypeJSON`: JSON format response (response object will be `NSDictionary` or `NSArray`)
- `MJApiClientResponseSerializerTypeRaw`: RAW response (response object will be `NSData`).

By default, request and response serializers are set to JSON format. However, it is possible to change them to the other types.

MJApiClient only support the listed types above. If there is a need for different type, the library will have to be extended and implemented.

#### 1.4.3 Response dispatch queue
This library is built on top of AFNetworking. Therefore, when performing a request, the response is returned asyncronously in the default `dispatch_queue_t` selected by AFNetworking, which usually is in the main queue.

`MJApiClient` offers the option to set a custom dispatch_queue_t to return its request's responses in. This can be set globaly o per request.

To set it per request, set a `dispatch_queue_t` inside the `MJApiRequest`'s `completionBlockQueue` parameter. If not set (nil), then the response block will be execute on the MJApiClient's global queue.
```objective-c
MJApiRequest *request = [MJApiRequest requestWithPath:@"user/12345"];
request.completionBlockQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
```
To set the global queue use the `MJAPiClientConfigurator` object inside the init method. If not set, then the response block will be executed in the default AFNetworking reponse block queue.
```objective-c
MJApiClient *apiClient = [[MJApiClient alloc] initWithConfigurator:^(MJAPiClientConfigurator *configurator) {
    configurator.host = @"http://www.domain.com";
    configurator.apiPath =  @"/api/v1";
    
    // Set a custom queue for all response blocks
    configurator.completionBlockQueue = dispatch_queue_create("com.myapp.api.completion-queue", DISPATCH_QUEUE_SERIAL);
}];
```

### 1.5 Error Handling
Use the `MJApiClientDelegate` object to create server-specific errors and manage them. 

In the following method, it is possible to specify custom errors depending of the content of the HTTP response. If an error is returned, then MJApiClient will assume the request failed and will include the error in its `MJApiResponse`.

```objective-c
- (NSError*)apiClient:(MJApiClient*)apiClient errorForResponseBody:(id)responseBody httpResponse:(NSHTTPURLResponse*)httpResponse incomingError:(NSError*)error 
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

Finally, use the method `-apiClient:didReceiveErrorInResponse:` of `MJApiClientDelegate` to globaly manage errors. Typically, you can use it to log errors, show alerts, and even logout the logged-in user if an unauthorized error.

```objective-c
- (void)apiClient:(MJApiClient*)apiClient didReceiveErrorInResponse:(MJApiResponse*)response
{
    // Manage the error of the response.
}
```

### 2. MJApiOAuthSession (OAuth Support)

In order to support OAuth, MJApiClient has the class `MJApiOAuthSession`. This class will keep the OAuth session alive and perform the fetch and refresh of tokens. Furthermore, it implements the `MJApiRequestExecutor` protocol in order to perform requests with OAuth support.

#### 2.1 Configuration

To configure an `MJApiOAuthSession` just create a new instnace and use the `initWithConfigurator:` method as follows:

```objective-c
MJApiOAuthSession *oauthSession = [[MJApiOAuthSession alloc] initWithConfigurator:^(MJApiOAuthSesionConfigurator *configurator) {
    configurator.apiClient = apiClient; // <-- configured MJApiClient instance
    configurator.apiOAuthPath = @"/api/oauth2/token";
    configurator.clientId = @"client_id";
    configurator.clientSecret = @"client_secret";
}];
```
It is required to provide configured `MJApiClient` instance, the api path of the OAuth methods, the client ID and client secret.

And that's all. Now the instance is ready to be used:

```objective-c
id <MJApiRequestExecutor> requestExecutor = _myOauthApiSession; 

MJApiRequest *request = [MJApiRequest requestWithPath:@"users/reset-password"];
request.httpMethod = HTTPMethodPOST;
request.parameters = @{@"email": email};

[requestExecutor performRequest:request completionBlock:^(MJApiResponse *response, NSInteger key) {
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

By default `MJApiOAuthSession` uses tokens in two levels: app and user. This means that whenever a user is not logged in, the session will fetch an app-level token. If the user is logged in, the session will fetch user-level tokens.

The default configuration is set to use app tokens. However, it can be disabled:

```objective-c
MJApiOAuthSession *oauthSession = [[MJApiOAuthSession alloc] initWithConfigurator:^(MJApiOAuthSesionConfigurator *configurator) {
    // Configuration of the oauth session here
    [...]
    
    // Disable app token
    configurator.useAppToken = NO;
}];
```

### 2.5 OAuth Namespace Configuration

If the OAuth server uses a specific namespace configuration for the resposnes including the OAuth tokens, it is possible to configure it accordingly using the `MJApiOAuthConfiguration` class.

```objective-c
MJApiOAuthConfiguration *oauthConfiguration = [[MJApiOAuthConfiguration alloc] init];
oauthConfiguration.expiresInKey = @"expires_in";
oauthConfiguration.refreshTokenKey = @"refresh_token";
oauthConfiguration.accessTokenKey = @"token";
oauthConfiguration.scopeKey = @"scope";
oauthConfiguration.expiryDateBlock = ^NSDate*(id value) {
    NSTimeInterval timeInterval = [value integerValue];
    return [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
};

MJApiOAuthSession *oauthSession = [[MJApiOAuthSession alloc] initWithConfigurator:^(MJApiOAuthSesionConfigurator *configurator) {
    // Configuration of the oauth session here
    [...]
    
    // Custom oauth namespace configuration
    configurator.oauthConfiguration = oauthConfiguration;
}];
```

### 2.6 OAuth delegate

The oauth session class `MJApiOAuthSession` has a delegate object which must implement the `MJApiOAuthSessionDelegate`.

```objective-c
- (void)session:(MJApiOAuthSession*)session didConfigureOAuth:(MJApiOAuth*)oauth forSessionAccess:(MJApiOAuthSesionAccess)sessionAccess
{
    // OAuth session access did change
}
```
