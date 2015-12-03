//
//  DBAMusicListDataSource.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/3.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBAMusicListDataSource.h"
#import "DBAMusicListCell.h"

@implementation DBAMusicListDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_musicSummarys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    DBAMusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[DBAMusicListCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:cellIdentifier];
    }
    
    if (_musicSummarys.count < indexPath.row){
        return cell;
    }
    
    DBAAlbumBriefModel *briefModel = [_musicSummarys objectAtIndex:indexPath.row];
    cell.briefModel = briefModel;
    [cell updateViewsDisplay];
    
    return cell;
}

@end
