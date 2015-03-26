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

#import "MJApiResponse.h"

@implementation MJApiResponse

- (id)init
{
    return [self initWithRequest:nil httpResponse:nil responseObject:nil];
}

- (id)initWithRequest:(MJApiRequest*)request httpResponse:(NSHTTPURLResponse*)response error:(NSError*)error
{
    self = [super init];
    if (self)
    {
        _error = error;
        _request = request;
        _httpResponse = response;
        _responseObject = nil;
    }
    return self;
}

- (id)initWithRequest:(MJApiRequest*)request httpResponse:(NSHTTPURLResponse*)response responseObject:(id)responseObject
{
    self = [super init];
    if (self)
    {
        _error = nil;
        _request = request;
        _httpResponse = response;
        _responseObject = responseObject;
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"\n\nREQUEST: %@\n\nERROR: %@\n\nHTTP RESPONSE: %@\n\nOBJECT: %@\n\n", _request.description, _error.description, _httpResponse.description, [_responseObject description]];
}

@end
