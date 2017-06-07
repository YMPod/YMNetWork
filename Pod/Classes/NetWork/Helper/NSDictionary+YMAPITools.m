//
//  NSDictionary+YMAPITools.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "NSDictionary+YMAPITools.h"

#import "NSArray+YMAPITools.h"
@implementation NSDictionary (YMAPITools)


- (NSString *)YMAPIDicUrlParamsString{
    NSArray *sortedArray = [self YMAPIDicTransformedUrlParamsArray];
    return [sortedArray YMAPIArrayJsonString];
}
- (NSString *)YMAPIDicjsonString{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (NSArray *)YMAPIDicTransformedUrlParamsArray{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@", obj];
        }
        
        if ([obj length] > 0) {
            [result addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    NSArray *sortedResult = [result sortedArrayUsingSelector:@selector(compare:)];
    return sortedResult;
}

@end
