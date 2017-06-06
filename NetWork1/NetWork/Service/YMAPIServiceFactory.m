//
//  YMAPIServiceFactory.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "YMAPIServiceFactory.h"
@interface YMAPIServiceFactory ()

@property (nonatomic,strong) NSCache *serviceStorage;

@end

@implementation YMAPIServiceFactory
#pragma mark - Lift Cycle
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static YMAPIServiceFactory *factory = nil;
    dispatch_once(&onceToken, ^{
        factory = [[YMAPIServiceFactory alloc] init];
    });
    return factory;
}

#pragma mark - Public Methods
- (YMAPIService<YMAPIServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier{
    if (![self.serviceStorage objectForKey:identifier]) {
        [self.serviceStorage setObject:[self newServiceWithIdentifier:identifier] forKey:identifier];
    }
    return [self.serviceStorage objectForKey:identifier];
}
#pragma mark - Private Methods

- (YMAPIService<YMAPIServiceProtocol> *)newServiceWithIdentifier:(NSString *)identifier{
    
    id service = [[NSClassFromString(identifier) alloc] init];
    
    return service;
}

#pragma mark - Getters and Setters
- (NSCache *)serviceStorage{
    if (!_serviceStorage) {
        _serviceStorage = [[NSCache alloc] init];
        _serviceStorage.countLimit = 5;
    }
    return _serviceStorage;
}
@end
