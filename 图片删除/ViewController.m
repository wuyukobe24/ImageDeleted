//
//  ViewController.m
//  图片删除
//
//  Created by WangXueqi on 17/8/28.
//  Copyright © 2017年 JingBei. All rights reserved.
//

#import "ViewController.h"
#import "ImageCollectionViewCell.h"
// 当前屏幕宽
#define K_ScreenWidth   CGRectGetWidth([[UIScreen mainScreen] bounds])
// 当前屏幕高
#define K_ScreenHeight  CGRectGetHeight([[UIScreen mainScreen] bounds])
#define k_itemNum       4
static NSString * imageCollectionId = @"imageCollectionId";
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)UICollectionView * imageCollectionView;
@property(nonatomic,strong)UIButton * deleteButton;
@property(nonatomic,strong)NSArray * imageArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageCollectionView];
    [self.view addSubview:self.deleteButton];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
    [self.imageCollectionView addGestureRecognizer:longPress];
}

- (NSArray *)imageArray {

    if (!_imageArray) {
        _imageArray = [NSArray arrayWithObjects:@"record_cancel",@"record_complete",@"record_end",@"record_start",@"sound_blue-water",@"sound_blue",@"sound_green",@"sound_ligh_blue",@"icon_pic_add", nil];
    }
    return _imageArray;
}
- (UICollectionView *)imageCollectionView {

    if (!_imageCollectionView) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = CGSizeMake((K_ScreenWidth-50)/k_itemNum, (K_ScreenWidth-50)/k_itemNum);//每个cell大小
        
        _imageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 40, K_ScreenWidth-20, K_ScreenHeight-40-50) collectionViewLayout:flowLayout];
        _imageCollectionView.delegate = self;
        _imageCollectionView.dataSource = self;
        _imageCollectionView.backgroundColor = [UIColor whiteColor];
        [_imageCollectionView setScrollEnabled:NO];
        [self.view addSubview:_imageCollectionView];
        
        [_imageCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:imageCollectionId];
    }
    return _imageCollectionView;
}

- (UIButton *)deleteButton {

    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setFrame:CGRectMake(0, K_ScreenHeight, K_ScreenWidth, 50)];
        [_deleteButton setTitle:@"拖到此处删除" forState:UIControlStateNormal];
        [_deleteButton setTitle:@"松手即可删除" forState:UIControlStateDisabled];
        [_deleteButton setBackgroundColor:[UIColor redColor]];
        [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    }
    return _deleteButton;
}

- (void)longAction:(UILongPressGestureRecognizer *)sender {
    
    static NSIndexPath *selectIndexPath;//当前长按的item的index
    static UICollectionViewCell *selectCell;
    static UIImageView *moveImageView;
    static NSIndexPath *lastIndexPath;
    static CGPoint offsetCenter;
    
    UICollectionViewCell *addCell = nil;
    if (self.imageArray.count < 9 ) {
        addCell = [self.imageCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.imageArray.count inSection:0]];
    }
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            {
                selectIndexPath = [self.imageCollectionView indexPathForItemAtPoint:[sender locationInView:self.imageCollectionView]];
                lastIndexPath = selectIndexPath;
                selectCell = [self.imageCollectionView cellForItemAtIndexPath:selectIndexPath];
                
                if (selectIndexPath.row == self.imageArray.count) {
                    return;
                }
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[self screenShot:selectCell.layer]];
                imageView.frame = [self.imageCollectionView convertRect:selectCell.frame toView:self.view];
                imageView.layer.cornerRadius = 8;
                imageView.layer.masksToBounds = YES;
                imageView.alpha = 0.7;
                [self.view insertSubview:imageView aboveSubview:self.deleteButton];
                moveImageView = imageView;
                
                CGPoint point = [sender locationInView:self.view];
                offsetCenter = CGPointMake(moveImageView.center.x - point.x, moveImageView.center.y - point.y);
                
                [UIView animateWithDuration:0.3 animations:^{
                    CGFloat W = imageView.frame.size.width*1.1;
                    CGFloat H = W;
                    CGFloat X = imageView.frame.origin.x - (W - imageView.frame.size.width)/2;
                    CGFloat Y = imageView.frame.origin.y - (H - imageView.frame.size.height)/2;
                    imageView.frame = CGRectMake(X, Y, W, H);
                }];
                
                selectCell.hidden = YES;
                //NSLog(@"offsetCenterX 1 == %f offsetCenterY == %f selectIndexPath == %zi lastIndexPath == %zi",offsetCenter.x,offsetCenter.y,selectIndexPath.row,lastIndexPath.row);
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            if (selectIndexPath.row == self.imageArray.count) {
                return;
            }
            
            CGPoint point = [sender locationInView:self.view];
            moveImageView.center = CGPointMake(point.x + offsetCenter.x, point.y + offsetCenter.y);
            
            if (selectIndexPath) {
                if ([self point:[sender locationInView:self.view] inRect:self.deleteButton.frame]) {
                    self.deleteButton.enabled = NO;
                } else {
                    self.deleteButton.enabled = YES;
                }
                [UIView animateWithDuration:0.5 animations:^{
                    self.deleteButton.frame = CGRectMake(0, K_ScreenHeight-50, K_ScreenWidth, 50);
                }];
                
                NSIndexPath *indexPath = [self.imageCollectionView indexPathForItemAtPoint:[sender locationInView:self.imageCollectionView]];
                if (indexPath && indexPath.row != self.imageArray.count) {
                    [self.imageCollectionView moveItemAtIndexPath:lastIndexPath toIndexPath:indexPath];
                    NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.imageArray];
                    id img = mArr[lastIndexPath.row];
                    [mArr removeObject:img];
                    [mArr insertObject:img atIndex:indexPath.row];
                    self.imageArray = mArr;
                    lastIndexPath = indexPath;
                }
            }
            //NSLog(@"offsetCenterX 2 == %f offsetCenterY == %f selectIndexPath == %zi lastIndexPath == %zi",offsetCenter.x,offsetCenter.y,selectIndexPath.row,lastIndexPath.row);
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (selectIndexPath.row == self.imageArray.count) {
                return;
            }
            
            ImageCollectionViewCell *imageCell = (ImageCollectionViewCell *)selectCell;
            selectCell.hidden = NO;
            [moveImageView removeFromSuperview];
            moveImageView = nil;
            
            if ([self point:[sender locationInView:self.view] inRect:self.deleteButton.frame]) {
                if (selectIndexPath && selectIndexPath.row < self.imageArray.count) {

                    NSMutableArray *mArr = [NSMutableArray arrayWithArray:self.imageArray];
                    [mArr removeObjectAtIndex:selectIndexPath.row];
                    self.imageArray = mArr;
                    
                    imageCell.selectImage = nil;
                    if (self.imageArray.count >= 8) {
                        [self.imageCollectionView reloadData];
                    } else {
                        [self.imageCollectionView deleteItemsAtIndexPaths:@[(lastIndexPath ? lastIndexPath : selectIndexPath)]];
                    }
                }
            }
            //NSLog(@"offsetCenterX 3 == %f offsetCenterY == %f selectIndexPath  == %zi lastIndexPath == %zi",offsetCenter.x,offsetCenter.y,selectIndexPath.row,lastIndexPath.row);
            lastIndexPath = nil;
            
            if (selectIndexPath) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.deleteButton.frame = CGRectMake(0, K_ScreenHeight, K_ScreenWidth, 50);
                }];
            }
            
            selectIndexPath = nil;
            
            break;
        }
        default:
        {
            if (selectIndexPath.row == self.imageArray.count) {
                return;
            }
            
            selectCell.hidden = NO;
            [moveImageView removeFromSuperview];
            moveImageView = nil;
            lastIndexPath = nil;
            
            if (selectIndexPath) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.deleteButton.frame = CGRectMake(0, K_ScreenHeight, K_ScreenWidth, 50);
                }];
            }
            
            selectIndexPath = nil;
            break;
        }
    }

}


#pragma mark - UICollectionviewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ImageCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageCollectionId forIndexPath:indexPath];
    [cell getSelectImage:self.imageArray[indexPath.row]];
    
    return cell;
}

- (UIImage *)screenShot:(CALayer *)layer {
    
    if (layer == nil) return nil;
    
    //1.开启一个基于位图的图形上下文
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, NO, 0.0);
    //2.渲染到图形上下文
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //3.结束上下文
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)point:(CGPoint)point inRect:(CGRect)rect {
    
    if (point.x >= rect.origin.x && point.y >= rect.origin.y && point.x <= rect.origin.x + rect.size.width && point.y <= rect.origin.y + rect.size.height) {
        return YES;
    } else {
        return NO;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
