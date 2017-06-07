//
//  NSObject+YMAPITools.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "NSObject+YMAPITools.h"

@implementation NSObject (YMAPITools)


- (id)ymApiDefaultValue:(id)defaultData{
    if (![defaultData isKindOfClass:[self class]]) {
        return defaultData;
    }
    
    if ([self ymApiIsEmptyObject]) {
        return defaultData;
    }
    
    return self;
}
- (BOOL)ymApiIsEmptyObject{
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return YES;
        }
    }
    
    return NO;
}


@end
