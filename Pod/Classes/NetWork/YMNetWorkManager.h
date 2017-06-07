//
//  YMNetWorkManager.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YMRequestGeneratorProtocol.h"
#import "YMCallBackDataValidatorProtocol.h"
#import "YMCacheTimeOutProtocol.h"

/**
 *
 *  用法示例
 *
 *
 *
 *
 */
@interface YMNetWorkManager : NSObject

@property (assign,nonatomic,readonly,getter=isLogEnable) BOOL apiLogEnable;
@property (strong,nonatomic) id<YMCallBackDataValidatorProtocol> dataValDelegate;
@property (nonatomic,strong) id<YMCacheTimeOutProtocol> cacheTimeOutDelegate;



+ (instancetype)manager;

/**
 *  设置 global requet 参数
 *  @param reqGenDelegate 实现 YMRequestGeneratorProtocol 的全局配置类
 */
- (void)setRequestGenAOP:(id<YMRequestGeneratorProtocol>)reqGenDelegate;


/**
 *  设置 是否打印网络请求
 *  @param logEnable 是否打印
 */
- (void)confLogEnable:(BOOL)logEnable;


@end
