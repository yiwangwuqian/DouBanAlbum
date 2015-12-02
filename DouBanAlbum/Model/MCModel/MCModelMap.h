//
//  MCModelMap.h
//  MCModel
//
//  Created by ~DD~ on 15/11/30.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#ifndef MCModelMap_h
#define MCModelMap_h

@protocol MCModelMap <NSObject>

//**********************************************//
//Dictionary->Model/Model->Dictionary Method.

/**
 @brief transform from instance to dictionary.
 @return result of transform.
 */
- (NSDictionary *)dictionary;

//Needs implement when map array or dictionary.
@optional
/**
 @brief dictionary corresponding object's class.
 */
- (NSString *)dictionaryMapClassNameForKey:(NSString *)key;

/**
 @brief array contains memeber's class.
 */
- (NSString *)arrayMemberMapClassNameForKey:(NSString *)key;

/**
 @brief map from dictionary alias key.
 */
- (NSString *)fromDictionaryAliasKeyForKey:(NSString *)key;

/**
 @brief map from dictionary alias key.
 */
- (NSString *)toDictionaryAliasKeyForKey:(NSString *)key;

@end

@protocol MCModelTable <MCModelMap>

@required
//**********************************************//
//Model->SQLite Method.

- (NSArray *)primaryKeys;

@end

#endif /* MCModelMap_h */
