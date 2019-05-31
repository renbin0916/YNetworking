//
//  YAPIProxy.m
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//

#import "YAPIProxy.h"

#import <AFNetworking.h>

#import "NSURLRequest+Y.h"

NSString * const kYApiProxyValidateResultKeyResponseObject = @"kYApiProxyValidateResultKeyResponseObject";
NSString * const kYApiProxyValidateResultKeyResponseString = @"kYApiProxyValidateResultKeyResponseString";

@interface YAPIProxy ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManger;
@end

@implementation YAPIProxy

+ (instancetype)sharedInstance {
    static YAPIProxy *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YAPIProxy alloc] init];
        [[AFNetworkReachabilityManager manager] startMonitoring];
    });
    return sharedInstance;
}

- (void)cancelRequstWithRequestID:(NSNumber *)requestID {
    NSURLSessionDataTask *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
    [self updateNetworkActivityIndicator];
}

- (void)cancelRequetWithRequestIDList:(NSArray *)requestIDList {
    for (NSNumber *requesID in requestIDList) {
        [self cancelRequstWithRequestID:requesID];
    }
}

- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(YCallback)success fail:(YCallback)fail {
    __block NSURLSessionDataTask *dataTask  = nil;
    dataTask = [[self sessionManagerWithService:request.y_service]
                dataTaskWithRequest:request
                uploadProgress:nil
                downloadProgress:nil
                completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    NSNumber *requestID = @([dataTask taskIdentifier]);
                    [self.dispatchTable removeObjectForKey:requestID];
                    [self updateNetworkActivityIndicator];
                    //通过request中指向的网络服务提供者，对数据进行初步的处理，返回键值对
                    NSDictionary *result = [request.y_service resultWithResponseObject:responseObject response:response request:request error:&error];
                    YURLResponse *yResponse = [[YURLResponse alloc]
                                               initWithResponseString:result[kYApiProxyValidateResultKeyResponseString]
                                               requestId:requestID
                                               request:request
                                               responseObject:result[kYApiProxyValidateResultKeyResponseObject]
                                               error:error];
                    if (error) {
                        fail ? fail(yResponse) : nil;
                    } else {
                        success ? success(yResponse) : nil;
                    }
                }];
    
    NSNumber *requestID = @([dataTask taskIdentifier]);
    self.dispatchTable[requestID] = dataTask;
    [dataTask resume];
    [self updateNetworkActivityIndicator];
    return requestID;
}

#pragma mark private func

/**
 更新状态栏网络活动显示器的状态
 */
- (void)updateNetworkActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication.sharedApplication.networkActivityIndicatorVisible = self.dispatchTable.count > 0;
    });
}

#pragma mark getter

- (AFHTTPSessionManager *)sessionManagerWithService:(id<YServiceProtocol>)service
{
    AFHTTPSessionManager *sessionManager = nil;
    if ([service respondsToSelector:@selector(sessionManager)]) {
        //假如某个网络请求的SessionManger需要特别的设置，那么可以通过实现YServiceProtocol的-(AFHTTPSessionManager *)sessionManager方法提供一个有特殊设置的AFHTTPSessionManager
        sessionManager = service.sessionManager;
    }
    if (sessionManager == nil) {
        sessionManager = [AFHTTPSessionManager manager];
    }
    return sessionManager;
}

- (NSMutableDictionary *)dispatchTable {
    if (!_dispatchTable) {
        _dispatchTable = [NSMutableDictionary new];
    }
    return _dispatchTable;
}

- (BOOL)isReachable {
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    }
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}
@end
