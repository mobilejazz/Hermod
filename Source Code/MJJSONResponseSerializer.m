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

#import "MJJSONResponseSerializer.h"

NSString * const MJJSONResponseSerializerBodyKey = @"MJJSONResponseSerializerBodyKey";

@implementation MJJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error])
    {
        if (*error != nil)
        {
            NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
            
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if (jsonObject)
                userInfo[MJJSONResponseSerializerBodyKey] = jsonObject;
            
            *error = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:[userInfo copy]];
        }
        
        return nil;
    }
    
    return [super responseObjectForResponse:response data:data error:error];
}

@end
