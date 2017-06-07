//
//  NSURLRequest+ymRequestParams.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "NSURLRequest+ymRequestParams.h"
#import <objc/runtime.h>

static void *AIFNetworkingRequestParams;

@implementation NSURLRequest (ymRequestParams)

- (void)setRequestParams:(NSDictionary *)requestParams
{
    objc_setAssociatedObject(self, &AIFNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams
{
    return objc_getAssociatedObject(self, &AIFNetworkingRequestParams);
}


@end
