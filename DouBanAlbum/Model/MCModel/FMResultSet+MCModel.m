//
//  FMResultSet+MCModel.m
//  MCModel
//
//  Created by ~DD~ on 15/11/30.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "FMResultSet+MCModel.h"
#import "MCModelMapUtil.h"

@implementation FMResultSet(MCModel)

- (void)mc_kvcMagic:(NSObject<MCModelMap> *)object
{
    if (![object isKindOfClass:[NSObject class]]){
        return;
    }
    
    NSDictionary *resultDictionary = [self resultDictionary];
    if (resultDictionary){
        [MCModelMapUtil propertyUpdate:object
                        withDictionary:resultDictionary];
    }
}

@end
