//
//  MCModelDBManger.h
//  MCModel
//
//  Created by ~DD~ on 15/11/30.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCModelMap.h"

@interface MCModelDBManger : NSObject


@property (nonatomic,readonly) NSString*         dbFullPath;

+ (instancetype)defaultManager;

/**
 @brief query single row data which match condition.
 */
- (id)querySingleWithObject:(NSObject<MCModelTable> *)object;

/**
 @brief query all row data.
 */
- (NSArray *)queryAll:(NSString *)aTableName withClass:(NSString *)className;

/**
 @brief INSERT/UPDATE object conform to <MCModelTable>.
 */
- (BOOL)saveObject:(NSObject<MCModelTable> *)object;

/**
 @brief save objects conform to <MCModelTable>.
 */
- (BOOL)saveArray:(NSArray *)array;

/**
 @brief DELETE object from which belong table.
 @note suggest first to query after to call.
 */
- (BOOL)deleteObject:(NSObject<MCModelTable> *)object;

@end
