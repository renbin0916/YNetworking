//
//  YAPIBaseManager.h
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YNetworkingDefines.h"
NS_ASSUME_NONNULL_BEGIN

@interface YAPIBaseManager : NSObject <NSCopying>

#pragma mark 外部使用时关注、和选择设定的属性
///请求结果回调代理
@property (nonatomic, weak) id <YAPIManagerCallBackDelegate> delegate;
///请求参数获取数据源
@property (nonatomic, weak) id <YAPIManagerParamSource> paramSource;
///请求有效性的验证器
@property (nonatomic, weak) id <YAPIManagerValidator> validator;
///请求管理者 传递接口名和请求方法
@property (nonatomic, weak) NSObject <YAPIManager> * child;
///拦截器
@property (nonatomic, weak) id <YAPIMangerInterceptor> interceptor;

#pragma mark 返回数据
@property (nonatomic, strong) YURLResponse * response;
@property (nonatomic, readonly) YAPIManagerErrorType errorType;
@property (nonatomic, copy, readonly) NSString * _Nullable errorMessage;

#pragma mark 请求发起前可能关注的东西
///是否联网
@property (nonatomic, assign, readonly) BOOL isReachable;
///是否正在请求数据
@property (nonatomic, assign, readonly) BOOL isLoading;

#pragma mark 开始请求
- (NSInteger)loadData;

+ (NSInteger)loadDataWithParams:(NSDictionary *)params success:(void (^)(YAPIBaseManager *))successCallBack fail:(void (^)(YAPIBaseManager *))failedCallBack;
#pragma mark 取消请求
- (void)cancelAllRequests;
- (void)cancelRequstWithRequestID:(NSInteger)requestID;

#pragma mark 请求完成

/**
 这个方法在外部显式调用

 是否通过在manger中传递一个reformer，
 请求完成之后直接调用reformer将数据处理完成后，通过callBack回调传回，我还在纠结
 
 @param reformer 数据处理者
 @return 我们最终需要使用到的数据
 */
- (id _Nullable)fetchDataWithReformer:(id<YAPIManagerDataReformer>)reformer;

@end

NS_ASSUME_NONNULL_END
