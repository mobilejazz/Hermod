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

#import "HMRequest.h"

/**
 * This class wraps all the fields needed to perform an upload data task.
 **/
@interface HMUploadTask : NSObject

/** ************************************************* **
 * @name Initializers
 ** ************************************************* **/

/**
 * Default initializer.
 * @param data The data to upload.
 * @param fieldName The field name for the upload request.
 * @param filename The filename for the server of the uploaded data.
 * @param mimeType The mimeType of the data beign uploaded.
 * @return An initialized instance.
 **/
+ (HMUploadTask*)taskWithData:(NSData*)data
                    fieldName:(NSString*)fieldName
                     filename:(NSString*)filename
                     mimeType:(NSString*)mimeType;

/** ************************************************* **
 * @name Attributes
 ** ************************************************* **/

/**
 * The data to upload.
 **/
@property (nonatomic, strong) NSData *data;

/**
 * The field name for the upload request.
 **/
@property (nonatomic, strong) NSString *fieldName;

/**
 * The filename for the server of the uploaded data.
 **/
@property (nonatomic, strong) NSString *filename;

/**
 * The mimeType of the data beign uploaded.
 **/
@property (nonatomic, strong) NSString *mimeType;

@end

/**
 * Use this class to perform an upload data task to the server. 
 * @discussion This class by default sets the `HMHTTPMethod` to POST.
 **/
@interface HMUploadRequest : HMRequest

/** ************************************************* **
 * @name Upload Data
 ** ************************************************* **/

/**
 * An array of files to upload.
 **/
@property (nonatomic, strong) NSArray *uploadTasks;

@end
