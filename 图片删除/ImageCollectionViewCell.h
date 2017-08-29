//
//  ImageCollectionViewCell.h
//  图片删除
//
//  Created by WangXueqi on 17/8/28.
//  Copyright © 2017年 JingBei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView * selectImage;

- (void)getSelectImage:(NSString *)image;
@end
