//
//  DBAMusicListViewController.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/2.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBAMusicListViewController.h"
#import "DBAMusicListDAO.h"
#import "DBAMusicListDataResult.h"
#import "DBAAlbumBriefModel.h"
#import "UIImageView+AFNetworking.h"
#import "MJRefresh.h"

@interface DBAMusicListViewController()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView*                _tableView;
    
    DBAMusicListDAO*            _listDAO;
    DBAMusicListDataResult*     _listDataResult;
    NSMutableArray*             _musicSummarys;
}
@end

@implementation DBAMusicListViewController

- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_listDAO){
        [self requestMusicType:self.belongType];
    }
}

#pragma mark- Private methods

- (void)setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView addFooterWithTarget:self
                                 action:@selector(willBeginLoadMoreRefresh)];
        [self.view addSubview:_tableView];
    }
}

- (void)initData
{
    if (!_musicSummarys){
        _musicSummarys = [[NSMutableArray alloc] init];
    }
}

- (void)requestMusicType:(NSString *)type
{
    NSDictionary *param = @{@"q":type};
    if (!_listDAO){
        _listDAO = [[DBAMusicListDAO alloc] init];
        _listDataResult= [[DBAMusicListDataResult alloc] init];
        _listDAO.dataResult = _listDataResult;
    }
    
    _listDAO.additionParam = param;
    
    [_listDAO requestWithSuccess:^(DBADAORequestStatus status, id responseData) {
        
        if (responseData){
            [_musicSummarys addObjectsFromArray:responseData];
        }
        
        if ([responseData count]){
            _listDataResult.start += [responseData count];
        }
        
        if (status== DBADAORequestStatusSuccess){
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                if (_tableView.footerRefreshing){
                    [_tableView footerEndRefreshing];
                }
            });
        }
    } failure:^(DBADAORequestStatus status, NSError *error) {
        NSLog(@"error:%@",[error localizedDescription]);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_musicSummarys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    if (_musicSummarys.count < indexPath.row){
        return cell;
    }
    
    DBAAlbumBriefModel *briefModel = [_musicSummarys objectAtIndex:indexPath.row];
    cell.textLabel.text = briefModel.title;
    cell.detailTextLabel.text = briefModel.author;
    if(briefModel.image){
        [cell.imageView setImageWithURL:[NSURL URLWithString:briefModel.image]];
    }else{
        cell.imageView.image = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)willBeginLoadMoreRefresh
{
    if (_listDataResult.total == _musicSummarys.count){
        [_tableView footerEndRefreshing];
        return;
    }
    
    [self requestMusicType:self.belongType];
}

@end
