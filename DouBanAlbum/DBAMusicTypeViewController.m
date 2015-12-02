//
//  DBAMusicTypeViewController.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/1.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBAMusicTypeViewController.h"
#import "DBAHTTPRequestManager.h"
#import "DBACommon.h"
#import "DBAMusicListViewController.h"

@interface DBAMusicTypeViewController()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray*                    _musicTypes;
    UITableView*                _tableView;
}
@end

@implementation DBAMusicTypeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect newRect = self.view.frame;
    newRect.origin.y = 20;
    newRect.size.height = newRect.size.height -20;
    self.view.frame = newRect;
    
    [self initData];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (!self.navigationController.navigationBarHidden){
//        [self.navigationController setNavigationBarHidden:YES];
//    }
}

#pragma mark- Private methods

- (void)initData
{
    if (!_musicTypes){
        _musicTypes = @[@"流行",@"摇滚",@"电子",@"民谣",@"爵士",@"轻音乐",@"世界音乐",@"说唱"];
    }
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_musicTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [_musicTypes objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushToMusicListViewControllerWithType:[_musicTypes objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)pushToMusicListViewControllerWithType:(NSString *)type
{
    DBAMusicListViewController *listViewController = [[DBAMusicListViewController alloc] init];
    listViewController.belongType = type;
    
    [self.navigationController pushViewController:listViewController
                                         animated:YES];
}

@end
