//
//  T1Service.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "T1Service.h"

@implementation T1Service

- (NSString *)offlineApiBaseUrl{
    return @"http://tenant.yudingnet.net";
}

- (NSString *)onlineApiBaseUrl{
    return @"http://tenant.yudingnet.net";
}

- (BOOL)isOnline{
    return YES;
}

@end
