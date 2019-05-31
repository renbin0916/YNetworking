//
//  YURLResponse.h
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YURLResponseStatus)
{
    YURLResponseStatusSuccess,
    YURLResponseStatusErrorTimeout,
    YURLResponseStatusErrorCancel,
    YURLResponseStatusErrorNoNetwork
};

NS_ASSUME_NONNULL_BEGIN

/**
 将网络请求返回的数据做一个最简单的处理，
 生成一个YURLResponse对象，便于之后的数据的传递和进一步处理
 */
@interface YURLResponse : NSObject

@property (nonatomic, assign, readonly) YURLResponseStatus status;
@property (nonatomic, copy, readonly) NSString *contentString;
@property (nonatomic, copy, readonly) id content;
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, copy, readonly) NSURLRequest *request;
@property (nonatomic, copy, readonly) NSData *responseData;
@property (nonatomic, strong, readonly) NSString *errorMessage;
@property (nonatomic, copy) NSDictionary *requestParams;

/**
 将网络请求返回的数据做一个最简单的处理，
 生成一个YURLResponse对象，便于之后的数据的传递和进一步处理
 @param responseString 网络请求提供者对返回的结果处理得到
 @param requestId 网络请求的ID
 @param request 网络请求的URLRequest
 @param responseObject 网络请求返回的数据
 @param error 网络请求返回的错误
 @return YURLResponse对象
 */
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseObject:(id)responseObject error:(NSError * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
