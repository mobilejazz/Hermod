//
//  NSDictionary+DescriptionHelpers.h
//  Hermod
//
//  Created by Borja Arias Drake on 18/10/2018.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DescriptionHelpers)

/**
 Generates a description of the dictionary where there keypaths passed by parameter have been removed.

 @param keyPaths Elements in these keypaths will be removed from the description.
 @return A description of the dictionary without the specified keypaths.
 */
- (NSString *)hm_descriptionRemovingKeyPaths:(NSArray <NSString *>*)keyPaths;

@end
