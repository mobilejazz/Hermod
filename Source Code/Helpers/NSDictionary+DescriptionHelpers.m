//
//  NSDictionary+DescriptionHelpers.m
//  Hermod
//
//  Created by Borja Arias Drake on 18/10/2018.
//

#import "NSDictionary+DescriptionHelpers.h"

@implementation NSDictionary (DescriptionHelpers)

- (NSString *)hm_descriptionRemovingKeyPaths:(NSArray <NSString *>*)keyPaths
{
    if (keyPaths == nil || keyPaths.count == 0) {
        return self.description;
    }
    
    NSDictionary *copy = [self hm_deepCopyRemovingKeyPaths:keyPaths currentKeyPath:@""];
    return copy.description;
}

- (NSDictionary *)hm_deepCopyRemovingKeyPaths:(NSArray <NSString *>*)keypathsToRemove currentKeyPath:(NSString *)currentKeyPath
{
    NSMutableDictionary *newDictionary = [NSMutableDictionary new];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        // Generate next keyPath
        NSString *nextKeyPath = [self hm_appendComponent:key toCurrentKeyPath:currentKeyPath];

        // Quit if keypath is in list
        if ([keypathsToRemove containsObject:nextKeyPath]) {
            // Base case
            return;
        }
        
        if (!([obj isKindOfClass:NSDictionary.class] || [obj isKindOfClass:NSMutableDictionary.class])) {
            // Base case
            newDictionary[key] = [obj copy];
            return;
        }
        
        // Recursion step
        newDictionary[key] = [obj hm_deepCopyRemovingKeyPaths:keypathsToRemove currentKeyPath:nextKeyPath];
    }];
    
    return [newDictionary copy];
}

- (NSString *)hm_appendComponent:(NSString *)component toCurrentKeyPath:(NSString *)keyPath
{
    NSString *nextKeyPath = nil;
    if (keyPath.length == 0)
    {
        nextKeyPath = [keyPath stringByAppendingFormat:@"%@", component];
    }
    else
    {
        nextKeyPath = [keyPath stringByAppendingFormat:@".%@", component];
    }
    
    return nextKeyPath;
}

@end
