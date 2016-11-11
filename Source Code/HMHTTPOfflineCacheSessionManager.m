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

#import "HMHTTPOfflineCacheSessionManager.h"

@implementation HMHTTPOfflineCacheSessionManager

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self)
    {
         [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (self)
    {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithSessionConfiguration:configuration];
    if (self)
    {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

//Override the default data task method and cache it
//A similar approach http://www.hpique.com/2014/03/how-to-cache-server-responses-in-ios-apps/

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler
{
    NSMutableURLRequest *copyRequest = [request mutableCopy];

    //NOTE: you need to setup the reachability manager to make the offline beahaviour to work
    //If the network is unreachable, by default pick up from the cache, no matter expiration date
    switch (self.reachabilityManager.networkReachabilityStatus)
    {
        case AFNetworkReachabilityStatusNotReachable:
            [copyRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
            break;
        case AFNetworkReachabilityStatusUnknown:
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
        default:
            [copyRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
            break;
    }
    
    return [super dataTaskWithRequest:copyRequest completionHandler:completionHandler];
}

@end
