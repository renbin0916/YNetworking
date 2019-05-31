//
//  YServiceFactory.h
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YServiceProtocol.h"
NS_ASSUME_NONNULL_BEGIN

/**
 一个service对象必须准守本协议（为什么呢？为了方便的通过类名，创建类）
 */
@protocol YServiceFactoryDataSource <NSObject>

/*
 * key为service的Identifier
 * value为service的Class的字符串
 */
- (NSDictionary<NSString *, NSString *> *)servicesKindsOfServiceFactory;

@end


/**
 service工厂，但凡通过本类创建的service都将本存储在内存中，便于下一次使用
 */
@interface YServiceFactory : NSObject

/**
 程序启动时需要设置dataSource
 之后在需要的地方可进行更改，不会导致前一个service被销毁
 */
@property (nonatomic, weak) id<YServiceFactoryDataSource> dataSource;

+ (instancetype)shareInstance;

- (id<YServiceProtocol>)serviceWithIdentifer:(NSString *)identifer;

@end

NS_ASSUME_NONNULL_END
