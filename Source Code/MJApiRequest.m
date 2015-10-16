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

#import "MJApiRequest.h"
#import "NSString+MJApiClientMD5Hashing.h"

@implementation MJApiRequest

+ (instancetype)requestWithPath:(NSString*)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    MJApiRequest *request = [[self.class alloc] init];
    request.path = string;
    
    return request;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _httpMethod = HTTPMethodGET;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _parameters = [coder decodeObjectForKey:@"parameters"];
        _httpMethod = [coder decodeIntegerForKey:@"httpMethod"];
        _path = [coder decodeObjectForKey:@"path"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_parameters forKey:@"parameters"];
    [coder encodeInteger:_httpMethod forKey:@"httpMethod"];
    [coder encodeObject:_path forKey:@"path"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    MJApiRequest *request = [[MJApiRequest allocWithZone:zone] init];
    
    request.httpMethod = _httpMethod;
    request.parameters = [_parameters copy];
    request.path = [_path copy];
    
    return request;
}

- (NSUInteger)hash
{
    return [self.identifier hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:MJApiRequest.class])
    {
        MJApiRequest *request = object;
        BOOL sameHash = [self.identifier isEqualToString:request.identifier];
        
        if (!sameHash)
            return NO;
        
        if (request.httpMethod == _httpMethod &&
            [request.path isEqualToString:_path] &&
            [request.parameters isEqualToDictionary:_parameters])
            return YES;
    }
    
    return NO;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - Identifier: %@ | Path: %@, HTTPMethod: %@, Parameters: %@",
            [super description],
            self.identifier,
            _path,
            NSStringFromHTTPMethod(_httpMethod),
            _parameters.description];
}

#pragma mark Public Methods

- (NSString*)identifier
{
    static NSString* (^stringForDictionary)(NSDictionary *dictionary) = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stringForDictionary = ^(NSDictionary *dictionary) {
            NSArray *allKeys = [dictionary.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            NSMutableString *parametersStr = [NSMutableString string];
            [parametersStr appendString:@"["];
            for (NSString *key in allKeys)
            {
                NSString *value = dictionary[key];
                [parametersStr appendFormat:@"%@:%@;", key, value];
            }
            [parametersStr appendString:@"]"];
            return [parametersStr md5_stringWithMD5Hash];
        };
    });
    
    NSString *string;
    if ([_parameters isKindOfClass:[NSDictionary class]])
        string = [NSString stringWithFormat:@"%@/%lu/%@", _path, (unsigned long)_httpMethod, stringForDictionary(_parameters)];
    else
        string = [NSString stringWithFormat:@"%@/%lu/%@", _path, (unsigned long)_httpMethod, _parameters];

    return [string md5_stringWithMD5Hash];
}

@end
