//
//  DBAAlbumBriefModel.h
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "MCModel.h"

/**
 @brief 专辑摘要、在列表页使用
 */

@interface DBAAlbumBriefModel : MCModel <MCModelTable>

@property (nonatomic, copy) NSString*   ID;

@property (nonatomic, copy) NSString*   title;

@property (nonatomic, copy) NSString*   author;

@property (nonatomic, copy) NSString*   pubdate;

@property (nonatomic, copy) NSString*   image;

@property (nonatomic, copy) NSString*   mobile_link;

@end
