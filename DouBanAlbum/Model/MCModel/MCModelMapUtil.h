//
//  MCModelMapUtil.h
//  MCModel
//
//  Created by ~DD~ on 15/11/26.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCModel.h"
#import <objc/runtime.h>

//Map object's class needs conform to Protocol `MCModelMap`

@interface MCModelMapUtil : NSObject

/**
 @brief convinient class method,map an instance of class from dictionary.
 */
+ (id)objectFromDictionary:(NSDictionary *)dictionary withClass:(Class)aClass error:(NSError **)error;

/**
 @brief convinient class method,map an array of instance from dictionary objects.
 */
+ (NSArray *)objectsFromArray:(NSArray *)array withClass:(Class)aClass error:(NSError **)error;

/**
 @brief set property from dictionary.
 */
+ (void)propertyUpdate:(id)object withDictionary:(NSDictionary *)dictionary;

/**
 @brief transform from instance to dictionary.
 */
+ (NSDictionary *)dictionaryWithObject:(id)object;

/**
 @brief transform an array of instance.
 */
+ (NSArray *)dictionarysWithArray:(NSArray *)objects;

/**
 @brief class corresponding every property detail info.
 @return MCModelProperty instance dictionary.
 */
+ (NSDictionary *)classPropertysDictionary:(Class)aClass;

@end