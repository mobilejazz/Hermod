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
    return [self initWithRequest:nil httpResponse:nil object:nil error:nil];
}

- (id)initWithRequest:(MJApiRequest*)request
         httpResponse:(NSHTTPURLResponse*)response
               object:(id)responseObject
                error:(NSError*)error
{
    self = [super init];
    if (self)
    {
        _error = error;
        _request = request;
        _httpResponse = response;
        _responseObject = responseObject;
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"\n\nREQUEST: %@\n\nERROR: %@\n\nHTTP RESPONSE: %@\n\nOBJECT: %@\n\n",
            _request.description,
            _error.description,
            _httpResponse.description,
            [_responseObject description]
            ];
}

#pragma mark - Protocols
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_error forKey:@"error"];
    [aCoder encodeObject:_request forKey:@"request"];
    [aCoder encodeObject:_httpResponse forKey:@"httpResponse"];
    [aCoder encodeObject:_httpResponse.URL forKey:@"httpResponse.url"];
    [aCoder encodeInteger:_httpResponse.statusCode forKey:@"httpResponse.statusCode"];
    [aCoder encodeObject:@"HTTP/1.1" forKey:@"httpResponse.version"];
    [aCoder encodeObject:_httpResponse.allHeaderFields forKey:@"httpResponse.headerFields"];
    [aCoder encodeObject:_responseObject forKey:@"responseObject"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _error = [aDecoder decodeObjectForKey:@"error"];
        _request = [aDecoder decodeObjectForKey:@"request"];
        _httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[aDecoder decodeObjectForKey:@"httpResponse.url"]
                                                    statusCode:[aDecoder decodeIntegerForKey:@"httpResponse.statusCode"]
                                                   HTTPVersion:[aDecoder decodeObjectForKey:@"httpResponse.version"]
                                                  headerFields:[aDecoder decodeObjectForKey:@"httpResponse.headerFields"]];
        _responseObject = [aDecoder decodeObjectForKey:@"responseObject"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:_httpResponse.URL
                                                                  statusCode:_httpResponse.statusCode
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:[_httpResponse.allHeaderFields copy]];
    
    MJApiResponse *response = [[MJApiResponse allocWithZone:zone] initWithRequest:[_request copy]
                                                                     httpResponse:httpResponse
                                                                           object:[_responseObject copy]
                                                                            error:[_error copy]];
    
    return response;
}

@end
