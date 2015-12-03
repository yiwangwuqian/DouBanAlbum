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
#import "DBAMusicListCell.h"
#import "DBAMusicListDataSource.h"

@interface DBAMusicListViewController()<UITableViewDelegate>
{
    UITableView*                _tableView;
    
    DBAMusicListDAO*            _listDAO;
    DBAMusicListDataResult*     _listDataResult;
    NSMutableArray*             _musicSummarys;
    DBAMusicListDataSource*     _tableDataSource;
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
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView addFooterWithTarget:self
                                 action:@selector(willBeginLoadMoreRefresh)];
        
        _tableDataSource = [[DBAMusicListDataSource alloc] init];
        _tableDataSource.musicSummarys = _musicSummarys;
        _tableView.delegate = self;
        _tableView.dataSource = _tableDataSource;
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
