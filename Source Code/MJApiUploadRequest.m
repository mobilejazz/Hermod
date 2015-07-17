//
//  MJApiUploadRequest.m
//  TASK.IO
//
//  Created by Joan Martin on 09/03/15.
//  Copyright (c) 2015 TASKDOTIO LTD. All rights reserved.
//

#import "MJApiUploadRequest.h"
#import "NSString+MJApiClientMD5Hashing.h"

@implementation MJApiUploadTask

+ (MJApiUploadTask*)taskWithData:(NSData*)data fieldName:(NSString*)fieldName filename:(NSString*)filename mimeType:(NSString*)mimeType
{
    MJApiUploadTask *task = [[MJApiUploadTask alloc] initWithData:data fieldName:fieldName filename:filename mimeType:mimeType];
    return task;
}

- (id)init
{
    return [self initWithData:nil fieldName:nil filename:nil mimeType:@"application/octet-stream"];
}

- (id)initWithData:(NSData*)data fieldName:(NSString*)fieldName filename:(NSString*)filename mimeType:(NSString*)mimeType
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
    return [[identifier md5_stringWithMD5Hash] hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:MJApiUploadTask.class])
    {
        MJApiUploadTask *task = object;
        
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

@implementation MJApiUploadRequest

- (id)init
{
    self = [super init];
    if (self)
    {
        self.httpMethod = HTTPMethodPOST;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    BOOL sameRequest = [super isEqual:object];
    
    if (sameRequest)
    {
        if ([object isKindOfClass:MJApiUploadRequest.class])
        {
            MJApiUploadRequest *request = object;
            
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
    
    [uploadTasks enumerateObjectsUsingBlock:^(MJApiUploadTask *task, NSUInteger idx, BOOL *stop) {
        [string appendFormat:@":%@:%@:%@:%lu",task.fieldName, task.filename, task.mimeType, (unsigned long)task.data.hash];
    }];
    
    return [string md5_stringWithMD5Hash];
}

@end
