//
//  MCModelMapUtil.m
//  MCModel
//
//  Created by ~DD~ on 15/11/26.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "MCModelMapUtil.h"
#import "MCModelProperty.h"

@implementation MCModelMapUtil

+ (id)objectFromDictionary:(NSDictionary *)dictionary withClass:(Class)aClass error:(NSError *__autoreleasing *)error
{
    if (![dictionary isKindOfClass:NSDictionary.class]){
        
        if(error){
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"It's not dictionary data", @""),
                                       NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"%@ could not be created because init data class: %@", @""), NSStringFromClass(aClass), dictionary.class],
                                       };
            
            *error = [NSError errorWithDomain:MCModelErrorDomain
                                         code:MCModelErrorNotDictionary
                                     userInfo:userInfo];
        }
        return nil;
    }
    
    id __autoreleasing object = [[aClass alloc] init];
    
    [self propertyUpdate:object withDictionary:dictionary];
    
    return object;
}

+ (NSArray *)objectsFromArray:(NSArray *)array withClass:(Class)aClass error:(NSError *__autoreleasing *)error
{
    if (![array isKindOfClass:NSArray.class]){
        if(error){
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"It's not array data", @""),
                                       NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"%@ could not be created because init data class: %@", @""), NSStringFromClass(aClass), array.class],
                                       };
            
            *error = [NSError errorWithDomain:MCModelErrorDomain
                                         code:MCModelErrorNotArray
                                     userInfo:userInfo];
        }
        return nil;
    }
    
    NSMutableArray *objects = nil;
    
    if (array && array.count){
        objects = [[NSMutableArray alloc] init];
    }
    
    for (id dic_obj in array){
        id __autoreleasing mapped_obj = [self objectFromDictionary:dic_obj
                                                         withClass:aClass
                                                             error:nil];
        if (mapped_obj){
            [objects addObject:mapped_obj];
        }
    }
    
    return objects;
}

+ (void)propertyUpdate:(id)object withDictionary:(NSDictionary *)dictionary
{
    NSDictionary *propertysDictionary = [self classPropertysDictionary:[object class]];
    
    for (NSString *key in dictionary){
        id __autoreleasing value = [dictionary objectForKey:key];
        if ([value isEqual:NSNull.null]){value = nil;continue;}
        
        MCModelProperty *property = [propertysDictionary objectForKey:key];
        NSString *valuesKey = nil;//value's key
        if (!property){
            if (![object respondsToSelector:@selector(fromDictionaryAliasKeyForKey:)]){
                continue;
            }
            
            NSString *aliasKey = [object fromDictionaryAliasKeyForKey:key];
            if (aliasKey && aliasKey.length){
                property = [propertysDictionary objectForKey:aliasKey];
            }else{
                continue;
            }
        }
        
        valuesKey = property.name;
        if (!valuesKey || valuesKey.length ==0){
            continue;
        }
        
        if ([value respondsToSelector:@selector(isEqualToDictionary:)]){
            //NSDictionary
            NSString *value_className = nil;
            if (property.isObject && property.className.length){
                //Declare class explicitly
                value_className = property.className;
            }else if (property.isObject && [object respondsToSelector:@selector(dictionaryMapClassNameForKey:)]){
                //Declare class by dictionaryMapClassNameForKey:
                value_className = [object dictionaryMapClassNameForKey:valuesKey];
            }
            Class value_class = NSClassFromString(value_className);
            if (value_class){
                value = [self objectFromDictionary:value
                                         withClass:value_class
                                             error:nil];
            }
        }else if([value respondsToSelector:@selector(isEqualToArray:)]){
            //NSArray
            NSString *value_className = nil;
            if (property.isObject && [object respondsToSelector:@selector(arrayMemberMapClassNameForKey:)]){
                //Declare class by arrayMemberMapClassNameForKey:
                value_className = [object arrayMemberMapClassNameForKey:valuesKey];
            }
            Class value_class = NSClassFromString(value_className);
            if (value_class){
                value = [self objectsFromArray:value
                                     withClass:value_class
                                         error:nil];
            }
        }
        
        if (![self validateValue:value
                    forProperty:property]){
            continue;
        }
        
        NSString *processed_key = valuesKey;
        processed_key = [processed_key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                               withString:[[processed_key substringToIndex:1] uppercaseString]];
        NSString *selName = [NSString stringWithFormat:@"set%@:",processed_key];
        SEL setSel = NSSelectorFromString(selName);
        if ([object respondsToSelector:setSel]){
            [object setValue:value
                      forKey:valuesKey];
        }
    }
}

+ (NSDictionary *)dictionaryWithObject:(id)object
{
    NSDictionary *propertysDictionary = [self classPropertysDictionary:[object class]];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *key in propertysDictionary){
        id __autoreleasing value = [object valueForKey:key];
        if (!value){
            value = NSNull.null;
            continue;
        }
        
        if ([value conformsToProtocol:NSProtocolFromString(@"MCModelMap")]){
            //conforms to MCModelMap
            value = [self dictionaryWithObject:value];
        }else if([value respondsToSelector:@selector(isEqualToArray:)]){
            //NSArray
            value = [self dictionarysWithArray:value];
        }
        
        if ([object respondsToSelector:@selector(toDictionaryAliasKeyForKey:)]){
            NSString *aliasKey = [object toDictionaryAliasKeyForKey:key];
            if (aliasKey && aliasKey.length){
                [object setValue:value
                          forKey:aliasKey];
                continue;
            }
        }
        
        [dictionary setValue:value
                      forKey:key];
    }
    
    return dictionary;
}

+ (NSArray *)dictionarysWithArray:(NSArray *)objects
{
    NSMutableArray *dictionarys = [[NSMutableArray alloc] init];
    
    for (id anObj in objects){
        if ([anObj conformsToProtocol:NSProtocolFromString(@"MCModelMap")]){
            [dictionarys addObject:[self dictionaryWithObject:anObj]];
        }else{
            [dictionarys addObject:anObj];
        }
    }
    
    return dictionarys;
}

+ (NSDictionary *)classPropertysDictionary:(Class)aClass
{
    NSMutableDictionary *propertysDictionary = [[NSMutableDictionary alloc] init];
    
    if ([aClass superclass]) {
        [propertysDictionary addEntriesFromDictionary:[self classPropertysDictionary:[aClass superclass]]];
    }else if (aClass == [NSObject class]){
        return [NSDictionary dictionary];
    }
    
    unsigned int p_count=0;
    objc_property_t *p_list = class_copyPropertyList([aClass class], &p_count);
    
    for (int i=0;i<p_count;i++){
        objc_property_t a_property = p_list[i];
        MCModelProperty *model_property = [[MCModelProperty alloc] init];
        
        [self initPropertyInstance:model_property
                     byPropertyVar:a_property];
        
        if (model_property.readonly){
            continue;
        }
        [propertysDictionary setObject:model_property
                                forKey:model_property.name];
    }
    
    free(p_list);
    
    return propertysDictionary;
}

#pragma mark- Private methods

/**
 @brief class corresponding property names.
 */
+ (NSArray *)classPropertyNameArray:(Class)aClass
{
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    
    if ([aClass superclass]) {
        [propertyNames addObjectsFromArray:[self classPropertyNameArray:[aClass superclass]]];
    }else if (aClass == [NSObject class]){
        return [NSArray array];
    }
    
    unsigned int p_count=0;
    objc_property_t *p_list = class_copyPropertyList([aClass class], &p_count);
    
    for (int i=0;i<p_count;i++){
        objc_property_t a_property = p_list[i];
        NSString *p_name = [NSString stringWithUTF8String:property_getName(a_property)];
        [propertyNames addObject:p_name];
    }
    
    free(p_list);
    
    return propertyNames;
}

/**
 @brief class corresponding every property detail info.
 @return MCModelProperty instance array.
 */
+ (NSArray *)classPropertysArray:(Class)aClass
{
    NSMutableArray *propertyArray = [[NSMutableArray alloc] initWithArray:[[self classPropertysDictionary:aClass] allValues]];
    return propertyArray;
}

/**
 @brief class corresponding property names.
 @return nil when not a class instance,length 0 when declare `id`.
 */
NSString *property_getClassName(objc_property_t property)
{
    if (!property){
        return nil;
    }
    
    NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
    //    NSAssert(![[attributes substringToIndex:1] isEqualToString:@"T"], @"property attributes must be start with `T`");
    assert([[attributes substringToIndex:1] isEqualToString:@"T"]);
    
    NSString *className = nil;
    
    if (![[attributes substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"@"]){
        return className;
    }
    
    NSRange firstCommaRange = [attributes rangeOfString:@","];
    
    if (firstCommaRange.location != NSNotFound){
        NSString *firstComponent = [attributes substringToIndex:firstCommaRange.location];
        if (firstComponent.length >4){
            //firstComponent pattern T@"ClassName"
            className = [firstComponent substringWithRange:NSMakeRange(3, firstComponent.length -4)];
        }else if (firstComponent.length ==2){
            //firstComponent equal T@
            className = @"";
        }
    }
    
    return className;
}

/**
 @brief property whether readonly.
 @return YES/NO.
 */
BOOL property_isReadOnly(objc_property_t property)
{
    NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
    if ([attributes rangeOfString:@",R"].location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}

/**
 @brief init MCModelProperty instance by objc_property_t var.
 */
+ (void)initPropertyInstance:(MCModelProperty *)instance byPropertyVar:(objc_property_t)var
{
    NSString *p_name = [NSString stringWithUTF8String:property_getName(var)];
    instance.name = p_name;
    
    NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(var)];
    assert([[attributes substringToIndex:1] isEqualToString:@"T"]);
    
    //className,objCType
    NSString *className = nil;
    NSString *objCType = nil;
    
    NSRange firstCommaRange = [attributes rangeOfString:@","];
    
    if (firstCommaRange.location != NSNotFound){
        NSString *firstComponent = [attributes substringToIndex:firstCommaRange.location];
        if (![[attributes substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"@"]){
            //objCType
            if (firstComponent.length>1){
                objCType = [firstComponent substringFromIndex:1];
            }
        }else{
            //kind of class instance.
            if (firstComponent.length >4){
                //firstComponent pattern T@"ClassName"
                className = [firstComponent substringWithRange:NSMakeRange(3, firstComponent.length -4)];
            }else if (firstComponent.length ==2){
                //firstComponent equal T@
                className = @"";
            }
        }
    }
    
    instance.className = className;
    instance.objCType = objCType;
    
    //readonly
    if ([attributes rangeOfString:@",R"].location != NSNotFound){
        instance.readonly = YES;
    }
    
    //isObject
    instance.isObject = instance.className;
}

//
//Validate and check method
//

/**
 @brief check whether value validate to property or not.
 @return YES when validate,otherwise NO.
 */
+ (BOOL)validateValue:(id)value forProperty:(MCModelProperty *)property
{
    BOOL isValid = NO;
    
    if (value && property){
        if (property.isObject && ([[value class] isSubclassOfClass:NSClassFromString(property.className)] || [property.className isEqualToString:NSStringFromClass([value class])]) ){
            //@property declare is kind of class's instance,has explicit class name.
            isValid = YES;
        }else if (property.isObject && property.className && property.className.length == 0){
            //@property declare is kind of class's instance,no explicit class name.
            isValid = YES;
        }else if (!property.isObject && property.objCType){
            if ([value respondsToSelector:@selector(objCType)]){
                //NSValue or NSNumber
                isValid = [property.objCType isEqualToString:[NSString stringWithUTF8String:[value objCType]]];
            }
        }
    }
    
    return isValid;
}

@end