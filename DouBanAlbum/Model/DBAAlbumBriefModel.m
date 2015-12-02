//
//  DBAAlbumBriefModel.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBAAlbumBriefModel.h"

@implementation DBAAlbumBriefModel

- (NSString *)fromDictionaryAliasKeyForKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]){
        return @"ID";
    }
    
    return nil;
}

- (NSArray *)primaryKeys
{
    return @[@"ID"];
}

@end
