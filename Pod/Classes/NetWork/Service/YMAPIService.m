//
//  YMAPIService.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "YMAPIService.h"

@implementation YMAPIService

- (instancetype)init{
    if (self = [super init]) {
        if ([self conformsToProtocol:@protocol(YMAPIServiceProtocol) ]) {
            self.child = (id<YMAPIServiceProtocol>)self;
        }
    }
    return self;
}

- (NSString *)apiBaseUrl{
    return self.child.isOnline ? self.child.onlineApiBaseUrl:self.child.offlineApiBaseUrl;
}
@end
