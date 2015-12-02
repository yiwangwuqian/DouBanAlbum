//
//  DBAHTTPRequestManager.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/1.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBAHTTPRequestManager.h"
#import "DBACommon.h"

@implementation DBAHTTPRequestManager

+ (instancetype)defaultManager
{
    static DBAHTTPRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] initWithBaseURL:[NSURL URLWithString:DBABaseURL]];
    });
    return manager;
}

@end
