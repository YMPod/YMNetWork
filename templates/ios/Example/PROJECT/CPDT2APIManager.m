//
//  CPDT2APIManager.m
//  PROJECT
//
//  Created by TJ on 2017/6/7.
//  Copyright © 2017年 PROJECT_OWNER. All rights reserved.
//

#import "CPDT2APIManager.h"
#import "CPDT2Service.h"
@implementation CPDT2APIManager


- (NSString *)methodName{
    return @"/v3/dfs/qiniu/upload";
}

- (NSString *)serviceType{
    return NSStringFromClass([CPDT2Service class]);
}

- (NSString *)requestType{
    return @"POST";
}

@end
