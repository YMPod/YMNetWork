//
//  CPDT2Service.m
//  PROJECT
//
//  Created by TJ on 2017/6/7.
//  Copyright © 2017年 PROJECT_OWNER. All rights reserved.
//

#import "CPDT2Service.h"

@implementation CPDT2Service

- (NSString *)offlineApiBaseUrl{
    return @"http://dd.yudingnet.net";
}

- (NSString *)onlineApiBaseUrl{
    return @"http://dd.yudingnet.net";
}

- (BOOL)isOnline{
    return YES;
}


@end
