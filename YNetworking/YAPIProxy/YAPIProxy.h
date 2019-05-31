//
//  YAPIProxy.h
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YURLResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YCallback)(YURLResponse *response);

/**
 网络请求真正的发起者和管理者 
 */
@interface YAPIProxy : NSObject

@property (nonatomic, assign, readonly) BOOL isReachable;

+ (instancetype)sharedInstance;

- (NSNumber *)callApiWithRequest:(NSURLRequest *)request
                         success:(YCallback)success
                            fail:(YCallback)fail;

- (void)cancelRequstWithRequestID:(NSNumber *)requestID;
- (void)cancelRequetWithRequestIDList:(NSArray *)requestIDList;

@end

NS_ASSUME_NONNULL_END
