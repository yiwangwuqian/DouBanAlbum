//
//  DBAMusicListDataResult.h
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBADataResult.h"

@interface DBAMusicListDataResult : DBADataResult

@property (nonatomic,assign) NSInteger          total;//全部数量
@property (nonatomic,assign) NSInteger          start;//请求的偏移量(offset)

@property (nonatomic,strong) NSMutableArray*    musicSummarys;//每次请求成功后经过解析的数据

@end
