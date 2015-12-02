//
//  MCModelSQLBuilder.h
//  MCModel
//
//  Created by ~DD~ on 15/11/30.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCModelMap.h"

/**
 Builder to compose SQL statement.
 */
@interface MCModelSQLBuilder : NSObject

+ (instancetype)defaultBuilder;

/**
 @brief compose create table sql,now only support single primary key.
 */
- (NSString *)createTableSQLWith:(NSObject<MCModelTable> *)object;

/**
 @brief compose insert into sql.
 */
- (NSString *)insertIntoSQLWith:(NSObject<MCModelTable> *)object;

/**
 @brief compose select single row sql.
 @param object which contains arg.
 */
- (NSString *)selectSingleRowSQLWith:(NSObject<MCModelTable> *)object;

/**
 @brief compose update single row sql.
 @param object which contains update values;
 */
- (NSString *)updateSQLWith:(NSObject<MCModelTable> *)object;

/**
 @brief compose delete single row sql.
 */
- (NSString *)deleteSQLWith:(NSObject<MCModelTable> *)object;

@end
