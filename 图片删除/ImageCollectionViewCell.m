//
//  ImageCollectionViewCell.m
//  图片删除
//
//  Created by WangXueqi on 17/8/28.
//  Copyright © 2017年 JingBei. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        if (!_selectImage) {
            _selectImage = [[UIImageView alloc]init];
            _selectImage.layer.cornerRadius = 5;
            _selectImage.layer.masksToBounds = YES;
            [self addSubview:_selectImage];
        }
    }
    return self;
}

- (void)getSelectImage:(NSString *)image {

    _selectImage.image = [UIImage imageNamed:@""];
    _selectImage.backgroundColor = [UIColor colorWithRed:(arc4random() % 256)/255.0 green:(arc4random() % 256)/255.0 blue:(arc4random() % 256)/255.0 alpha:1.0f];
}

- (void)layoutSubviews {

    [super layoutSubviews];
    _selectImage.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
