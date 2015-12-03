//
//  DBAMusicListCell.m
//  DouBanAlbum
//
//  Created by ~DD~ on 15/12/3.
//  Copyright © 2015年 ~DD~. All rights reserved.
//

#define kCell_DefaultHeight     44

#import "DBAMusicListCell.h"
#import "UIImageView+AFNetworking.h"

@interface DBAMusicListCell()

@property (nonatomic,weak) UIImageView*   iconImageView;
@property (nonatomic,weak) UILabel*       titleLabel;

@end

@implementation DBAMusicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    if (!_iconImageView){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.5, 0.5, 43, 43)];
        [self.contentView addSubview:imageView];
        _iconImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _iconImageView.layer.borderWidth = 0.5;
        self.iconImageView = imageView;
    }
    
    if (!_titleLabel){
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_iconImageView.frame) + 0.5,
                                                                        CGRectGetMinY(_iconImageView.frame),
                                                                        CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetMaxX(_iconImageView.frame) - 1,
                                                                        CGRectGetHeight(_iconImageView.frame))];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
}

- (void)updateViewsDisplay
{
    if (!self.briefModel){
        return;
    }
    
    if (_briefModel.image){
        [_iconImageView setImageWithURL:[NSURL URLWithString:_briefModel.image]];
    }
    
    _titleLabel.text = [NSString stringWithFormat:@"%@--%@",_briefModel.title,_briefModel.author];
    [self adjustTitleLabelFrame];
}

- (void)adjustTitleLabelFrame
{
    CGSize textSize = CGSizeZero;
    
    if (_titleLabel.text){
        textSize = [_titleLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(_titleLabel.frame), kCell_DefaultHeight-1)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:[NSDictionary dictionaryWithObjectsAndKeys: _titleLabel.font, NSFontAttributeName, nil]
                                                  context:nil].size;
    }
    
    CGRect newRect = _titleLabel.frame;
    newRect.size.height = textSize.height;
    _titleLabel.frame = newRect;
}

@end

#undef kCell_DefaultHeight
