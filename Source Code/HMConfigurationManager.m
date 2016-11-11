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

#import "HMConfigurationManager.h"

@interface HMConfiguration ()

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@implementation HMConfiguration

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _scheme = dictionary[@"scheme"];
        if (!_scheme)
        {
            _scheme = @"http";
        }

        _host = dictionary[@"host"];

        if (!_host)
        {
            NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"Must provide a host"
                                                           userInfo:nil];
            @throw exception;
        }

        _path = dictionary[@"path"];

        if (dictionary[@"port"])
        {
            _port = [dictionary[@"port"] integerValue];
        }
        else
        {
            _port = NSNotFound;
        }

        NSMutableDictionary *apiInfo = [dictionary mutableCopy];
        [apiInfo removeObjectForKey:@"host"];
        [apiInfo removeObjectForKey:@"scheme"];
        [apiInfo removeObjectForKey:@"port"];
        [apiInfo removeObjectForKey:@"path"];

        if (apiInfo.count > 0)
        {
            _apiInfo = [apiInfo copy];
        }
    }
    return self;
}

- (NSString *)serverPath
{
    NSMutableString *string = [[NSMutableString alloc] init];

    [string appendString:_scheme];

    if (![_scheme hasSuffix:@"://"])
    {
        [string appendString:@"://"];
    }

    [string appendString:_host];

    if (_port != NSNotFound)
    {
        [string appendFormat:@":%ld", (long)_port];
    }

    return [string copy];
}

- (NSString *)apiPath
{
    NSMutableString *string = [[NSMutableString alloc] init];

    [string appendString:[self serverPath]];

    if (_path.length > 0)
    {
        if (![_path hasPrefix:@"/"])
        {
            [string appendString:@"/"];
        }

        [string appendString:_path];
    }

    return [string copy];
}

@end


@implementation HMConfigurationManager
{
    NSDictionary *_plist;
    NSMutableDictionary *_dictionary;
}

- (id)initWithPlistFileName:(NSString *)fileName
{
    self = [super init];
    if (self)
    {
        _fileName = fileName;

        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
        _plist = [NSDictionary dictionaryWithContentsOfFile:filePath];
        _dictionary = [NSMutableDictionary dictionaryWithCapacity:_plist.count];
    }
    return self;
}

- (HMConfiguration *)configurationForEnvironment:(HMEnvironment *)environment
{
    HMConfiguration *config = _dictionary[environment];

    if (!config)
    {
        NSDictionary *dictionary = _plist[environment];

        if (dictionary)
        {
            config = [[HMConfiguration alloc] initWithDictionary:dictionary];
            _dictionary[environment] = config;
        }
    }

    return config;
}

@end
