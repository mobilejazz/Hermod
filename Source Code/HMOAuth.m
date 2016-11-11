//
// Copyright 2015 Mobile Jazz SL
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

#import "HMOAuth.h"

@implementation HMOAuthConfiguration

- (id)init
{
    self = [super init];
    if (self)
    {
        _accessTokenKey = @"access_token";
        _refreshTokenKey = @"refresh_token";
        _expiresInKey = @"expires_in";
        _tokenTypeKey = @"token_type";
        _scopeKey = @"scope";
        
        _expiryDateBlock = ^NSDate*(id value) {
            NSTimeInterval timeInterval = [value doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
            return date;
        };
    }
    return self;
}

@end

#pragma mark -

@implementation HMOAuth

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _accessToken = [aDecoder decodeObjectForKey:@"accessToken"];
        _refreshToken = [aDecoder decodeObjectForKey:@"refreshToken"];
        _expiryDate = [aDecoder decodeObjectForKey:@"expiryDate"];
        _tokenType = [aDecoder decodeObjectForKey:@"tokenType"];
        _scope = [aDecoder decodeObjectForKey:@"scope"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_accessToken forKey:@"accessToken"];
    [aCoder encodeObject:_refreshToken forKey:@"refreshToken"];
    [aCoder encodeObject:_expiryDate forKey:@"expiryDate"];
    [aCoder encodeObject:_tokenType forKey:@"tokenType"];
    [aCoder encodeObject:_scope forKey:@"scope"];
}

- (id)initWithJSON:(NSDictionary*)JSONDict configuration:(HMOAuthConfiguration*)configuration;
{
    self = [super init];
    if (self)
    {
        _accessToken = JSONDict[configuration.accessTokenKey];
        _refreshToken = JSONDict[configuration.refreshTokenKey];
        _expiryDate = configuration.expiryDateBlock(JSONDict[configuration.expiresInKey]);
        _tokenType = JSONDict[configuration.tokenTypeKey];
        _scope = JSONDict[configuration.scopeKey];
    }
    return self;
}

#pragma mark Public Methods

- (BOOL)isValid
{
    return [self isValidWithOffset:0];
}

- (BOOL)isValidWithOffset:(NSTimeInterval)offset
{
    return _accessToken.length > 0 && _expiryDate.timeIntervalSinceNow > offset;
}

@end
