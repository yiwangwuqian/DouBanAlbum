//
//  DBAHTTPRequestManager.h
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/1.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "AFNetworking.h"

@interface DBAHTTPRequestManager : AFHTTPRequestOperationManager

+ (instancetype)defaultManager;

@end
