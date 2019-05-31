//
//  YServiceFactory.m
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//

#import "YServiceFactory.h"

@interface YServiceFactory ()

/**
 存储不同的service
 */
@property (nonatomic, strong) NSMutableDictionary *serviceStorage;

@end

@implementation YServiceFactory

+ (instancetype)shareInstance {
    static YServiceFactory *shareInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstace = [[YServiceFactory alloc] init];
    });
    return shareInstace;
}

- (id<YServiceProtocol>)serviceWithIdentifer:(NSString *)identifer {
    @synchronized (self.dataSource) {
        NSAssert([self.dataSource respondsToSelector:@selector(servicesKindsOfServiceFactory)], @"dataSource必须绑定并实现servicesKindsOfServiceFactory方法");
        if (self.serviceStorage[identifer] == nil) {
            self.serviceStorage[identifer] = [self newServiceWithIdentifer:identifer];
        }
        return self.serviceStorage[identifer];
    }
}

#pragma mark private func
- (id<YServiceProtocol>)newServiceWithIdentifer:(NSString *)identifier
{
    if ([[self.dataSource servicesKindsOfServiceFactory] valueForKey:identifier]) {
        NSString *classString = [[self.dataSource servicesKindsOfServiceFactory] valueForKey:identifier];
        id service = [[NSClassFromString(classString) alloc] init];
        NSString *temp = [NSString stringWithFormat:@"%@未能创建，请检查其servicesKindsOfServiceFactory是否正确", classString];
        NSAssert(service, temp);
        temp = [NSString stringWithFormat:@"%@未遵守YServiceProtocol", classString];
        NSAssert([service conformsToProtocol:@protocol(YServiceProtocol)], temp);
        return service;
    }
    NSAssert(NO, @"找不到对应的Identifer");
    return nil;
}

#pragma mark getter
- (NSMutableDictionary *)serviceStorage {
    if (!_serviceStorage) {
        _serviceStorage = [NSMutableDictionary new];
    }
    return _serviceStorage;
}
@end
