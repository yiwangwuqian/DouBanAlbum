//
//  DBAMusicListCell.h
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/3.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBAAlbumBriefModel.h"

@interface DBAMusicListCell : UITableViewCell

@property (nonatomic,weak) DBAAlbumBriefModel*    briefModel;

- (void)updateViewsDisplay;

@end
