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

#import "HMConstants.h"

HMEnvironment * const HMEnvironmentProduction   = @"production";
HMEnvironment * const HMEnvironmentStaging      = @"staging";
HMEnvironment * const HMEnvironmentDevelopment  = @"development";

typedef struct ___HMIntStrPair
{
    NSInteger integer;
    char *string;
} __HMIntStrPair;

NSInteger __HMIntStrPairGetIntegerFromString(__HMIntStrPair array [], NSInteger size, NSString *string)
{
    for (int i=0; i<size; ++i)
    {
        __HMIntStrPair it = array[i];
        NSString *str = [[NSString alloc] initWithCString:it.string encoding:NSUTF8StringEncoding];
        
        if ([str isEqualToString:string])
            return it.integer;
    }
    
    return 0;
}

NSString* __HMIntStrPairGetStringFromInt(__HMIntStrPair array [], NSInteger size, NSInteger integer)
{
    for (int i=0; i<size; ++i)
    {
        __HMIntStrPair it = array[i];
        
        if (it.integer == integer)
        {
            NSString *str = [[NSString alloc] initWithCString:it.string encoding:NSUTF8StringEncoding];
            return str;
        }
    }
    
    return nil;
}

static __HMIntStrPair HMHTTPMethodPair [] = {
    {HMHTTPMethodGET, "GET"},
    {HMHTTPMethodPOST, "POST"},
    {HMHTTPMethodPUT, "PUT"},
    {HMHTTPMethodDELETE, "DELETE"},
    {HMHTTPMethodHEAD, "HEAD"},
    {HMHTTPMethodPATCH, "PATCH"}
};

static NSInteger HMHTTPMethodPairSize = sizeof(HMHTTPMethodPair)/sizeof(__HMIntStrPair);

HMHTTPMethod HMHTTPMethodFromNSString(NSString *string)
{
    return (HMHTTPMethod)__HMIntStrPairGetIntegerFromString(HMHTTPMethodPair, HMHTTPMethodPairSize, string);
}

NSString* NSStringFromHMHTTPMethod(HMHTTPMethod method)
{
    return __HMIntStrPairGetStringFromInt(HMHTTPMethodPair, HMHTTPMethodPairSize, method);
}
