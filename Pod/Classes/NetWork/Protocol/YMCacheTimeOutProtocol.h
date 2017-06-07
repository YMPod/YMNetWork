//
//  YMCacheTimeOutProtocol.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YMCacheTimeOutProtocol <NSObject>

/**
 *  全局网络缓存数据过期时间
 */
- (NSTimeInterval)globalCacheTimeOut;

@end
