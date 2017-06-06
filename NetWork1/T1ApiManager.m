//
//  T1ApiManager.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "T1ApiManager.h"
#import "T1Service.h"

@implementation T1ApiManager

- (NSString *)methodName{
    return @"/v3/stadium/api/stadiums/stadiumItems?pageNo=1&pageSize=10";
}

- (NSString *)serviceType{
    return NSStringFromClass([T1Service class]);
}

- (NSString *)requestType{
    return @"GET";
}

@end
