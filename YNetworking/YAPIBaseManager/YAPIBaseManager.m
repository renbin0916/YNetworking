//
//  YAPIBaseManager.m
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//

#import "YAPIBaseManager.h"
#import "YAPIProxy.h"
#import "YServiceFactory.h"
#import "NSURLRequest+Y.h"

@interface YAPIBaseManager ()

@property (nonatomic, strong, readwrite) id fetchedRawData;
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, copy, readwrite) NSString *errorMessage;

@property (nonatomic, readwrite) YAPIManagerErrorType errorType;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *requestIdList;

@property (nonatomic, copy, nullable) void (^successBlock)(YAPIBaseManager *apimanager);
@property (nonatomic, copy, nullable) void (^failBlock)(YAPIBaseManager *apimanager);
@end


@implementation YAPIBaseManager

#pragma mark life cycle
- (instancetype)init
{
    if (self = [super init]) {
        _delegate     = nil;
        _validator    = nil;
        _paramSource  = nil;
        _errorMessage = nil;
        _interceptor  = nil;
        _fetchedRawData = nil;
        _errorType      = YAPIManagerErrorTypeDefault;
        NSAssert([self conformsToProtocol:@protocol(YAPIManager)], @"未遵守YAPIManager协议");
        self.child      = (id <YAPIManager>)self;
    }
    return self;
}

- (void)dealloc {
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark pubic func
- (NSInteger)loadData {
    NSDictionary *params = [self.paramSource paramsForApi:self];
    NSInteger requstId   = [self loadDataWithParams:params];
    return requstId;
}

+ (NSInteger)loadDataWithParams:(NSDictionary *)params
                        success:(void (^)(YAPIBaseManager * _Nonnull))successCallBack
                           fail:(void (^)(YAPIBaseManager * _Nonnull))failedCallBack
{
    return [[[self alloc] init] loadDataWithParams:params
                                           success:successCallBack
                                              fail:failedCallBack];
}

- (void)cancelAllRequests {
    [[YAPIProxy sharedInstance] cancelRequetWithRequestIDList:self.requestIdList];
}

- (void)cancelRequstWithRequestID:(NSInteger)requestID {
    [self removeRequestWithRequestID:requestID];
}

- (id)fetchDataWithReformer:(id<YAPIManagerDataReformer>)reformer {
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        resultData = [reformer manager:self reformData:self.fetchedRawData];
    } else {
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}

#pragma mark about api call
- (NSInteger)loadDataWithParams:(NSDictionary *)params
                        success:(void (^)(YAPIBaseManager * _Nonnull))successCallBack
                           fail:(void (^)(YAPIBaseManager * _Nonnull))failedCallBack
{
    self.successBlock = successCallBack;
    self.failBlock = failedCallBack;
    return [self loadDataWithParams:params];
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params
{
    NSInteger requestID = 0;
    NSDictionary *reformedParams = [self reformParams:params];
    if (reformedParams == nil)
    {
        reformedParams = @{};
    }

    if (YAPIProxy.sharedInstance.isReachable)
    {
        self.isLoading = YES;
        id <YServiceProtocol> service = [[YServiceFactory shareInstance] serviceWithIdentifer:self.child.serviceIdentifier];
        NSURLRequest *request = [service requestWithParams:reformedParams APIName:self.child.APIName requestType:self.child.requestType];
        request.y_service     = service;
        request.y_requestParams = reformedParams;
        //发起网络请求前，可以调用validator验证URL或者请求参数--做任何我们需要做的
        
        //即将发起网络请求，这里可以调用拦截器interceptor对参数、URL进行任何需要的处理
        
        //网络请求发起，返回的是一个经过YAPIProxy初步处理后的YURLResponse对象
        NSNumber *requestID = [[YAPIProxy sharedInstance]
                               callApiWithRequest:request
                               success:^(YURLResponse * _Nonnull response) {
                                   [self successedOnCallingAPI:response];
                               }
                               fail:^(YURLResponse * _Nonnull response) {
                                   YAPIManagerErrorType errorType = YAPIManagerErrorTypeDefault;
                                   if (response.status == YURLResponseStatusErrorCancel) {
                                       errorType = YAPIManagerErrorTypeCanceled;
                                   }
                                   else if (response.status == YURLResponseStatusErrorTimeout) {
                                       errorType = YAPIManagerErrorTypeTimeout;
                                   }
                                   else if (response.status == YURLResponseStatusErrorNoNetwork) {
                                       errorType = YAPIManagerErrorTypeNoNetWork;
                                   }
                                   [self failedOnCallingAPI:response withErrorType:errorType];
                               }];
        
        //网络请求已发出，这里可以调用拦截器interceptor做一些我们需要做的处理
        
        [self.requestIdList addObject:requestID];
        return requestID.integerValue;
    }
    
    [self failedOnCallingAPI:nil withErrorType:YAPIManagerErrorTypeNoNetWork];
    return requestID;
}

- (NSDictionary *)reformParams:(NSDictionary *)params {
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP  = [self methodForSelector:@selector(reformParams:)];
    if (childIMP == selfIMP) {
        return params;
    } else {
        NSDictionary *result = nil;
        result = [self.child reformParams:params];
        if (result) {
            return result;
        }
        return params;
    }
}

#pragma mark api call back
- (void)successedOnCallingAPI:(YURLResponse *)response
{
    self.isLoading = false;
    self.response  = response;
    if (response.content) {
        self.fetchedRawData = [response.content copy];
    } else {
        self.fetchedRawData = [response.responseData copy];
    }
    [self removeRequestWithRequestID:response.requestId];
    
    //调用validator对获得返回数据的有效性进行判断
    YAPIManagerErrorType errorType = [self.validator manager:self isCorrectWithCallBackData:response.content];
    
    //调用interceptor处理一些在收到数据返回时需要做的事情
    
    if (errorType == YAPIManagerErrorTypeNoError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(managerCallAPIDidSuccess:)]) {
                [self.delegate managerCallAPIDidSuccess:self];
            }
            self.successBlock ? self.successBlock(self) : nil;
        });
    } else {
        [self failedOnCallingAPI:response withErrorType:errorType];
    }
}

- (void)failedOnCallingAPI:(YURLResponse *)response withErrorType:(YAPIManagerErrorType)errorType
{
    self.isLoading = NO;
    if (response) {
        self.response = response;
    }
    self.errorType = errorType;
    [self removeRequestWithRequestID:response.requestId];
    
    //根据errorType做出对应的处理
    id <YServiceProtocol> service = [[YServiceFactory shareInstance] serviceWithIdentifer:self.child.serviceIdentifier];
    BOOL shoundContinu = [service handleCommonErrorWithResponse:response manager:self errorType:errorType];
    
    if (!shoundContinu) {
        return;
    }
    
    if (errorType == YAPIManagerErrorTypeNoNetWork) {
        self.errorMessage = @"无网络连接，请检查网络";
    }
    else if (errorType == YAPIManagerErrorTypeTimeout) {
        self.errorMessage = @"请求超时";
    }
    else if (errorType == YAPIManagerErrorTypeCanceled) {
        self.errorMessage = @"您已取消";
    }
    
    //这里依旧可以用拦截器做一些我们在网络请求失败后需要做的事情
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(managerCallAPIDidFailed:)]) {
            [self.delegate managerCallAPIDidFailed:self];
        }
        self.failBlock ? self.failBlock(self) : nil;
    });
}


#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark private func
- (void)removeRequestWithRequestID:(NSInteger)requestID {
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedNumber in self.requestIdList) {
        if ([storedNumber integerValue] == requestID) {
            requestIDToRemove =storedNumber;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
        [[YAPIProxy sharedInstance] cancelRequstWithRequestID:requestIDToRemove];
    }
}


#pragma mark getter
- (NSMutableArray *)requestIdList {
    if (!_requestIdList) {
        _requestIdList = [NSMutableArray new];
    }
    return _requestIdList;
}

- (BOOL)isLoading {
    if (self.requestIdList.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}
@end
