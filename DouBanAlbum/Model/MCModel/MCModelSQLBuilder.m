//
//  MCModelSQLBuilder.m
//  MCModel
//
//  Created by ~DD~ on 15/11/30.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "MCModelSQLBuilder.h"
#import "MCModelMapUtil.h"
#import "MCModelProperty.h"
#import "NSString+SQLEscape.h"

@implementation MCModelSQLBuilder

#pragma mark- Public methods

+ (instancetype)defaultBuilder
{
    static MCModelSQLBuilder *builder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        builder = [[[self class] alloc] init];
    });
    return builder;
}

- (NSString *)createTableSQLWith:(NSObject<MCModelTable> *)object
{
    if (![object respondsToSelector:@selector(primaryKeys)] || ([object respondsToSelector:@selector(primaryKeys)] && [object primaryKeys].count==0)){
        return nil;
    }
    
    NSString *tableName = NSStringFromClass([object class]);
    
    NSString *columnDeclare = @"";
    NSDictionary *propertysDictionary = [MCModelMapUtil classPropertysDictionary:[object class]];
    NSArray *allKeys = [propertysDictionary allKeys];
    BOOL primaryIsSet = NO;
    for (int i=0;i<allKeys.count;i++){
        NSString *key = allKeys[i];
        NSString *currentColumnDeclare = nil;
        MCModelProperty *modelProperty = [propertysDictionary objectForKey:key];
        
        NSString *sqlType = nil;
        if (modelProperty.isObject){
            //property is class type
            sqlType = [[self classToSQLDataTypeDictionary] objectForKey:modelProperty.className];
        }else{
            //property is base type
            sqlType = [[self objCTypeToSQLDataTypeDictionary] objectForKey:modelProperty.objCType];
        }
        
        if (sqlType){
            //property type has validated
            currentColumnDeclare = [NSString stringWithFormat:@"%@ %@", modelProperty.name , sqlType];
        }
        
        if (!primaryIsSet && [object respondsToSelector:@selector(primaryKeys)] && [object primaryKeys].count){
            NSString *primaryKey = [object primaryKeys][0];
            if ([primaryKey respondsToSelector:@selector(isEqualToString:)] && [primaryKey isEqualToString:key]){
                //set primary key
                currentColumnDeclare = [currentColumnDeclare stringByAppendingString:@" NOT NULL PRIMARY KEY"];
                primaryIsSet = YES;
            }
        }
        
        if (currentColumnDeclare){
            columnDeclare = [columnDeclare stringByAppendingString:currentColumnDeclare];
        }
        
        if (i != allKeys.count-1 && currentColumnDeclare){
            //add comma
            columnDeclare = [columnDeclare stringByAppendingString:@","];
        }
    }
    
    NSString *SQL = [NSString stringWithFormat:@"CREATE TABLE %@(%@)", tableName, columnDeclare];
    return SQL;
}

- (NSString *)insertIntoSQLWith:(NSObject<MCModelTable> *)object
{
    if (![object respondsToSelector:@selector(dictionary)]){
        return nil;
    }
    
    NSString *tableName = NSStringFromClass([object class]);
    NSMutableArray *columnArray = [[NSMutableArray alloc] init];
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    
    NSDictionary *propertysDictionary = [MCModelMapUtil classPropertysDictionary:[object class]];
    NSDictionary *valueDictionary = [object dictionary];
    for (NSString *valueKey in valueDictionary){
        NSString *sqlType = nil;
        MCModelProperty *modelProperty = [propertysDictionary objectForKey:valueKey];
        if (modelProperty.isObject){
            //property is class type
            sqlType = [[self classToSQLDataTypeDictionary] objectForKey:modelProperty.className];
        }else{
            //property is base type
            sqlType = [[self objCTypeToSQLDataTypeDictionary] objectForKey:modelProperty.objCType];
        }
        
        if (sqlType){
            [columnArray addObject:valueKey];
            
            NSString *nowColumnValue = [NSString stringWithFormat:@"%@",valueDictionary[valueKey]];
            if (nowColumnValue){
                nowColumnValue = [nowColumnValue stringBySQLEscape];
            }
            nowColumnValue = [NSString stringWithFormat:@"'%@'",nowColumnValue];
            [valueArray addObject:nowColumnValue];
        }
    }
    
    NSString *columnString = [columnArray componentsJoinedByString:@","];
    NSString *valueString = [valueArray componentsJoinedByString:@","];
    NSString *SQL = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)", tableName, columnString, valueString];
    return SQL;
}

- (NSString *)selectSingleRowSQLWith:(NSObject<MCModelTable> *)object
{
    if (![object respondsToSelector:@selector(primaryKeys)] || ([object respondsToSelector:@selector(primaryKeys)] && [object primaryKeys].count==0)){
        return nil;
    }
    
    NSString *primaryKey = [object primaryKeys][0];
    id __autoreleasing primaryKeyValue = nil;
    @try {
        primaryKeyValue = [object valueForKey:primaryKey];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        if (!primaryKeyValue){
            return nil;
        }
    }
    NSString *tableName = NSStringFromClass([object class]);
    NSString *SQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", tableName, primaryKey, primaryKeyValue];
    return SQL;
}

- (NSString *)updateSQLWith:(NSObject<MCModelTable> *)object
{
    if (![object respondsToSelector:@selector(dictionary)]){
        return nil;
    }
    
    if (![object respondsToSelector:@selector(primaryKeys)] || ([object respondsToSelector:@selector(primaryKeys)] && [object primaryKeys].count==0)){
        return nil;
    }
    
    NSMutableArray *columnArray = [[NSMutableArray alloc] init];
    NSDictionary *valueDictionary = [object dictionary];
    NSArray *allKeys = [valueDictionary allKeys];
    NSString *primaryKey = [object primaryKeys][0];
    if (![allKeys containsObject:primaryKey]){
        return nil;
    }
    NSString *tableName = NSStringFromClass([object class]);
    id __autoreleasing primaryKeyValue =[valueDictionary objectForKey:primaryKey];
    NSDictionary *propertysDictionary = [MCModelMapUtil classPropertysDictionary:[object class]];
    for (NSString *valueKey in valueDictionary){
        
        if ([valueKey isEqualToString:primaryKey]){
            continue;
        }
        
        NSString *sqlType = nil;
        MCModelProperty *modelProperty = [propertysDictionary objectForKey:valueKey];
        if (modelProperty.isObject){
            //property is class type
            sqlType = [[self classToSQLDataTypeDictionary] objectForKey:modelProperty.className];
        }else{
            //property is base type
            sqlType = [[self objCTypeToSQLDataTypeDictionary] objectForKey:modelProperty.objCType];
        }
        
        if (sqlType){
            id __autoreleasing value = [valueDictionary objectForKey:valueKey];
            [columnArray addObject:[NSString stringWithFormat:@"%@ = '%@'", valueKey, value]];
        }
    }
    
    NSString *columnString = [columnArray componentsJoinedByString:@","];
    NSString *SQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@='%@'", tableName, columnString, primaryKey, primaryKeyValue];
    return SQL;
}

- (NSString *)deleteSQLWith:(NSObject<MCModelTable> *)object
{
    if (![object respondsToSelector:@selector(primaryKeys)] || ([object respondsToSelector:@selector(primaryKeys)] && [object primaryKeys].count==0)){
        return nil;
    }
    
    NSString *primaryKey = [object primaryKeys][0];
    id __autoreleasing primaryKeyValue =nil;
    @try {
        primaryKeyValue =[object valueForKey:primaryKey];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        if(!primaryKeyValue){
            return nil;
        }
    }
    NSString *tableName = NSStringFromClass([object class]);
    NSString *SQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@'", tableName, primaryKey, primaryKeyValue];
    return SQL;
}

#pragma mark- Private methods

/**
 @brief Class transform to SQL data type.
 
 @note default `NSNumber` to `INTEGER`;
 */
- (NSDictionary *)classToSQLDataTypeDictionary
{
    static NSDictionary *dataTypeDictionary = nil;
    
    if (dataTypeDictionary ==nil){
        dataTypeDictionary = @{@"NSNumber"  :@"INTEGER",
                               @"NSString"  :@"TEXT",
                               @"NSData"    :@"BLOB"};
    }
    
    return dataTypeDictionary;
}

/**
 @brief objCType transform to SQL data type.
 */
- (NSDictionary *)objCTypeToSQLDataTypeDictionary
{
    static NSDictionary *dataTypeDictionary = nil;
    
    if (dataTypeDictionary ==nil){
        dataTypeDictionary = @{[NSString stringWithUTF8String:@encode(BOOL)]                :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(char)]                :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(double)]              :@"REAL",
                               [NSString stringWithUTF8String:@encode(float)]               :@"REAL",
                               [NSString stringWithUTF8String:@encode(int)]                 :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(NSInteger)]           :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(long)]                :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(long long)]           :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(short)]               :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(unsigned char)]       :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(unsigned int)]        :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(NSUInteger)]          :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(unsigned long)]       :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(unsigned long long)]  :@"INTEGER",
                               [NSString stringWithUTF8String:@encode(unsigned short)]      :@"INTEGER"};
    }
    
    return dataTypeDictionary;
}


@end
