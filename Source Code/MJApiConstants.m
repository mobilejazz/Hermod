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

#import "MJApiConstants.h"

typedef struct ___MJApiIntStrPair
{
    NSInteger integer;
    char *string;
} __MJApiIntStrPair;

NSInteger __MJApiIntStrPairGetIntegerFromString(__MJApiIntStrPair array [], NSInteger size, NSString *string)
{
    for (int i=0; i<size; ++i)
    {
        __MJApiIntStrPair it = array[i];
        NSString *str = [[NSString alloc] initWithCString:it.string encoding:NSUTF8StringEncoding];
        
        if ([str isEqualToString:string])
            return it.integer;
    }
    
    return 0;
}

NSString* __MJApiIntStrPairGetStringFromInt(__MJApiIntStrPair array [], NSInteger size, NSInteger integer)
{
    for (int i=0; i<size; ++i)
    {
        __MJApiIntStrPair it = array[i];
        
        if (it.integer == integer)
        {
            NSString *str = [[NSString alloc] initWithCString:it.string encoding:NSUTF8StringEncoding];
            return str;
        }
    }
    
    return nil;
}

static __MJApiIntStrPair HTTPMethodPair [] = {
    {HTTPMethodGET, "GET"},
    {HTTPMethodPOST, "POST"},
    {HTTPMethodPUT, "PUT"},
    {HTTPMethodDELETE, "DELETE"},
    {HTTPMethodHEAD, "HEAD"},
    {HTTPMethodPATCH, "PATCH"}
};

static NSInteger HTTPMethodPairSize = sizeof(HTTPMethodPair)/sizeof(__MJApiIntStrPair);

HTTPMethod HTTPMethodPairFromNSString(NSString *string)
{
    return (HTTPMethod)__MJApiIntStrPairGetIntegerFromString(HTTPMethodPair, HTTPMethodPairSize, string);
}

NSString* NSStringFromHTTPMethod(HTTPMethod method)
{
    return __MJApiIntStrPairGetStringFromInt(HTTPMethodPair, HTTPMethodPairSize, method);
}
