//
//  MJApiUploadRequest.h
//  TASK.IO
//
//  Created by Joan Martin on 09/03/15.
//  Copyright (c) 2015 TASKDOTIO LTD. All rights reserved.
//

#import "MJApiRequest.h"

/**
 * This class wraps all the fields needed to perform an upload data task.
 **/
@interface MJApiUploadTask : NSObject

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
+ (MJApiUploadTask*)taskWithData:(NSData*)data fieldName:(NSString*)fieldName filename:(NSString*)filename mimeType:(NSString*)mimeType;

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
 * @discussion This class by default sets the `HTTPMethod` to POST.
 **/
@interface MJApiUploadRequest : MJApiRequest

/** ************************************************* **
 * @name Upload Data
 ** ************************************************* **/

/**
 * An array of files to upload.
 **/
@property (nonatomic, strong) NSArray *uploadTasks;

@end
