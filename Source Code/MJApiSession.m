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

#import "MJApiSession.h"

#import "MJApiClientKeychainManager.h"
#import "NSString+MJApiClientMD5Hashing.h"

@implementation MJApiSessionConfigurator

@end

@implementation MJApiSession
{
    NSOperationQueue *_requestOperationQueue;
    
    MJApiClient *_apiClient;
    NSString *_apiOAuthPath;
    NSString *_clientId;
    NSString *_clientSecret;
    
    NSString *_identifier;
}

- (id)init
{
    return [self initWithConfigurator:nil];
}

- (id)initWithConfigurator:(void (^)(MJApiSessionConfigurator *configurator))configuratorBlock;
{
    self = [super init];
    if (self)
    {
        MJApiSessionConfigurator *configurator = [[MJApiSessionConfigurator alloc] init];
        if (configuratorBlock)
            configuratorBlock(configurator);
        
        // One request at a time.
        _requestOperationQueue = [[NSOperationQueue alloc] init];
        _requestOperationQueue.maxConcurrentOperationCount = 1;
        
        _apiClient = configurator.apiClient;
        _apiOAuthPath = configurator.apiOAuthPath;
        _clientId = configurator.clientId;
        _clientSecret = configurator.clientSecret;
        
        NSString *string = [NSString stringWithFormat:@"host:%@::clientId:%@", _apiClient.host, _clientId];
        _identifier = [string md5_stringWithMD5Hash];

        [self mjz_load];
    }
    return self;
}

#pragma mark Properties

- (void)setOauthForAppAccess:(MJApiSessionOAuth *)oauthForAppAccess
{
    _oauthForAppAccess = oauthForAppAccess;
    [self mjz_refreshApiClientAuthorization];
    [self mjz_save];
}

- (void)setOauthForUserAccess:(MJApiSessionOAuth *)oauthForUserAccess
{
    _oauthForUserAccess = oauthForUserAccess;
    [self mjz_refreshApiClientAuthorization];
    [self mjz_save];
}

#pragma mark Public Methods

- (void)validateOAuth:(void (^)())block
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        // This operation must be alive until the given block can be called safely
        // having a valid token or an error while refreshnig the token happens.
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        void (^endOperation)(BOOL succeed) = ^(BOOL succeed){
            dispatch_semaphore_signal(semaphore);
            
            if ([NSThread isMainThread])
            {
                if (block)
                    block();
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block)
                        block();
                });
            }
        };
        
        if (_oauthForUserAccess != nil)
        {
            // Checking validity of the user oauth token.
            if (_oauthForUserAccess.isValid)
            {
                endOperation(YES);
            }
            else
            {
                [self mjz_refreshToken:_oauthForUserAccess.refreshToken completionBlock:^(MJApiSessionOAuth *oauth, NSError *error) {
                    if (!error)
                        self.oauthForUserAccess = oauth;
                    else
                        self.oauthForUserAccess = nil;
                    
                    endOperation(error == nil);
                }];
            }
        }
        else
        {
            // Checking validity of the app oauth token.
            if (_oauthForAppAccess.isValid)
            {
                endOperation(YES);
            }
            else
            {
                [self mjz_clientCredentialsWithCompletionBlock:^(MJApiSessionOAuth *oauth, NSError *error) {
                    if (!error)
                        self.oauthForAppAccess = oauth;
                    else
                        self.oauthForAppAccess = nil;
                    
                    endOperation(error == nil);
                }];
            }
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        semaphore = NULL;
    }];
    
    [_requestOperationQueue addOperation:operation];
}

- (void)logout
{
    _oauthForAppAccess = nil;
    _oauthForUserAccess = nil;
    
    [self mjz_save];
    [self mjz_refreshApiClientAuthorization];
}

- (void)loginWithUsername:(NSString*)username password:(NSString*)password completionBlock:(void (^)(NSError *error))completionBlock
{
    NSAssert(username != nil, @"username cannot be nil.");
    NSAssert(password != nil, @"password cannot be nil.");
    NSAssert(_apiOAuthPath != nil, @"API OAuth path is not set.");
    NSAssert(_clientId != nil, @"client id is not set.");
    NSAssert(_clientSecret != nil, @"client secret is not set.");
    
    MJApiRequest *request = [MJApiRequest requestWithPath:_apiOAuthPath];
    request.httpMethod = HTTPMethodPOST;
    request.parameters = @{@"username": username,
                           @"password": password,
                           @"grant_type": @"password",
                           @"client_id": _clientId,
                           @"client_secret": _clientSecret,
                           };
    
    [self validateOAuth:^{
        [_apiClient performRequest:request apiPath:nil completionBlock:^(MJApiResponse *response) {
            if (response.error == nil)
            {
                MJApiSessionOAuth *oauth = [[MJApiSessionOAuth alloc] initWithDictionary:response.responseObject];
                self.oauthForUserAccess = oauth;
                
                if (completionBlock)
                    completionBlock(nil);
            }
            else
            {
                if (completionBlock)
                    completionBlock(response.error);
            }
        }];
    }];
}

#pragma mark Private Mehtods

- (NSString*)mjz_keychainOAuthAppKey
{
    NSString *key = [NSString stringWithFormat:@"%@.oauth.app", _identifier];
    return key;
}

- (NSString*)mjz_keychainOAuthUserKey
{
    NSString *key = [NSString stringWithFormat:@"%@.oauth.user", _identifier];
    return key;
}

- (void)mjz_refreshToken:(NSString*)refreshToken completionBlock:(void (^)(MJApiSessionOAuth *oauth, NSError *error))completionBlock
{
    NSAssert(_apiOAuthPath != nil, @"API OAuth path is not set.");
    NSAssert(_clientId != nil, @"client id is not set.");
    NSAssert(_clientSecret != nil, @"client secret is not set.");
    
    MJApiRequest *request = [MJApiRequest requestWithPath:_apiOAuthPath];
    request.httpMethod = HTTPMethodPOST;
    request.parameters = @{@"grant_type": @"refresh_token",
                           @"refresh_token": refreshToken,
                           @"client_id": _clientId,
                           @"client_secret": _clientSecret,
                           };
    
    [_apiClient performRequest:request apiPath:nil completionBlock:^(MJApiResponse *response) {
        if (response.error == nil)
        {
            MJApiSessionOAuth *oauth = [[MJApiSessionOAuth alloc] initWithDictionary:response.responseObject];
            
            if (completionBlock)
                completionBlock(oauth, nil);
        }
        else
        {
            if (completionBlock)
                completionBlock(nil, response.error);
        }
    }];
}

- (void)mjz_clientCredentialsWithCompletionBlock:(void (^)(MJApiSessionOAuth *oauth, NSError *error))completionBlock
{
    NSAssert(_apiOAuthPath != nil, @"API OAuth path is not set.");
    NSAssert(_clientId != nil, @"client id is not set.");
    NSAssert(_clientSecret != nil, @"client secret is not set.");
    
    MJApiRequest *request = [MJApiRequest requestWithPath:_apiOAuthPath];
    request.httpMethod = HTTPMethodPOST;
    request.parameters = @{@"grant_type": @"client_credentials",
                           @"client_id": _clientId,
                           @"client_secret": _clientSecret,
                           };
    
    [_apiClient performRequest:request apiPath:nil completionBlock:^(MJApiResponse *response) {
        if (response.error == nil)
        {
            MJApiSessionOAuth *oauth = [[MJApiSessionOAuth alloc] initWithDictionary:response.responseObject];
            
            if (completionBlock)
                completionBlock(oauth, nil);
        }
        else
        {
            if (completionBlock)
                completionBlock(nil, response.error);
        }
    }];
}

- (void)mjz_load
{
    NSData *appData = [[self mjz_keychainManager] keychainDataForKey:[self mjz_keychainOAuthAppKey]];
    NSData *userData = [[self mjz_keychainManager] keychainDataForKey:[self mjz_keychainOAuthUserKey]];
    
    if (appData)
    {
        MJApiSessionOAuth *appOauth = [NSKeyedUnarchiver unarchiveObjectWithData:appData];
        if (appOauth.accessToken && appOauth.refreshToken)
        {
            _oauthForAppAccess = appOauth;
        }
    }
    
    if (userData) {
        MJApiSessionOAuth *userOauth = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        if (userOauth.accessToken && userOauth.refreshToken)
        {
            _oauthForUserAccess = userOauth;
        }
    }
    
    [self mjz_refreshApiClientAuthorization];
}

- (void)mjz_save
{
    if (_oauthForAppAccess)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_oauthForAppAccess];
        [[self mjz_keychainManager] setKeychainData:data forKey:[self mjz_keychainOAuthAppKey]];
    }
    else
    {
        [[self mjz_keychainManager] removeKeychainEntryForKey:[self mjz_keychainOAuthAppKey]];
    }
    
    if (_oauthForUserAccess)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_oauthForUserAccess];
        [[self mjz_keychainManager] setKeychainData:data forKey:[self mjz_keychainOAuthUserKey]];
    }
    else
    {
        [[self mjz_keychainManager] removeKeychainEntryForKey:[self mjz_keychainOAuthUserKey]];
    }
}

- (void)mjz_refreshApiClientAuthorization
{
    MJApiSessionAccess access = MJApiSessionAccessNone;
    MJApiSessionOAuth *oauth = nil;
    
    if (_oauthForUserAccess.isValid)
    {
        oauth = _oauthForUserAccess;
        access = MJApiSessionAccessUser;
    }
    else if (_oauthForAppAccess.isValid)
    {
        oauth = _oauthForAppAccess;
        access = MJApiSessionAccessApp;
    }
    
    // Set the oauth authorization headers
    if (oauth)
        [_apiClient setBearerToken:oauth.accessToken];
    else
        [_apiClient removeAuthorizationHeaders];
    
    // update the session access flag
    [self willChangeValueForKey:@"sessionAccess"];
    _sessionAccess = access;
    [self didChangeValueForKey:@"sessionAccess"];
}

- (MJApiClientKeychainManager*)mjz_keychainManager
{
    static NSString *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [NSString stringWithFormat:@"%@.%@",[[NSBundle mainBundle] bundleIdentifier], _identifier];
    });
    
    MJApiClientKeychainManager *manager = [MJApiClientKeychainManager managerForService:service];
    return manager;
}

#pragma mark - Protocols
#pragma mark MJApiRequestExecutor

- (void)performRequest:(MJApiRequest *)request completionBlock:(MJApiResponseBlock)completionBlock
{
    [self validateOAuth:^{
        [_apiClient performRequest:request completionBlock:completionBlock];
    }];
}

- (void)performRequest:(MJApiRequest *)request apiPath:(NSString *)apiPath completionBlock:(MJApiResponseBlock)completionBlock
{
    [self validateOAuth:^{
        [_apiClient performRequest:request completionBlock:completionBlock];
    }];
}

@end
