# MJApiClient
User friendly API client on top of AFNetworking

## Installation
The easiest to import MJApiClient to your project is by using Cocoa Pods:

```
pod 'MJApiClient', :git => 'https://github.com/mobilejazz/MJApiClient.git', :tag => '0.3.9'
```

##1. API Client

###1.1 Definining the instance

To create a new API client you must specify the host domain as well as the API path where all requests will be directed to.

```objective-c
MJApiClient *apiClient = [[MJApiClient alloc] initWithConfigurator:^(MJAPiClientConfigurator *configurator) {
    configurator.host = @"http://www.domain.com";
    configurator.apiPath =  @"/api/v1";
}];
```

###1.2 Creating requests and upload requests

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

###1.3 Performing requests

To perfom a request use the `MJApiClient` methods:

```objective-c
- (NSInteger)performRequest:(MJApiRequest*)request completionBlock:(MJApiResponseBlock)completionBlock;
- (NSInteger)performRequest:(MJApiRequest*)request apiPath:(NSString*)apiPath completionBlock:(MJApiResponseBlock)completionBlock;
```

The first one uses the default `apiPath`, the second one uses a custom `apiPath`. The return of those methods is an identifier of the request.

The response block will contain a `MJApiResponse` together with the identifier of the request. The error will be encapsulated inside the `MJApiResponse`.

For example:

```objective-c
MJApiRequest *request = [MJApiRequest requestWithPath:@"users/reset-password"];
request.httpMethod = HTTPMethodPOST;
request.parameters = @{@"email": email};

[_apiClient performRequest:request completionBlock:^(MJApiResponse *response, NSInteger key) {
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
###1.4 Managing the URL Cache

MJApiClient implements a basic offline simulation via the URL cache. To configure it, use the default init method of `MJApiClient` and set the `cacheManagement` of the `MJAPiClientConfigurator` to `MJApiClientCacheManagementOffline`. When configured, the app will use the URL Cache to return already cached respones when being offline. By default the `cacheManagement` is set to `MJApiClientCacheManagementDefault` (which ignores the URL cache when being offline).

```objective-c
MJApiClient *apiClient = [[MJApiClient alloc] initWithConfigurator:^(MJAPiClientConfigurator *configurator) {
    configurator.host = @"http://www.domain.com";
    configurator.apiPath =  @"/api/v1";
    
    // Use the URLCache to return already cached responses when being offline.
    configurator.cacheManagement = MJApiClientCacheManagementOffline;
}];
```
###1.5 Response dispatch queue
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

###1.6 Error Handling
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

###2. MJApiSession

```
<TODO>
```
