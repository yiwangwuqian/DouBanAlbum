//
//  DBAMusicListDAO.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBAMusicListDAO.h"
#import "DBAMusicListDataResult.h"

@implementation DBAMusicListDAO

- (NSString *)requestURL
{
    return DBAMusicSearchSubpath;
}

- (NSDictionary *)requestParam
{
    DBAMusicListDataResult *dataResult = (DBAMusicListDataResult*)self.dataResult;
    
    if (!dataResult.start){
        return nil;
    }
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[NSNumber numberWithInteger:dataResult.start]
              forKey:@"start"];
    return param;
}

@end
