//
//  YMAPIService.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>


//所有 Service 的派生类都要符合这个协议
@protocol YMAPIServiceProtocol <NSObject>

@property (nonatomic,readonly) BOOL isOnline;

@property (nonatomic,readonly) NSString *offlineApiBaseUrl;
@property (nonatomic,readonly) NSString *onlineApiBaseUrl;


@end

@interface YMAPIService : NSObject

@property (nonatomic,copy,readonly) NSString *apiBaseUrl;

@property (nonatomic,weak) id<YMAPIServiceProtocol> child;

@end
