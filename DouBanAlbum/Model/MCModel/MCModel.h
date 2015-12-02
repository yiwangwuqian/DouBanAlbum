//
//  MCModel.h
//  MCModel
//
//  Created by ~DD~ on 15/10/27.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCModelMap.h"

/*
 version:0.1
 --transform from dictionary to MCModel instance;from instance to dictionary.purpose to map Model NSObject.
 */

@interface MCModel : NSObject <MCModelMap>

/**
 @brief init with dictionary which contains property key and value.
 @param dictionary
 @param error,pointer to init error.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;

/**
 @brief transform from instance to dictionary.
 @return result of transform.
 */
- (NSDictionary *)dictionary;

@end

//**********************************************//
//Constant Declare

extern NSString *const MCModelErrorDomain;

extern const NSInteger MCModelErrorNotDictionary;

extern const NSInteger MCModelErrorNotArray;

