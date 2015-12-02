//
//  MCModelProperty.h
//  MCModel
//
//  Created by ~DD~ on 15/11/4.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCModelProperty : NSObject

/**
 @brief indicate declared property name.
 */
@property (nonatomic,copy)  NSString*    name;

/**
 @brief indicate whether is kind of class's instance.
 */
@property (nonatomic,assign)BOOL         isObject;

/**
 @brief indicate whether read only.
 */
@property (nonatomic,assign)BOOL         readonly;
/**
 @brief when isObject YES,indicate property declare class.
 */
@property (nonatomic,copy)  NSString*    className;

/**
 @brief when isObject NO,indicate property data type.
 */
@property (nonatomic,copy)  NSString*    objCType;

@end
