//
//  YServiceProtocol.h
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "YNetworkingDefines.h"
#import <AFNetworking/AFNetworking.h>

/**
 网络服务提供者必须遵守本协议
 网络服务提供者通过实现协议，为网络请求的发起提供参数
 同时也可以在其中对不同类型的网络请求设置不同的策略
 */
@protocol YServiceProtocol <NSObject>

/**
 APP运行请求发起的环境
 */
@property (nonatomic, assign) YServiceAPIEnviroment apiEnviroment;


/**
 网络请求发起之前，对传入参数进行符合规则的处理，获得一个NSURLRequest

 @param params 参数
 @param APIName 接口名称
 @param requestType 网络请求的方法
 @return NSURLRequest
 */
- (NSURLRequest *)requestWithParams:(NSDictionary *)params
                            APIName:(NSString *)APIName
                        requestType:(YAPIManagerRequestType)requestType;

/**
 处理网络请求返回的数据
 */
- (NSDictionary *)resultWithResponseObject:(id)responseObject
                                  response:(NSURLResponse *)response
                                   request:(NSURLRequest *)request
                                     error:(NSError **)error;

/**
 如果检查错误之后，需要继续走fail路径上报到业务层的，return YES。（例如网络错误等，需要业务层弹框）
 如果检查错误之后，不需要继续走fail路径上报到业务层的，return NO。
 （例如用户token失效，此时挂起API，调用刷新token的API，成功之后再重新调用原来的API。
 那么这种情况就不需要继续走fail路径上报到业务。）
 */
- (BOOL)handleCommonErrorWithResponse:(YURLResponse *)response
                              manager:(YAPIBaseManager *)manager
                            errorType:(YAPIManagerErrorType)errorType;

@optional

/**
 实现本方法，提供一个特殊设置的AFHTTPSessionManager
 */
- (AFHTTPSessionManager *)sessionManager;
@end
