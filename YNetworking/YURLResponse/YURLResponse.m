//
//  YURLResponse.m
//  ControllWebLoad
//
//  Created by r 一 on 5/29/19.
//  Copyright © 2019 r 一. All rights reserved.
//

#import "YURLResponse.h"
#import "NSObject+Y.h"
#import "NSURLRequest+Y.h"
@interface YURLResponse ()

@property (nonatomic, assign, readwrite) YURLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *contentString;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, strong, readwrite) NSString *errorMessage;

@end

@implementation YURLResponse

#pragma mark life cycle
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseObject:(id)responseObject error:(NSError *)error {
    if (self = [super init]) {
        self.contentString = [responseString y_defaultData:@""];
        self.requestId     = requestId.integerValue;
        self.request       = request;
        self.requestParams = request.y_requestParams;
        self.status        = [self responseStatusWithError:error];
        self.content       = responseObject ? responseObject : @{};
        self.errorMessage  = [NSString stringWithFormat:@"%@", error];
    }
    return self;
}

#pragma mark - private methods
- (YURLResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        YURLResponseStatus result = YURLResponseStatusErrorNoNetwork;
        if (error.code == NSURLErrorTimedOut) {
            result = YURLResponseStatusErrorTimeout;
        }
        if (error.code == NSURLErrorCancelled) {
            result = YURLResponseStatusErrorCancel;
        }
        return result;
    } else {
        return YURLResponseStatusSuccess;
    }
}

#pragma mark getter
- (NSData *)responseData {
    if (!_responseData) {
        NSError *error = nil;
        _responseData = [NSJSONSerialization dataWithJSONObject:self.content options:0 error:&error];
        if (error) {
            _responseData =[@"" dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return _responseData;
}
@end
