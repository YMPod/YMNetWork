//
//  YMCallBackDataValidatorProtocol.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YMBaseAPIManager;

@protocol YMCallBackDataValidatorProtocol <NSObject>

/**
 *  全局网络数据验证拦截器
 */
- (BOOL)globalRemoteDateValidator:(id)remoteData manager:(YMBaseAPIManager *)apiManager;


@end
