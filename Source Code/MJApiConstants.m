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

typedef struct _IntStrPair
{
    NSInteger integer;
    char *string;
} IntStrPair;

NSInteger IntStrPairGetIntegerFromString(IntStrPair array [], NSInteger size, NSString *string)
{
    for (int i=0; i<size; ++i)
    {
        IntStrPair it = array[i];
        NSString *str = [[NSString alloc] initWithCString:it.string encoding:NSUTF8StringEncoding];
        
        if ([str isEqualToString:string])
            return it.integer;
    }
    
    return 0;
}

NSString *IntStrPairGetStringFromInt(IntStrPair array [], NSInteger size, NSInteger integer)
{
    for (int i=0; i<size; ++i)
    {
        IntStrPair it = array[i];
        
        if (it.integer == integer)
        {
            NSString *str = [[NSString alloc] initWithCString:it.string encoding:NSUTF8StringEncoding];
            return str;
        }
    }
    
    return nil;
}

static IntStrPair HTTPMethodPair [] = {
    {HTTPMethodGET, "GET"},
    {HTTPMethodPOST, "POST"},
    {HTTPMethodPUT, "PUT"},
    {HTTPMethodDELETE, "DELETE"},
    {HTTPMethodHEAD, "HEAD"}
};

static NSInteger HTTPMethodPairSize = sizeof(HTTPMethodPair)/sizeof(IntStrPair);

HTTPMethod HTTPMethodPairFromNSString(NSString *string)
{
    return (HTTPMethod)IntStrPairGetIntegerFromString(HTTPMethodPair, HTTPMethodPairSize, string);
}

NSString* NSStringFromHTTPMethod(HTTPMethod method)
{
    return IntStrPairGetStringFromInt(HTTPMethodPair, HTTPMethodPairSize, method);
}
