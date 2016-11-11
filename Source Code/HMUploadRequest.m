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

#import "HMUploadRequest.h"
#import "NSString+HMClientMD5Hashing.h"

@implementation HMUploadTask

+ (HMUploadTask*)taskWithData:(NSData*)data
                    fieldName:(NSString*)fieldName
                     filename:(NSString*)filename
                     mimeType:(NSString*)mimeType
{
    HMUploadTask *task = [[HMUploadTask alloc] initWithData:data
                                                  fieldName:fieldName
                                                   filename:filename
                                                   mimeType:mimeType];
    return task;
}

- (id)init
{
    return [self initWithData:nil
                    fieldName:nil
                     filename:nil
                     mimeType:@"application/octet-stream"];
}

- (id)initWithData:(NSData*)data
         fieldName:(NSString*)fieldName
          filename:(NSString*)filename
          mimeType:(NSString*)mimeType
{
    self = [super init];
    if (self)
    {
        _data = data;
        _fieldName = fieldName;
        _filename = filename;
        _mimeType = mimeType;
    }
    return self;
}

- (NSUInteger)hash
{
    NSString *identifier = [NSString stringWithFormat:@"%@:%@:%lu:%@",_fieldName, _filename, (unsigned long)_data.hash, _mimeType];
    return [[identifier mjz_api_md5_stringWithMD5Hash] hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:HMUploadTask.class])
    {
        HMUploadTask *task = object;
        
        if ([_fieldName isEqualToString:task.fieldName] &&
            [_mimeType isEqualToString:task.mimeType] &&
            [_filename isEqualToString:task.filename] &&
            [_data isEqualToData:task.data])
        {
            return YES;
        }
    }
    
    return NO;
}

@end

@implementation HMUploadRequest

- (id)init
{
    self = [super init];
    if (self)
    {
        self.httpMethod = HMHTTPMethodPOST;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    BOOL sameRequest = [super isEqual:object];
    
    if (sameRequest)
    {
        if ([object isKindOfClass:HMUploadRequest.class])
        {
            HMUploadRequest *request = object;
            
            BOOL isEqual = [_uploadTasks isEqualToArray:request.uploadTasks];
            return isEqual;
        }
    }
    
    return NO;
}

- (NSString*)identifier
{
    NSMutableString *string = [NSMutableString string];
    [string appendString:[super identifier]];
    
    NSArray *uploadTasks = [_uploadTasks sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fieldName" ascending:YES]]];
    
    [uploadTasks enumerateObjectsUsingBlock:^(HMUploadTask *task, NSUInteger idx, BOOL *stop) {
        [string appendFormat:@":%@:%@:%@:%lu",task.fieldName, task.filename, task.mimeType, (unsigned long)task.data.hash];
    }];
    
    return [string mjz_api_md5_stringWithMD5Hash];
}

@end
