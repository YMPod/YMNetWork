//
//  YMNetWorkManager.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "YMNetWorkManager.h"
#import "YMRequestGenerator.h"

@interface YMNetWorkManager()

@property (nonatomic,strong) id<YMRequestGeneratorProtocol> requestGeneratorDelegate;
@property (assign,nonatomic,readwrite,getter=isLogEnable) BOOL apiLogEnable;


@end

@implementation YMNetWorkManager

+ (instancetype)manager{
    static dispatch_once_t onceToken;
    static YMNetWorkManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[YMNetWorkManager alloc] init];
    });
    return manager;
}

- (void)setRequestGenAOP:(id<YMRequestGeneratorProtocol>)reqGenDelegate{
    //保持保证不释放
    self.requestGeneratorDelegate = reqGenDelegate;
    [YMRequestGenerator shareInstance].genDelegate = self.requestGeneratorDelegate;
}

- (void)confLogEnable:(BOOL)logEnable{
    self.apiLogEnable = logEnable;
}

#pragma mark - Getter and Setter

@end
