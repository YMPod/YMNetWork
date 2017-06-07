//
//  NSDictionary+YMAPITools.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (YMAPITools)

- (NSString *)YMAPIDicUrlParamsString;
- (NSString *)YMAPIDicjsonString;
- (NSArray *)YMAPIDicTransformedUrlParamsArray;


@end
