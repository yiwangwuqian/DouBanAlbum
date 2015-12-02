//
//  DBABaseDAO.h
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DBAHTTPRequestManager.h"
#import "DBACommon.h"
#import "DBADataResult.h"

typedef NS_ENUM(NSUInteger, DBADAOHttpMethod){
    DBADAOHttpMethodGET =   (1),
    DBADAOHttpMethodPOST =  (2),
};

typedef NS_ENUM(NSUInteger, DBADAORequestStatus){
    DBADAORequestStatusSuccess =    (1),
    DBADAORequestStatusFailure =    (2),
};

typedef void(^DBADAORequestSuccessBlock) (DBADAORequestStatus status,id responseData);
typedef void(^DBADAORequestFailureBlock) (DBADAORequestStatus status,NSError *error);

@interface DBABaseDAO : NSObject

@property (nonatomic,strong) AFHTTPRequestOperation*            requestOperation;

@property (nonatomic,assign) DBADAOHttpMethod                   httpMethod;

@property (nonatomic,copy)   NSDictionary*                      additionParam;

@property (nonatomic,weak)   NSObject<DBADataResult>*           dataResult;

@property (nonatomic,copy)   DBADAORequestSuccessBlock          successBlock;

@property (nonatomic,copy)   DBADAORequestFailureBlock          failureBlock;

- (void)requestWithSuccess:(DBADAORequestSuccessBlock)success
                   failure:(DBADAORequestFailureBlock)failure;

- (NSString *)requestURL;

- (NSDictionary *)requestParam;

@end
