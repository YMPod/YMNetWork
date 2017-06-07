//
//  YMRequestGeneratorProtocol.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YMRequestGeneratorProtocol <NSObject>

/**
 *  @param method 请求方式
 *  @param host    要访问的主域名
 *  全局参数配置
 */
- (NSDictionary *)globalParamsForMethod:(NSString *)method
                                host:(NSString *)host;

/**
 *  @param method 请求方式
 *  @param host    要访问的主域名
 *  全局请求头参数配置
 */
- (NSDictionary *)globalHeaderFieldsForMethod:(NSString *)method
                                      host:(NSString *)host;


/**
 *  @param method 请求方式
 *  @param host    要访问的主域名
 *  全局请求超时设置
 */
- (NSTimeInterval)globalTimeOutForMethod:(NSString *)method
                                         host:(NSString *)host;


@end
