//
//  MCModelDBManger.m
//  MCModel
//
//  Created by ~DD~ on 15/11/30.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "MCModelDBManger.h"
#import "FMDB.h"
#import "MCModelSQLBuilder.h"
#import "FMResultSet+MCModel.h"
#import <objc/runtime.h>

NSString *const MCModelDBMangerSharedPath =  @"MCModel.db";

@interface MCModelDBManger()
{
    NSString*         _dbFullPath;
}
@property (nonatomic,strong) FMDatabaseQueue*   sharedDBQueue;

@end

@implementation MCModelDBManger

#pragma mark- Public methods

+ (instancetype)defaultManager
{
    static MCModelDBManger *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
        [manager configureDBFile];
        [manager sharedDBQueue];
    });
    return manager;
}

- (id)querySingleWithObject:(NSObject<MCModelTable> *)object
{
    if (object ==nil || ![object conformsToProtocol:NSProtocolFromString(@"MCModelTable")]){
        return nil;
    }
    
    __block id<MCModelTable> returnObj = nil;
    
    __weak __typeof(self)weakSelf = self;
    [self.sharedDBQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:NSStringFromClass([object class])]){
            FMResultSet *nowRS = [weakSelf resultSet:object
                                                inDB:db];
            if (nowRS && [nowRS next]){
                returnObj = [[[object class] alloc] init];
                [nowRS mc_kvcMagic:returnObj];
            }
            [nowRS close];
        }
    }];
    
    return returnObj;
}

- (NSArray *)queryAll:(NSString *)aTableName withClass:(NSString *)className
{
    Class objectsClass = NSClassFromString(className);
    if (!objectsClass || !class_conformsToProtocol(objectsClass, NSProtocolFromString(@"MCModelTable"))){
        return nil;
    }
    
    __block NSMutableArray *allArray = [[NSMutableArray alloc] init];
    
    __weak __typeof(self)weakSelf = self;
    [self.sharedDBQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:aTableName]){
            FMResultSet *nowRS = [db executeQuery:[weakSelf selectAllSQLWith:aTableName]];
            while (nowRS && [nowRS next]){
                @autoreleasepool {
                    
                    id __autoreleasing object  = [[[objectsClass class] alloc] init];
                    [nowRS mc_kvcMagic:object];
                    [allArray addObject:object];
                    
                }
            }
            [nowRS close];
        }
    }];
    
    return allArray;
}

- (BOOL)saveObject:(NSObject<MCModelTable> *)object
{
    __block BOOL ret = NO;
    
    if (object ==nil || ![object conformsToProtocol:NSProtocolFromString(@"MCModelTable")]){
        return ret;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sharedDBQueue inDatabase:^(FMDatabase *db) {
        ret = [weakSelf saveObject:object
                              inDB:db];
    }];
    
    return ret;
}

- (BOOL)saveArray:(NSArray *)array
{
    __block BOOL ret = NO;
    
    __weak __typeof(self)weakSelf = self;
    [self.sharedDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSObject<MCModelTable> *object in array){
            ret = [weakSelf saveObject:object
                                  inDB:db];
            if (!ret){
                *rollback = YES;
                break;
            }
        }
    }];
    
    return ret;
}

- (BOOL)deleteObject:(NSObject<MCModelTable> *)object
{
    __block BOOL ret = NO;
    
    if (object ==nil || ![object conformsToProtocol:NSProtocolFromString(@"MCModelTable")]){
        return ret;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sharedDBQueue inDatabase:^(FMDatabase *db) {
        ret = [weakSelf toDeleteWith:object
                                inDB:db];
    }];
    
    return ret;
}

#pragma mark- Private methods

+ (NSString *)GetDocumentPath
{
    NSString *path=NSHomeDirectory();
    path = [path stringByAppendingString:@"/Documents/DB"];
    
    return path;
}

- (FMDatabaseQueue *)sharedDBQueue
{
    if (!_sharedDBQueue){
        _sharedDBQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbFullPath];
    }
    
    return _sharedDBQueue;
}

- (NSString *)dbFullPath
{
    if (!_dbFullPath){
        _dbFullPath = [NSString stringWithFormat:@"%@/%@",[[self class] GetDocumentPath],MCModelDBMangerSharedPath];
    }
    
    return _dbFullPath;
}

- (void)configureDBFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *createError = nil;
    if (![fileManager fileExistsAtPath:self.dbFullPath]){
        if(![fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@",[[self class] GetDocumentPath]]
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&createError]){
            NSLog(@"error:%@",[createError localizedDescription]);
        }
        
        [fileManager createFileAtPath:self.dbFullPath
                             contents:nil
                           attributes:nil];
    }
}

- (NSString *)createTableSQLWith:(NSObject<MCModelTable> *)object
{
    NSString *SQL = [[MCModelSQLBuilder defaultBuilder] createTableSQLWith:object];
    return SQL;
}

- (BOOL)toCreateTableWith:(NSObject<MCModelTable> *)object inDB:(FMDatabase *)db
{
    BOOL ret = NO;
    NSString *createSQL = [self createTableSQLWith:object];
    if(createSQL){
        ret = [db executeUpdate:createSQL];
    }
    return ret;
}

- (NSString *)insertIntoSQLWith:(NSObject<MCModelTable> *)object
{
    NSString *SQL = [[MCModelSQLBuilder defaultBuilder] insertIntoSQLWith:object];
    return SQL;
}

- (BOOL)toInsertIntoWith:(NSObject<MCModelTable> *)object inDB:(FMDatabase *)db
{
    BOOL ret = NO;
    NSString *insertSQL = [self insertIntoSQLWith:object];
    
    if(insertSQL){
        ret = [db executeUpdate:insertSQL];
    }
    return ret;
}

- (NSString *)selectSingleRowSQLWith:(NSObject<MCModelTable> *)object
{
    NSString *SQL = [[MCModelSQLBuilder defaultBuilder] selectSingleRowSQLWith:object];
    return SQL;
}

/**
 return if row exist.
 */
- (FMResultSet *)resultSet:(NSObject<MCModelTable> *)object inDB:(FMDatabase *)db
{
    FMResultSet *rs = nil;
    
    NSString *selectSQL = [self selectSingleRowSQLWith:object];
    if(selectSQL){
        rs = [db executeQuery:selectSQL];
    }
    return rs;
}

- (NSString *)updateSQLWith:(NSObject<MCModelTable> *)object
{
    NSString *SQL = [[MCModelSQLBuilder defaultBuilder] updateSQLWith:object];
    return SQL;
}

- (BOOL)toUpdateWith:(NSObject<MCModelTable> *)object inDB:(FMDatabase *)db
{
    BOOL ret = NO;
    
    NSString *updateSQL = [self updateSQLWith:object];
    if(updateSQL){
        ret = [db executeUpdate:updateSQL];
    }
    
    return ret;
}

- (NSString *)deleteSQLWith:(NSObject<MCModelTable> *)object
{
    NSString *SQL = [[MCModelSQLBuilder defaultBuilder] deleteSQLWith:object];
    return SQL;
}

- (BOOL)toDeleteWith:(NSObject<MCModelTable> *)object inDB:(FMDatabase *)db
{
    BOOL ret = NO;
    
    NSString *deleteSQL = [self deleteSQLWith:object];
    if(deleteSQL){
        ret = [db executeUpdate:deleteSQL];
    }
    
    return ret;
}

/**
 @brief save object in specific db.
 */

- (BOOL)saveObject:(NSObject<MCModelTable> *)object inDB:(FMDatabase *)db
{
    BOOL ret = NO;
    __weak __typeof(self)weakSelf = self;
    if (![db tableExists:NSStringFromClass([object class])]){
        //need insert
        ret = [weakSelf toCreateTableWith:object
                                     inDB:db];
        if (ret){
            ret = [weakSelf toInsertIntoWith:object
                                        inDB:db];
        }
    }else{
        FMResultSet *nowRS = [weakSelf resultSet:object
                                            inDB:db];
        if (nowRS && [nowRS next]){
            [nowRS close];
            
            //need update
            ret = [weakSelf toUpdateWith:object
                                    inDB:db];
        }else{
            [nowRS close];
            
            //need insert
            ret = [weakSelf toInsertIntoWith:object
                                        inDB:db];
        }
    }
    
    return ret;
}

- (NSString *)selectAllSQLWith:(NSString *)aTableName
{
    NSString *SQL = [[MCModelSQLBuilder defaultBuilder] selectAllSQLWith:aTableName];
    return SQL;
}

@end
