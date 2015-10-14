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

#pragma mark Motis Methods

+ (NSDictionary *)mts_mapping {
    return @{@"access_token": mts_key(accessToken),
             @"refresh_token": mts_key(refreshToken),
             @"expires_in": mts_key(expiryDate),
             @"token_type": mts_key(tokenType),
             @"scope": mts_key(scope),
             };
}

- (void)setNilValueForKey:(NSString *)key {
    // Avoid crash when receiving "null" for a non object property type
}

- (BOOL)validateExpiryDate:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)outError {
    // Converting the expires_in value (numeric value in seconds) to a date of expiry.
    if ([*ioValue isKindOfClass:NSNumber.class])
        *ioValue = [NSDate dateWithTimeIntervalSinceNow:[*ioValue floatValue]];
    
    return [*ioValue isKindOfClass:NSDate.class];
}

#pragma mark Public Methods

- (BOOL)isValid {
    return _accessToken.length > 0 && _expiryDate.timeIntervalSinceNow > 60;
}

@end
