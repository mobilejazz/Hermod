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

#import "MJApiClient.h"

#import <AFNetworking/AFNetworking.h>
#import <FormatterKit/TTTURLRequestFormatter.h>

#import "MJJSONResponseSerializer.h"

#import "MJHTTPOfflineCacheSessionManager.h"

@implementation MJAPiClientConfigurator

@end

@interface MJApiClient ()

@end

@implementation MJApiClient
{
    AFHTTPSessionManager *_httpSessionManager;
    
    AFHTTPRequestSerializer *_requestSerializer;
    AFHTTPResponseSerializer *_responseSerializer;
}

- (id)init
{
    [[NSException exceptionWithName:NSInvalidArgumentException
                             reason:@"To init a MJApiClient use the initializer -initWithConfigurator:"
                           userInfo:nil] raise];
    
    return [self initWithHost:@"http://www.mydomain.com" apiPath:nil];
}

- (id)initWithHost:(NSString*)host apiPath:(NSString *)apiPath
{
    return [self initWithConfigurator:^(MJAPiClientConfigurator *configurator) {
        configurator.apiPath = apiPath;
        configurator.host = host;
        configurator.cacheManagement = MJApiClientCacheManagementDefault;
        configurator.requestSerializerType = MJApiClientRequestSerializerTypeJSON;
        configurator.responseSerializerType = MJApiClientResponseSerializerTypeJSON;
    }];
}

- (id)initWithConfigurator:(void (^)(MJAPiClientConfigurator *configurator))configuratorBlock;
{
    if (!configuratorBlock)
    {
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:@"The configurator block cannot be nil!" userInfo:nil];
        @throw exception;
    }
    
    self = [super init];
    if (self)
    {
        MJAPiClientConfigurator *configurator = [MJAPiClientConfigurator new];
        configurator.cacheManagement = MJApiClientCacheManagementDefault;
        configurator.requestSerializerType = MJApiClientRequestSerializerTypeJSON;
        configurator.responseSerializerType = MJApiClientResponseSerializerTypeJSON;
        configurator.timeoutInterval = 60;
        configuratorBlock(configurator);
        
        _host = configurator.host;
        _apiPath = configurator.apiPath;
        _cacheManagement = configurator.cacheManagement;
        _completionBlockQueue = configurator.completionBlockQueue;
        
        // Configuring the cache management
        if (configurator.cacheManagement == MJApiClientCacheManagementOffline)
        {
            _httpSessionManager = [[MJHTTPOfflineCacheSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_host]];
        }
        else
        {
            _httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_host]];
        }
        
        // Request serializer
        if (configurator.requestSerializerType == MJApiClientRequestSerializerTypeJSON)
        {
            _requestSerializer = [[AFJSONRequestSerializer alloc] init];
        }
        else if (configurator.requestSerializerType == MJApiClientRequestSerializerTypeFormUrlencoded)
        {
            _requestSerializer = [[AFHTTPRequestSerializer alloc] init];
            [_requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf8" forHTTPHeaderField:@"Content-Type"];
        }
        
        // Response serializer
        if (configurator.responseSerializerType == MJApiClientResponseSerializerTypeJSON)
        {
            MJJSONResponseSerializer *jsonResponseSerializer = [[MJJSONResponseSerializer alloc] init];
            jsonResponseSerializer.readingOptions = NSJSONReadingAllowFragments;
            _responseSerializer = jsonResponseSerializer;
        }
        else if (configurator.responseSerializerType == MJApiClientResponseSerializerTypeRaw)
        {
            _responseSerializer = [[AFHTTPResponseSerializer alloc] init];
        }
        
        // Configuring timout interval
        _requestSerializer.timeoutInterval = configurator.timeoutInterval;
        
        // Configuring Language
        self.insertAcceptLanguageHeader = YES;
        self.insertLanguageAsParameter = NO;
        self.languageParameterName = @"language";
        
        // Configuring serializers
        _httpSessionManager.requestSerializer = _requestSerializer;
        _httpSessionManager.responseSerializer = _responseSerializer;
    }
    return self;
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

- (NSString*)mjz_urlPathForRequest:(MJApiRequest*)request apiPath:(NSString*)apiPath
{
    if (request)
    {
        if (apiPath.length > 0)
            return [_host stringByAppendingFormat:@"%@/%@", apiPath, request.path];
        else
            return [_host stringByAppendingFormat:@"%@", request.path];
    }
    return nil;
}

- (NSString*)mjz_requestLanguage
{
    return [[NSLocale preferredLanguages] firstObject];
}

#pragma mark - Protocols
#pragma mark MJApiRequestExecutor

- (void)performRequest:(MJApiRequest*)request completionBlock:(MJApiResponseBlock)completionBlock
{
    return [self performRequest:request apiPath:_apiPath completionBlock:completionBlock];
}

- (void)performRequest:(MJApiRequest*)request apiPath:(NSString*)apiPath completionBlock:(MJApiResponseBlock)completionBlock
{
    NSURLSessionDataTask *sessionDataTask = nil;
    
    NSString *urlPath = [self mjz_urlPathForRequest:request apiPath:apiPath];
    NSDictionary *parameters = request.parameters;
    HTTPMethod httpMethod = request.httpMethod;
    
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
    
    void (^taskCompletion)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject)
    {
        didFinish = YES;
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        
        NSError *error = nil;
        if ([_delegate respondsToSelector:@selector(apiClient:errorForResponseBody:httpResponse:incomingError:)])
            error = [_delegate apiClient:self errorForResponseBody:responseObject httpResponse:httpResponse incomingError:nil];
        
        MJApiResponse *response = [[MJApiResponse alloc] initWithRequest:request
                                                            httpResponse:httpResponse
                                                                  object:responseObject
                                                                   error:error];
        
        if ((_logLevel & MJApiClientLogLevelResponses) != 0)
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
    
    void (^taskFailCompletion)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        
        didFinish = YES;
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        
        NSDictionary *body = error.userInfo[MJJSONResponseSerializerBodyKey];
        if (body)
        {
            if ([_delegate respondsToSelector:@selector(apiClient:errorForResponseBody:httpResponse:incomingError:)])
                error = [_delegate apiClient:self errorForResponseBody:body httpResponse:httpResponse incomingError:error];
        }
        
        MJApiResponse *response = [[MJApiResponse alloc] initWithRequest:request
                                                            httpResponse:httpResponse
                                                                  object:body
                                                                   error:error];
        
        if ((_logLevel & MJApiClientLogLevelResponses) != 0)
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
    
    if (httpMethod == HTTPMethodGET)
    {
        sessionDataTask = [_httpSessionManager GET:urlPath
                                        parameters:parameters
                                          progress:nil
                                           success:taskCompletion
                                           failure:taskFailCompletion];
    }
    else if (httpMethod == HTTPMethodPOST)
    {
        if ([request isKindOfClass:MJApiUploadRequest.class])
        {
            MJApiUploadRequest *uploadRequest = (id)request;
            
            NSMutableURLRequest *request = [_httpSessionManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                                       URLString:[[NSURL URLWithString:urlPath relativeToURL:_httpSessionManager.baseURL] absoluteString]
                                                                                                      parameters:parameters
                                                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                           [uploadRequest.uploadTasks enumerateObjectsUsingBlock:^(MJApiUploadTask *task, NSUInteger idx, BOOL *stop) {
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
                                               progress:nil
                                                success:taskCompletion
                                                failure:taskFailCompletion];
        }
    }
    else if (httpMethod == HTTPMethodPUT)
    {
        sessionDataTask = [_httpSessionManager PUT:urlPath
                                        parameters:parameters
                                           success:taskCompletion
                                           failure:taskFailCompletion];
    }
    else if (httpMethod == HTTPMethodDELETE)
    {
        sessionDataTask = [_httpSessionManager DELETE:urlPath
                                           parameters:parameters
                                              success:taskCompletion
                                              failure:taskFailCompletion];
    }
    else if (httpMethod == HTTPMethodHEAD)
    {
        sessionDataTask = [_httpSessionManager HEAD:urlPath
                                         parameters:parameters
                                            success:^(NSURLSessionDataTask *task) {
                                                taskCompletion(task, nil);
                                            }
                                            failure:taskFailCompletion];
    }
    else if (httpMethod == HTTPMethodPATCH)
    {
        sessionDataTask = [_httpSessionManager PATCH:urlPath
                                          parameters:parameters
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 taskCompletion(task, nil);
                                             }
                                             failure:taskFailCompletion];
    }
    
    if ((_logLevel & MJApiClientLogLevelRequests) != 0)
    {
        NSString *curl = [TTTURLRequestFormatter cURLCommandFromURLRequest:sessionDataTask.originalRequest];
        NSLog(@"[ApiClient] REQUEST:\n%@\n%@\n\n", request.description, curl);
    }
    
    request.finalURLRequest = sessionDataTask.originalRequest;
}

@end
