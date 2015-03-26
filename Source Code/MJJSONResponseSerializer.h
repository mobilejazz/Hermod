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

#import "AFURLResponseSerialization.h"

/**
 * The key of the HTTP response body that will be added in the `NSError` when a request failes.
 **/
extern NSString * const MJJSONResponseSerializerBodyKey;

/**
 * This subclass of AFJSONResponseSerializer includes inside the `userInfo` dictionary of the errors of network responses the JSON body of the request response.
 * Use the key `MJJSONResponseSerializerBodyKey` to access to the JSON response object in the `NSError`'s `userInfo` dictionary.
 **/
@interface MJJSONResponseSerializer : AFJSONResponseSerializer

@end
