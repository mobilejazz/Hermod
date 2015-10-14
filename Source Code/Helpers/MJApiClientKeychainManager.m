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

#import "MJApiClientKeychainManager.h"

@implementation MJApiClientKeychainManager

#pragma mark Static Methods

+ (MJApiClientKeychainManager*)managerForService:(NSString*)service
{
    __strong static NSMutableDictionary *_managers = nil;
    
    if (!_managers)
        _managers = [NSMutableDictionary dictionary];
    
    id sharedObject = nil;
    
    @synchronized(self)
    {
        sharedObject = [_managers valueForKey:service];
        
        if (!sharedObject)
        {
            sharedObject = [[MJApiClientKeychainManager alloc] initWithService:service];
            [_managers setValue:sharedObject forKey:service];
        }
    }
    
    return sharedObject;
}

+ (MJApiClientKeychainManager*)defaultManager
{
    MJApiClientKeychainManager *manager = [self managerForService:[[NSBundle mainBundle] bundleIdentifier]];
    return manager;
}

#pragma mark Initializers

- (id)initWithService:(NSString*)service
{
    self = [super init];
    if (self)
    {
        _service = service;
    }
    return self;
}

#pragma mark Public Methods

- (NSData*)keychainDataForKey:(NSString*)key
{
    return [self mjz_retrieveFromKeychainDataForKey:key];
}

- (void)setKeychainData:(NSData*)data forKey:(NSString*)key
{
    [self mjz_storeInKeychainData:data forKey:key];
}

- (NSString*)keychainValueForKey:(NSString*)key
{
    NSData *data = [self keychainDataForKey:key];
    
    if (data)
    {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return string;
    }
    
    return nil;
}

- (void)setKeychainValue:(NSString*)value forKey:(NSString*)key
{
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    [self setKeychainData:data forKey:key];
}

- (void)removeKeychainEntryForKey:(NSString*)key;
{
    [self mjz_removeFromKeychainDataForKey:key];
}

#pragma mark Private Methods

- (void)mjz_storeInKeychainData:(NSData*)data forKey:(NSString*)key
{
    if (data == nil)
    {
        [self mjz_removeFromKeychainDataForKey:key];
        return;
    }
    
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          _service, kSecAttrService,
                                          key, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnAttributes,
                                          nil];
    
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    
    // Delete an existing entry first:
    SecItemDelete(query);
    
    // Add the accounts query to the keychain query:
    keychainQuery[(__bridge_transfer NSString *)kSecValueData] = data;
    
    // Add the token data to the keychain
    // Even if we never use resData, replacing with NULL in the call throws EXC_BAD_ACCESS
    CFTypeRef resData = NULL;
    SecItemAdd(query, (CFTypeRef *) &resData);
    
    CFRelease(query);
}

- (NSData*)mjz_retrieveFromKeychainDataForKey:(NSString*)key
{
    NSData *data = nil;
    
    // Build the keychain query
    NSDictionary *keychainQuery = @{(__bridge_transfer NSString *)kSecClass: (__bridge_transfer NSString *)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrService: _service,
                                    (__bridge id)kSecAttrAccount: key,
                                    (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
                                    (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
                                    };
    
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    
    // Get the token data from the keychain
    CFTypeRef resData = NULL;
    
    // Get the token dictionary from the keychain
    if (SecItemCopyMatching(query, (CFTypeRef *) &resData) == noErr)
        data = (__bridge_transfer NSData *)resData;
    
    CFRelease(query);
    
    return data;
}

- (void)mjz_removeFromKeychainDataForKey:(NSString*)key
{
    // Build the keychain query
    NSDictionary *keychainQuery = @{(__bridge_transfer NSString *)kSecClass: (__bridge_transfer NSString *)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrService: _service,
                                    (__bridge id)kSecAttrAccount: key,
                                    (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue
                                    };
    
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    
    SecItemDelete(query);
    CFRelease(query);
}

@end