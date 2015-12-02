//
//  DBABaseDAO.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBABaseDAO.h"
#import "DBAHTTPRequestManager.h"

@implementation DBABaseDAO

- (id)init
{
    self = [super init];
    if (self){
        _httpMethod = DBADAOHttpMethodGET;
    }
    return self;
}

- (void)requestWithSuccess:(DBADAORequestSuccessBlock)success failure:(DBADAORequestFailureBlock)failure
{
    if (self.requestOperation){
        [self.requestOperation cancel];
        _requestOperation = nil;
    }
    
    if (success){
        self.successBlock = success;
    }
    
    if (failure){
        self.failureBlock = failure;
    }
    
    [self startRequest];
}

- (NSString *)requestURL
{
    return nil;
}

- (NSDictionary *)requestParam
{
    return nil;
}

#pragma mark- Private method

- (NSDictionary *)combinedRequestParam
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if (self.requestParam){
        [param addEntriesFromDictionary:self.requestParam];
    }
    if (self.additionParam){
        [param addEntriesFromDictionary:self.additionParam];
    }
    
    return [param copy];
}

- (void)startRequest
{
    __weak __typeof(self)weakSelf = self;
    switch (self.httpMethod) {
        case DBADAOHttpMethodGET:
        {
            self.requestOperation = [[DBAHTTPRequestManager defaultManager] GET:[self requestURL]
                                                                     parameters:[self combinedRequestParam]
                                                                        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                                            [weakSelf request:operation successResponse:responseObject];
                                                                        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                                                                            [weakSelf request:operation failureResponse:error];
                                                                        }];
        }
            break;
        case DBADAOHttpMethodPOST:
        {
            self.requestOperation = [[DBAHTTPRequestManager defaultManager] POST:[self requestURL]
                                                                      parameters:[self combinedRequestParam]
                                                                         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                                             [weakSelf request:operation successResponse:responseObject];
                                                                         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                                                                             [weakSelf request:operation failureResponse:error];
                                                                         }];
        }
            break;
        default:
            break;
    }
}

- (void)request:(AFHTTPRequestOperation *)operation successResponse:(id)responseObject
{
    if (self.dataResult){
        NSOperation *dataProcessOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSError *validateError = nil;
            id __autoreleasing data= [self.dataResult validateResult:responseObject
                                                           withError:&validateError];
            if (data){
                validateError = nil;
                [self.dataResult storeResult:data
                                   withError:&validateError];
                if(validateError){
                    NSLog(@"%@ store result failure", self.dataResult.class);
                }
                
                if (self.successBlock){
                    self.successBlock(DBADAORequestStatusSuccess,data);
                }
            }else {
                if (self.failureBlock){
                    self.failureBlock(DBADAORequestStatusFailure,validateError?validateError:nil);
                }
            }
        }];
        
        [[[self class] dataProcessOperationQueue] addOperation:dataProcessOperation];
    }else{
        if (self.successBlock){
            self.successBlock(DBADAORequestStatusSuccess,responseObject);
        }
    }
}

- (void)request:(AFHTTPRequestOperation *)operation failureResponse:(NSError *)error
{
    if (self.failureBlock){
        self.failureBlock(DBADAORequestStatusFailure,error);
    }
}

#pragma mark- Private methods

+ (NSOperationQueue *)dataProcessOperationQueue {
    static NSOperationQueue *dataProcessOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataProcessOperationQueue = [[NSOperationQueue alloc] init];
        dataProcessOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return dataProcessOperationQueue;
}

@end
