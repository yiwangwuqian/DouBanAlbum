//
//  DBADataResult.h
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBADataResult;
typedef void(^DBADataResultLoadedBufferBlock) (NSObject<DBADataResult> *sender);
@protocol DBADataResult <NSObject>

/**
 @brief validate result's structure.
 */
- (id)validateResult:(id)result withError:(NSError **)error;

/**
 @brief store result into DB or local.
 */
- (void)storeResult:(id)result withError:(NSError **)error;

/**
 @brief load stored result from DB or local.
 */
- (void)loadBufferDataWithCompletion:(DBADataResultLoadedBufferBlock)completion;

@end

@interface DBADataResult : NSObject<DBADataResult>

@end
