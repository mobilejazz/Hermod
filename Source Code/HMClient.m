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

#import "HMClient.h"

#import <AFNetworking/AFNetworking.h>


#if TARGET_OS_IOS
#import <FormatterKit/TTTURLRequestFormatter.h>
#endif

#import "HMJSONResponseSerializer.h"

#import "HMHTTPOfflineCacheSessionManager.h"

@implementation HMClientConfigurator

- (void)configureWithConfiguration:(HMConfiguration * _Nonnull)configuration
{
    _serverPath = configuration.serverPath;
    _apiPath = configuration.path;
}

@end

@interface HMClient ()

@end

@implementation HMClient
{
    AFHTTPSessionManager *_httpSessionManager;
    
    AFHTTPRequestSerializer *_requestSerializer;
    AFHTTPResponseSerializer *_responseSerializer;
}

- (id)init
{
    [[NSException exceptionWithName:NSInvalidArgumentException
                             reason:@"To init a HMClient use the initializer -initWithConfigurator:"
                           userInfo:nil] raise];
    
    return [self initWithServerPath:@"http://www.mydomain.com" apiPath:nil];
}

- (id)initWithServerPath:(NSString*)serverPath apiPath:(NSString *)apiPath
{
    return [self initWithConfigurator:^(HMClientConfigurator *configurator) {
        configurator.apiPath = apiPath;
        configurator.serverPath = serverPath;
        configurator.cacheManagement = HMClientCacheManagementDefault;
        configurator.requestSerializerType = HMClientRequestSerializerTypeJSON;
        configurator.responseSerializerType = HMClientResponseSerializerTypeJSON;
        configurator.acceptableContentTypes = nil;
    }];
}

- (id)initWithConfigurator:(void (^)(HMClientConfigurator *configurator))configuratorBlock
{
	if (!configuratorBlock)
	{
		NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:@"The configurator block cannot be nil!" userInfo:nil];
		@throw exception;
	}
	
	self = [super init];
	if (self)
	{
		[self mjz_configureWithBlock:configuratorBlock];
        
        // Configuring Language
        self.insertAcceptLanguageHeader = YES;
        self.insertLanguageAsParameter = NO;
        self.languageParameterName = @"language";
	}
	return self;
}

- (void)reconfigureWithConfigurator:(void (^_Nonnull)(HMClientConfigurator * _Nonnull configurator))configuratorBlock
{
	if (!configuratorBlock)
	{
		NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:@"The configurator block cannot be nil!" userInfo:nil];
		@throw exception;
	}
	
	if (self)
	{
		[self mjz_configureWithBlock:configuratorBlock];
	}
}

#pragma mark Properties

- (void)setHeaderParameters:(NSDictionary *)headerParameters
{
    if (_headerParameters.count > 0)
    {
        // Removing old header parameters
        [_headerParameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [_httpSessionManager.requestSerializer setValue:nil forHTTPHeaderField:key];
        }];
    }
    
    _headerParameters = headerParameters;
    
    if (_headerParameters.count > 0)
    {
        // Adding new header parameters
        [_headerParameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [_httpSessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
}

#pragma mark Public Methods

- (void)setBearerToken:(NSString*)token
{
    if (token)
    {
        [_httpSessionManager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    }
    else
    {
        [self removeAuthorizationHeaders];
    }
}

- (void)setBasicAuthWithUsername:(NSString*)username password:(NSString*)password
{
    if (username != nil && password != nil)
    {
        [_httpSessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    }
    else // if (username == nil && password == nil)
    {
        [self removeAuthorizationHeaders];
    }
}

- (void)setAuthorizationHeader:(NSString *)value
{
    if (value)
    {
        [_httpSessionManager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
    }
    else
    {
        [self removeAuthorizationHeaders];
    }
}

- (void)removeAuthorizationHeaders
{
    [_httpSessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
}

- (void)setInsertAcceptLanguageHeader:(BOOL)insertAcceptLanguageHeader
{
    _insertLanguageAsParameter = insertAcceptLanguageHeader;
    
    if (insertAcceptLanguageHeader)
    {
        NSString *language = [self mjz_requestLanguage];
        [_requestSerializer setValue:language forHTTPHeaderField:@"Accept-Language"];
    }
    else
    {
        [_requestSerializer setValue:nil forHTTPHeaderField:@"Accept-Language"];
    }
}


#pragma mark Private Methods

- (void)mjz_configureWithBlock:(void (^)(HMClientConfigurator *))configuratorBlock
{
	HMClientConfigurator *configurator = [HMClientConfigurator new];
	configurator.cacheManagement = HMClientCacheManagementDefault;
	configurator.requestSerializerType = HMClientRequestSerializerTypeJSON;
	configurator.responseSerializerType = HMClientResponseSerializerTypeJSON;
	configurator.timeoutInterval = 60;
    configurator.acceptableContentTypes = nil;
	configuratorBlock(configurator);
	
	_serverPath = configurator.serverPath;
	_apiPath = configurator.apiPath;
	_cacheManagement = configurator.cacheManagement;
	_completionBlockQueue = configurator.completionBlockQueue;
	
	// Configuring the cache management
	if (configurator.cacheManagement == HMClientCacheManagementOffline)
	{
		_httpSessionManager = [[HMHTTPOfflineCacheSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_serverPath]];
	}
	else
	{
		_httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_serverPath]];
	}
	
	// Request serializer
	if (configurator.requestSerializerType == HMClientRequestSerializerTypeJSON)
	{
		_requestSerializer = [[AFJSONRequestSerializer alloc] init];
	}
	else if (configurator.requestSerializerType == HMClientRequestSerializerTypeFormUrlencoded)
	{
		_requestSerializer = [[AFHTTPRequestSerializer alloc] init];
		[_requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf8" forHTTPHeaderField:@"Content-Type"];
	}
	
	// Response serializer
	if (configurator.responseSerializerType == HMClientResponseSerializerTypeJSON)
	{
		HMJSONResponseSerializer *jsonResponseSerializer = [[HMJSONResponseSerializer alloc] init];
		jsonResponseSerializer.readingOptions = NSJSONReadingAllowFragments;
		_responseSerializer = jsonResponseSerializer;
	}
	else if (configurator.responseSerializerType == HMClientResponseSerializerTypeRaw)
	{
		_responseSerializer = [[AFHTTPResponseSerializer alloc] init];
	}

    _responseSerializer.acceptableContentTypes = configurator.acceptableContentTypes;
	
	// Configuring timout interval
	_requestSerializer.timeoutInterval = configurator.timeoutInterval;
		
	// Configuring serializers
	_httpSessionManager.requestSerializer = _requestSerializer;
	_httpSessionManager.responseSerializer = _responseSerializer;
}

- (NSString*)mjz_urlPathForRequest:(HMRequest*)request apiPath:(NSString*)apiPath
{
    if (request)
    {
        if (apiPath.length > 0)
            return [_serverPath stringByAppendingFormat:@"%@/%@", apiPath, request.path];
        else
            return [_serverPath stringByAppendingFormat:@"%@", request.path];
    }
    return nil;
}

- (NSString*)mjz_requestLanguage
{
    return [[NSLocale preferredLanguages] firstObject];
}

#pragma mark - Protocols
#pragma mark HMRequestExecutor

- (void)performRequest:(HMRequest*)request completionBlock:(HMResponseBlock)completionBlock
{
    return [self performRequest:request apiPath:_apiPath completionBlock:completionBlock];
}

- (void)performRequest:(HMRequest*)request apiPath:(NSString*)apiPath completionBlock:(HMResponseBlock)completionBlock
{
    NSURLSessionDataTask *sessionDataTask = nil;
    
    NSString *urlPath = [self mjz_urlPathForRequest:request apiPath:apiPath];
    NSDictionary *parameters = request.parameters;
    HMHTTPMethod httpMethod = request.httpMethod;
    
    if (!urlPath)
    {
        if (completionBlock)
            completionBlock(nil);
        return;
    }
    
    // Adding language parameter if needed
    if (_insertLanguageAsParameter && _languageParameterName.length > 0)
    {
        NSMutableDictionary *dict = [parameters mutableCopy];
        if (!dict)
            dict = [NSMutableDictionary dictionary];
        
        NSString *language = [self mjz_requestLanguage];
        [dict setObject:language forKey:_languageParameterName];
        parameters = [dict copy];
    }
    
    // Adding request shared parameters
    if (_requestGlobalParameters.count > 0)
    {
        NSMutableDictionary *dict = [parameters mutableCopy];
        if (!dict)
            dict = [NSMutableDictionary dictionary];
        
        [dict addEntriesFromDictionary:_requestGlobalParameters];
        parameters = [dict copy];
    }
    
    dispatch_queue_t completionBlockQueue = request.completionBlockQueue;
    if (!completionBlockQueue)
    {
        completionBlockQueue = self.completionBlockQueue;
        if (!completionBlockQueue)
            completionBlockQueue = dispatch_get_main_queue();
    }
    
    __block BOOL didFinish = NO;
    
    // Defining task success completion block
    void (^taskCompletion)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject)
    {
        didFinish = YES;
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        
        NSError *error = nil;
        if ([_delegate respondsToSelector:@selector(apiClient:errorForResponseBody:httpResponse:incomingError:)])
            error = [_delegate apiClient:self errorForResponseBody:responseObject httpResponse:httpResponse incomingError:nil];
        
        HMResponse *response = [[HMResponse alloc] initWithRequest:request
                                                      httpResponse:httpResponse
                                                            object:responseObject
                                                             error:error];
        
        if ((_logLevel & HMClientLogLevelResponses) != 0)
            NSLog(@"[ApiClient] RESPONSE: %@\n%@\n\n", error!=nil?@"FAILURE":@"SUCCESS", response.description);
        
        dispatch_async(completionBlockQueue, ^{
            if (completionBlock)
                completionBlock(response);
            
            if (response.error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(apiClient:didReceiveErrorInResponse:)])
                        [_delegate apiClient:self didReceiveErrorInResponse:response];
                });
            }
        });
    };
    
    // Defining task fail completion block
    void (^taskFailCompletion)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        
        didFinish = YES;
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        
        NSDictionary *body = error.userInfo[HMJSONResponseSerializerBodyKey];
        if (body)
        {
            if ([_delegate respondsToSelector:@selector(apiClient:errorForResponseBody:httpResponse:incomingError:)])
                error = [_delegate apiClient:self errorForResponseBody:body httpResponse:httpResponse incomingError:error];
        }
        
        HMResponse *response = [[HMResponse alloc] initWithRequest:request
                                                      httpResponse:httpResponse
                                                            object:body
                                                             error:error];
        
        if ((_logLevel & HMClientLogLevelResponses) != 0)
            NSLog(@"[ApiClient] RESPONSE: %@\n%@\n\n", error!=nil?@"FAILURE":@"SUCCESS", response.description);
        
        dispatch_async(completionBlockQueue, ^{
            if (completionBlock)
                completionBlock(response);
            
            if (response.error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(apiClient:didReceiveErrorInResponse:)])
                        [_delegate apiClient:self didReceiveErrorInResponse:response];
                });
            }
        });
    };
    
    @synchronized (self)
    {
        // Crating a synchronization block to manage the timeoutInterval. The synchrnonization will enforce the request serialization
        // using the correct timetout defined in the HMRequest. The snchronization block will generate a semaphore that will be unlocked
        // syncrhonously (there are no async calls involved in the unlock).
        
        // Storing the original timeout.
        NSTimeInterval timeoutInterval = _requestSerializer.timeoutInterval;
        BOOL customTimeoutInterval = (request.timeoutInterval != HMRequestDefaultTimeoutInterval);
        
        if (customTimeoutInterval)
        {
            // If the request.timeoutInterval has been customized, configure the new timeout in the request serializer.
            _requestSerializer.timeoutInterval = request.timeoutInterval;
        }
        
        // Executing the request (serializing it and then sending it via AFNetworking)
        if (httpMethod == HMHTTPMethodGET)
        {
            sessionDataTask = [_httpSessionManager GET:urlPath
                                            parameters:parameters
                                               headers:nil
                                              progress:nil
                                               success:taskCompletion
                                               failure:taskFailCompletion];
        }
        else if (httpMethod == HMHTTPMethodPOST)
        {
            if ([request isKindOfClass:HMUploadRequest.class])
            {
                HMUploadRequest *uploadRequest = (id)request;
                
                NSMutableURLRequest *request = [_httpSessionManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                                           URLString:[[NSURL URLWithString:urlPath relativeToURL:_httpSessionManager.baseURL] absoluteString]
                                                                                                          parameters:parameters
                                                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                               [uploadRequest.uploadTasks enumerateObjectsUsingBlock:^(HMUploadTask *task, NSUInteger idx, BOOL *stop) {
                                                                                                   [formData appendPartWithFileData:task.data
                                                                                                                               name:task.fieldName
                                                                                                                           fileName:task.filename
                                                                                                                           mimeType:task.mimeType];
                                                                                               }];
                                                                                           }
                                                                                                               error:nil];
                
                sessionDataTask = [_httpSessionManager uploadTaskWithStreamedRequest:request
                                                                            progress:nil
                                                                   completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                                                                       if (error)
                                                                           taskFailCompletion(sessionDataTask, error);
                                                                       else
                                                                           taskCompletion(sessionDataTask, responseObject);
                                                                   }];
                [sessionDataTask resume];
            }
            else
            {
                sessionDataTask = [_httpSessionManager POST:urlPath
                                                 parameters:parameters
                                                    headers:nil
                                                   progress:nil
                                                    success:taskCompletion
                                                    failure:taskFailCompletion];
            }
        }
        else if (httpMethod == HMHTTPMethodPUT)
        {
            sessionDataTask = [_httpSessionManager PUT:urlPath
                                            parameters:parameters
                                               headers:nil
                                               success:taskCompletion
                                               failure:taskFailCompletion];
        }
        else if (httpMethod == HMHTTPMethodDELETE)
        {
            sessionDataTask = [_httpSessionManager DELETE:urlPath
                                               parameters:parameters
                                                  headers:nil
                                                  success:taskCompletion
                                                  failure:taskFailCompletion];
        }
        else if (httpMethod == HMHTTPMethodHEAD)
        {
            sessionDataTask = [_httpSessionManager HEAD:urlPath
                                             parameters:parameters
                                                headers:nil
                                                success:^(NSURLSessionDataTask *task) {
                                                    taskCompletion(task, nil);
                                                }
                                                failure:taskFailCompletion];
        }
        else if (httpMethod == HMHTTPMethodPATCH)
        {
            sessionDataTask = [_httpSessionManager PATCH:urlPath
                                              parameters:parameters
                                                 headers:nil
                                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                                     taskCompletion(task, nil);
                                                 }
                                                 failure:taskFailCompletion];
        }
        
        if (customTimeoutInterval)
        {
            // After serializing the request, configuring back the request serializer with the original timeout interval.
            _requestSerializer.timeoutInterval = timeoutInterval;
        }
    }
    
    if ((_logLevel & HMClientLogLevelRequests) != 0)
    {
#if TARGET_OS_IOS
        // If enabled, logging a CURL of the request
        NSString *curl = [TTTURLRequestFormatter cURLCommandFromURLRequest:sessionDataTask.originalRequest];
        NSLog(@"[ApiClient] REQUEST:\n%@\n%@\n\n", request.description, curl);
#else
        // If enabled, logging the request description
        NSLog(@"[ApiClient] REQUEST:\n%@\n\n", request.description);
#endif
    }
    
    // Finally, setting the original NSURLRequest tot the HMRequest for later inspection.
    request.finalURLRequest = sessionDataTask.originalRequest;
}

@end
