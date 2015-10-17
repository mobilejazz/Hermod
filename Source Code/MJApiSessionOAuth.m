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

#import "MJApiSessionOAuth.h"

@implementation MJApiSessionOAuth

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
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

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        _accessToken = dictionary[@"access_token"];
        _refreshToken = dictionary[@"refresh_token"];
        _expiryDate = [NSDate dateWithTimeIntervalSinceNow:[dictionary[@"expires_in"] floatValue]];
        _tokenType = dictionary[@"token_type"];
        _scope = dictionary[@"scope"];
                                  
    }
    return self;
}

#pragma mark Public Methods

- (BOOL)isValid {
    return _accessToken.length > 0 && _expiryDate.timeIntervalSinceNow > 60;
}

@end
