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

#import <Foundation/Foundation.h>

/**
 * A simple keychain manager.
 **/
@interface MJApiClientKeychainManager : NSObject

/**
 * Retrieves the keychain manager for a custom service.
 **/
+ (MJApiClientKeychainManager*)managerForService:(NSString*)service;

/**
 * Retrieves the default keychain manager.
 * @discussion The default keychain manager has the app bundle identifier as its service.
 **/
+ (MJApiClientKeychainManager*)defaultManager;

/**
 * Default initializer.
 * @param service A service name.
 * @return The initialized instance.
 **/
- (id)initWithService:(NSString*)service;

/**
 * The service name.
 **/
@property (nonatomic, strong, readonly) NSString *service;

/**
 * Retrieves the data for the given key.
 * @param key The key.
 * @return The data stored in the keychain.
 **/
- (NSData*)keychainDataForKey:(NSString*)key;

/**
 * Set data for the given key.
 * @param data The data to store.
 * @param key The key.
 **/
- (void)setKeychainData:(NSData*)data forKey:(NSString*)key;

/**
 * Retrieves the string for the given key.
 * @param key The key.
 * @return The string stored in the keychain.
 **/
- (NSString*)keychainValueForKey:(NSString*)key;

/**
 * Set string for the given key.
 * @param string The data to store.
 * @param key The key.
 **/
- (void)setKeychainValue:(NSString*)value forKey:(NSString*)key;

/**
 * Removes any stored data or string for the given key.
 * @param key The key.
 **/
- (void)removeKeychainEntryForKey:(NSString*)key;

@end