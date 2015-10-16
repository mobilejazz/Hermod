//
//  MJHTTPSessionManager.m
//  ApiClient
//
//  Created by Paolo Tagliani on 07/08/15.
//  Copyright (c) 2015 Mobile Jazz. All rights reserved.
//

#import "MJHTTPOfflineCacheSessionManager.h"

@implementation MJHTTPOfflineCacheSessionManager

+ (instancetype)sharedOperationManager
{
    static MJHTTPOfflineCacheSessionManager *_sharedOperationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedOperationManager = (MJHTTPOfflineCacheSessionManager *) [[[self class] alloc] init];
    });
    
    return _sharedOperationManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self)
    {
         [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
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
    switch (self.reachabilityManager.networkReachabilityStatus) {
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
