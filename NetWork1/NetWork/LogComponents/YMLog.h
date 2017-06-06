//
//  YMLog.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YMAPIService.h"
#import "YMAPIResponse.h"
@interface YMLog : NSObject

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request
                        apiName:(NSString *)apiName
                        service:(YMAPIService *)service
                  requestParams:(id)requestParams
                     httpMethod:(NSString *)httpMethod;


+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response
                   resposeString:(NSString *)responseString
                         request:(NSURLRequest *)request
                           error:(NSError *)error;

+ (void)logDebugInfoWithCachedResponse:(YMAPIResponse *)response
                            methodName:(NSString *)methodName
                     serviceIdentifier:(YMAPIService *)service;

@end
