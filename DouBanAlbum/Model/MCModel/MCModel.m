//
//  MCModel.m
//  MCModel
//
//  Created by ~DD~ on 15/10/27.
//  Copyright © 2015年 ~DD~. All rights reserved.
//


#import "MCModel.h"
#import "MCModelMapUtil.h"

NSString *const MCModelErrorDomain = @"MCModelErrorDomain";

const NSInteger MCModelErrorNotDictionary = 1;

const NSInteger MCModelErrorNotArray = 2;

@interface MCModel()

@end

@implementation MCModel

#pragma mark- Public methods

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error
{
    self = [super init];
    if (self){
        
        if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]){
            if (error){
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"It's not dictionary data", @""),
                                           NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"%@ could not be created because init data class: %@", @""), NSStringFromClass(self.class), dictionary.class],
                                           };
                
                *error = [NSError errorWithDomain:MCModelErrorDomain
                                             code:MCModelErrorNotDictionary
                                         userInfo:userInfo];
            }
            return nil;
        }
        
        [MCModelMapUtil propertyUpdate:self
                     withDictionary:dictionary];
    }
    return self;
}

- (NSDictionary *)dictionary
{
    return [MCModelMapUtil dictionaryWithObject:self];
}

- (NSString *)dictionaryMapClassNameForKey:(NSString *)key
{
    return nil;
}

- (NSString *)arrayMemberMapClassNameForKey:(NSString *)key
{
    return nil;
}

#pragma mark- Private methods

@end
