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

#import "MJApiRequestGroup.h"

#import "MJApiClient.h"

@implementation MJApiRequestGroup
{
    NSMutableSet *_set;
}

- (id)init
{
    return [self initWithApiClient:nil];
}

- (id)initWithApiClient:(MJApiClient*)apiClient
{
    self = [super init];
    if (self)
    {
        _apiClient = apiClient;
        _set = [NSMutableSet set];
    }
    return self;
}

- (void)addPerformedRequestWithKey:(NSInteger)key
{
    [_set addObject:@(key)];
}

- (void)cancel
{
    NSArray *keys = [_set allObjects];
    [_set removeAllObjects];
    
    for (NSNumber *value in keys)
        [_apiClient cancelRequestWithIdentifier:value.integerValue];
}

- (void)suspend
{
    NSArray *keys = [_set allObjects];
    for (NSNumber *value in keys)
        [_apiClient suspendRequestWithIdentifier:value.integerValue];
}

- (void)resume
{
    NSArray *keys = [_set allObjects];
    for (NSNumber *value in keys)
        [_apiClient resumeRequestWithIdentifier:value.integerValue];
}

@end
