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

#import <Foundation/Foundation.h>

/**
 * OAuth object configuration.
 */
@interface MJApiOAuthConfiguration : NSObject

/** ************************************************************************************************ **
 * @name JSON Keys
 ** ************************************************************************************************ **/

/** Access Token JSON key. Default value is "access_token". **/
@property (nonatomic, strong) NSString *accessTokenKey;

/** Refresh Token JSON key. Default value is "refresh_token". **/
@property (nonatomic, strong) NSString *refreshTokenKey;

/** Expires In JSON key. Default value is "expires_in". **/
@property (nonatomic, strong) NSString *expiresInKey;

/** Token Type JSON key. Default value is "token_type". **/
@property (nonatomic, strong) NSString *tokenTypeKey;

/** Scope JSON key. Default value is "scope". **/
@property (nonatomic, strong) NSString *scopeKey;

/** ************************************************************************************************ **
 * @name Date Generators
 ** ************************************************************************************************ **/

/**
 * Creates the expiryDate from the expires_in JSON value. Default implementation expect value as a number with the offset from now to the expiry date.
 **/
@property (nonatomic, strong) NSDate* (^expiryDateBlock)(id value);

@end


/**
 * OAuth object.
 */
@interface MJApiOAuth : NSObject <NSCoding>

/** ************************************************************************************************ **
 * @name Initializers
 ** ************************************************************************************************ **/

/**
 * Network resposne initializer.
 * @param JSONDict The JSON dictionary.
 * @param configuration The configuration.
 * @return The initialized instance.
 **/
- (id)initWithJSON:(NSDictionary*)JSONDict configuration:(MJApiOAuthConfiguration*)configuration;

/** ************************************************************************************************ **
 * @name Properties
 ** ************************************************************************************************ **/

/** Access token. **/
@property (nonatomic, strong, readonly) NSString *accessToken;

/** Refresh Token. **/
@property (nonatomic, strong, readonly) NSString *refreshToken;

/** The expiry date. **/
@property (nonatomic, strong, readonly) NSDate *expiryDate;

/** THe token type. **/
@property (nonatomic, strong, readonly) NSString *tokenType;

/** The scope. **/
@property (nonatomic, strong, readonly) NSString *scope;

/** ************************************************************************************************ **
 * @name Methods
 ** ************************************************************************************************ **/

/**
 * Return if the token is valid now.
 * @return YES if valid, NO otherwise.
 * @discussion This method calls `-isValidWithOffset:` with offset 0.
 **/
- (BOOL)isValid;

/**
 * Return if the token is valid now using an offset.
 * @return YES if valid, NO otherwise.
 **/
- (BOOL)isValidWithOffset:(NSTimeInterval)offset;

@end
