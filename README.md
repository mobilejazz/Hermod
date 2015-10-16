# MJApiClient
User friendly API client on top of AFNetworking

## Installation
The easiest to import MJApiClient to your project is by using Cocoa Pods:

```
pod 'MJApiClient', :git => 'https://github.com/mobilejazz/MJApiClient.git', :tag => '0.2.1'
```

##1. API Client

###1.1 Definining the instance

To create a new API client you must specify the host domain as well as the API path where all requests will be directed to.

```objective-c
MJApiClient *apiClient = [[MJApiClient alloc] initWithHost:@"http://www.domain.com"];
apiClient.apiPath = @"/api_path_sample/v1";
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

###1.4 Error Handling

Use the `MJApiClientDelegate` object to create server-specific errors. For example, the following code would be the delegate of the api client:

```objective-c
#pragma mark MJApiClientDelegate

- (NSError*)apiClient:(MJApiClient *)apiClient errorForResponseBody:(NSDictionary *)responseBody incomingError:(NSError *)error {
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

###2. MJApiSession

```
<TODO>
```
