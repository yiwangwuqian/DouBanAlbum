//
//  DBAMainViewController.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/1.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#import "DBAMainViewController.h"
#import "DBAMusicTypeViewController.h"

@interface DBAMainViewController()
{
    DBAMusicTypeViewController*     _musicTypeViewController;
}
@end

@implementation DBAMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupViews];
}

- (void)setupViews
{
    if (!_musicTypeViewController){
        _musicTypeViewController = [[DBAMusicTypeViewController alloc] init];
        [self.view addSubview:_musicTypeViewController.view];
        [self addChildViewController:_musicTypeViewController];
    }
}

@end
