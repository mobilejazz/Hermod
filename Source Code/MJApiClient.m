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

@implementation MJApiClient
{
    AFHTTPSessionManager *_httpSessionManager;
    NSMutableDictionary *_tasks;
    
    AFJSONRequestSerializer *_jsonRequestSerializer;
    MJJSONResponseSerializer *_jsonResponseSerializer;
}

- (id)init
{
    return [self initWithHost:nil];
}

- (id)initWithHost:(NSString*)host;
{
    self = [super init];
    if (self)
    {
        _host = host;
        _tasks = [NSMutableDictionary dictionary];
        
        _jsonRequestSerializer = [[AFJSONRequestSerializer alloc] init];
        _jsonResponseSerializer = [[MJJSONResponseSerializer alloc] init];
        
        // Allowing fragments on json responses.
        _jsonResponseSerializer.readingOptions = NSJSONReadingAllowFragments;
        
        // Setting the backend return language
        NSString *language = [[NSLocale preferredLanguages] firstObject];
        [_jsonRequestSerializer setValue:language forHTTPHeaderField:@"Accept-Language"];
        
        _httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_host]];
        _httpSessionManager.requestSerializer = _jsonRequestSerializer;
        _httpSessionManager.responseSerializer = _jsonResponseSerializer;
    }
    return self;
}

//#pragma mark Properties

#pragma mark Public Methods

- (void)setBearerToken:(NSString*)token
{
    if (token)
        [_httpSessionManager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    else
        [self removeAuthorizationHeaders];
}

- (void)setBasicAuthWithUsername:(NSString*)username password:(NSString*)password
{
    [_httpSessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
}

- (void)removeAuthorizationHeaders
{
    [_httpSessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
}

- (NSInteger)performRequest:(MJApiRequest*)request completionBlock:(MJApiResponseBlock)completionBlock
{
    return [self performRequest:request apiPath:_apiPath completionBlock:completionBlock];
}

- (NSInteger)performRequest:(MJApiRequest*)request apiPath:(NSString*)apiPath completionBlock:(MJApiResponseBlock)completionBlock
{
    NSURLSessionDataTask *sessionDataTask = nil;
    
    NSString *urlPath = [self mjz_urlPathForRequest:request apiPath:apiPath];
    NSDictionary *parameters = request.parameters;
    HTTPMethod httpMethod = request.httpMethod;
    
    if (!urlPath)
        return NSNotFound;
    
    __block BOOL didFinish = NO;
    
    void (^taskCompletion)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject)
    {
        didFinish = YES;
        [_tasks removeObjectForKey:@(task.taskIdentifier)];
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        
        MJApiResponse *response = [[MJApiResponse alloc] initWithRequest:request httpResponse:httpResponse responseObject:responseObject];
        
        if ((_logLevel & MJApiClientLogLevelResponses) != 0)
        {
            NSLog(@"[ApiClient] RESPONSE: SUCCESS\n%@\n\n", response.description);
        }
        
        if (completionBlock)
            completionBlock(response, task.taskIdentifier);
    };
    
    void (^taskFailCompletion)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        
        didFinish = YES;
        [_tasks removeObjectForKey:@(task.taskIdentifier)];
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        
        NSDictionary *body = error.userInfo[MJJSONResponseSerializerBodyKey];
        
        if (body)
        {
            if ([_delegate respondsToSelector:@selector(apiClient:errorForResponseBody:incomingError:)])
                error = [_delegate apiClient:self errorForResponseBody:body incomingError:error];
        }
        
        MJApiResponse *response = [[MJApiResponse alloc] initWithRequest:request httpResponse:httpResponse error:error];
        response.responseObject = body;
        
        if ((_logLevel & MJApiClientLogLevelResponses) != 0)
        {
            NSLog(@"[ApiClient] RESPONSE: FAILURE\n%@\n\n", response.description);
        }
        
        if (completionBlock)
            completionBlock(response, task.taskIdentifier);
    };
    
    if (httpMethod == HTTPMethodGET)
        sessionDataTask = [_httpSessionManager GET:urlPath parameters:parameters success:taskCompletion failure:taskFailCompletion];
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
            
            sessionDataTask = [_httpSessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                if (error)
                    taskFailCompletion(sessionDataTask, error);
                else
                    taskCompletion(sessionDataTask, responseObject);
            }];
            
            [sessionDataTask resume];
        }
        else
        {
            sessionDataTask = [_httpSessionManager POST:urlPath parameters:parameters success:taskCompletion failure:taskFailCompletion];
        }
    }
    else if (httpMethod == HTTPMethodPUT)
        sessionDataTask = [_httpSessionManager PUT:urlPath parameters:parameters success:taskCompletion failure:taskFailCompletion];
    else if (httpMethod == HTTPMethodDELETE)
        sessionDataTask = [_httpSessionManager DELETE:urlPath parameters:parameters success:taskCompletion failure:taskFailCompletion];
    else if (httpMethod == HTTPMethodHEAD)
        sessionDataTask = [_httpSessionManager HEAD:urlPath parameters:parameters success:^(NSURLSessionDataTask *task) { taskCompletion(task, nil); } failure:taskFailCompletion];
    else if (httpMethod == HTTPMethodPATCH)
        sessionDataTask = [_httpSessionManager PATCH:urlPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) { taskCompletion(task, nil); } failure:taskFailCompletion];

    if ((_logLevel & MJApiClientLogLevelRequests) != 0)
    {
        NSString *curl = [TTTURLRequestFormatter cURLCommandFromURLRequest:sessionDataTask.originalRequest];
        NSLog(@"[ApiClient] REQUEST:\n%@\n%@\n\n", request.description, curl);
    }
    
    request.finalURLRequest = sessionDataTask.originalRequest;
    
    if (sessionDataTask && !didFinish)
    {
        NSInteger identifier = sessionDataTask.taskIdentifier;
        _tasks[@(identifier)] = sessionDataTask;
        return identifier;
    }
    
    return NSNotFound;
}

- (void)cancelRequestWithIdentifier:(NSInteger)identifier
{
    NSURLSessionDataTask *task = _tasks[@(identifier)];
    [_tasks removeObjectForKey:@(identifier)];
    [task cancel];
}

- (void)suspendRequestWithIdentifier:(NSInteger)identifier
{
    NSURLSessionDataTask *task = _tasks[@(identifier)];
    [task suspend];
}

- (void)resumeRequestWithIdentifier:(NSInteger)identifier
{
    NSURLSessionDataTask *task = _tasks[@(identifier)];
    [task resume];
}

- (void)cancelAllRequests
{
    NSArray *tasks = [_tasks allValues];
    [tasks makeObjectsPerformSelector:@selector(cancel)];
    [_tasks removeAllObjects];
}

- (void)suspendAllRequests
{
    NSArray *tasks = [_tasks allValues];
    [tasks makeObjectsPerformSelector:@selector(suspend)];
}

- (void)resumeAllRequests
{
    NSArray *tasks = [_tasks allValues];
    [tasks makeObjectsPerformSelector:@selector(resume)];
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

@end
