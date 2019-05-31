//
//  YNetworkingDefines.h
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//

/**
 定义了一些网络请求中可能包含的枚举值，和网络封装中可能用到的相关协议代理
 */
#ifndef YNetworkingDefines_h
#define YNetworkingDefines_h

#import <UIKit/UIKit.h>
@class YAPIBaseManager;
@class YURLResponse;
/**
 开发环境配置
 */
typedef NS_ENUM(NSUInteger, YServiceAPIEnviroment)
{
    YServiceAPIEnviromentDevelop,    //开发
    YServiceAPIEnviromentPreView, //预发布
    YServiceAPIEnviromentRelease     //发布
};

/**
 网络请求的请求类型
 */
typedef NS_ENUM (NSUInteger, YAPIManagerRequestType)
{
    YAPIManagerRequestTypeGet,
    YAPIManagerRequestTypePost,
    YAPIManagerRequestTypePut,
    YAPIManagerRequestTypeDelete
};


/**
 请求发生错误的类型
 */
typedef NS_ENUM (NSUInteger, YAPIManagerErrorType)
{
    YAPIManagerErrorTypeDefault,         // 未产生网络请求，默认状态
    YAPIManagerErrorTypeCanceled,        // 网络请求取消
    YAPIManagerErrorTypeNeedAccessToken, // 需要重新刷新accessToken
    YAPIManagerErrorTypeNeedLogin,       // 需要登陆
    YAPIManagerErrorTypeSuccess,         // API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    YAPIManagerErrorTypeNoContent,       // API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    YAPIManagerErrorTypeParamsError,     // 参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    YAPIManagerErrorTypeTimeout,         // 请求超时。
    YAPIManagerErrorTypeNoNetWork,       // 网络不通。
    YAPIManagerErrorTypeNoError          // 无错误
};

// 结果
extern NSString * _Nonnull const kYApiProxyValidateResultKeyResponseObject;
extern NSString * _Nonnull const kYApiProxyValidateResultKeyResponseString;

/***************************************************************/

/**
 请求的管理者
 */
@protocol YAPIManager <NSObject>

@required

/**
 接口名称（url地址）
 */
- (NSString *_Nonnull)APIName;

/**
 对应的service标识符
 */
- (NSString *_Nonnull)serviceIdentifier;
- (YAPIManagerRequestType)requestType;

@optional

/**
 处理传入的参数
 --比如针对某个接口需要额外添加一个固定的参数之类的

 @param params 原参数
 @return 处理后的参数
 */
- (NSDictionary *_Nullable)reformParams:(NSDictionary *_Nullable)params;

@end

/***************************************************************/
/**
 拦截器，在请求发出之前和之后拦截并作出需要的操作和处理
 可根据需求增添和实现方法
 */
@protocol YAPIMangerInterceptor <NSObject>

@optional
- (BOOL)manager:(YAPIBaseManager *_Nonnull)manager beforePerformSuccessWithResponse:(YURLResponse *_Nonnull)response;
- (void)manager:(YAPIBaseManager *_Nonnull)manager afterPerformSuccessWithResponse:(YURLResponse *_Nonnull)response;

- (BOOL)manager:(YAPIBaseManager *_Nonnull)manager beforePerformFailWithResponse:(YURLResponse *_Nonnull)response;
- (void)manager:(YAPIBaseManager *_Nonnull)manager afterPerformFailWithResponse:(YURLResponse *_Nonnull)response;

- (BOOL)manager:(YAPIBaseManager *_Nonnull)manager shouldCallAPIWithParams:(NSDictionary *_Nullable)params;
- (void)manager:(YAPIBaseManager *_Nonnull)manager afterCallingAPIWithParams:(NSDictionary *_Nullable)params;
- (void)manager:(YAPIBaseManager *_Nonnull)manager didReceiveResponse:(YURLResponse *_Nullable)response;
@end

/***************************************************************/

/**
 请求数据完成后的回调
 */
@protocol YAPIManagerCallBackDelegate <NSObject>
@required
- (void)managerCallAPIDidSuccess:(YAPIBaseManager * _Nonnull)manager;
- (void)managerCallAPIDidFailed:(YAPIBaseManager * _Nonnull)manager;
@end

/***************************************************************/

/**
 数据处理者---
 将服务器返回的原始数据处理为我们需要的数据类型
 */
@protocol YAPIManagerDataReformer <NSObject>
@required
- (id _Nullable)manager:(YAPIBaseManager * _Nonnull)manager reformData:(NSDictionary * _Nullable)data;
@end

/***************************************************************/

/**
 在请求发起之前对参数有效性进行校验
 在请求返回数据后，对数据有效性进行校验
 */
@protocol YAPIManagerValidator <NSObject>
@required
- (YAPIManagerErrorType)manager:(YAPIBaseManager *_Nonnull)manager
      isCorrectWithCallBackData:(NSDictionary *_Nullable)data;
- (YAPIManagerErrorType)manager:(YAPIBaseManager *_Nonnull)manager
        isCorrectWithParamsData:(NSDictionary *_Nullable)data;
@end

/***************************************************************/

/**
 网络请求的数据源---传递网络请求的参数
 */
@protocol YAPIManagerParamSource <NSObject>
@required
- (NSDictionary *_Nullable)paramsForApi:(YAPIBaseManager *_Nonnull)manager;
@end


#endif /* YNetworkingDefines_h */
