//
//  LZImageCropping.h
//  CroppingImage
//
//  Created by 刘志雄 on 2017/12/25.
//  Copyright © 2017年 刘志雄. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LZImageCropping;
@protocol LZImageCroppingDelegate <NSObject>

-(void)lzImageCroppingDidCancle:(LZImageCropping *)cropping;
-(void)lzImageCropping:(LZImageCropping *)cropping didCropImage:(UIImage *)image;

@end

@interface LZImageCropping : UIViewController

@property(nonatomic,weak)id<LZImageCroppingDelegate>delegate;

/**
 裁剪的图片
 */
@property(nonatomic,strong)UIImage *image;

/**
 [兼容API]裁剪区域 默认转换为宽高比例，返回指定比例不确定分辨率的图片
 */
@property(nonatomic,assign)CGSize cropSize;
/// 最大裁剪宽高px: 返回最大指定分辨率的图片。注：该参数覆盖宽高比配置
@property(nonatomic,assign)CGSize cropMaxSize;

/*
 顶部title
 */
@property(nonatomic,strong)UILabel *titleLabel;

/**
 主题色
 */
@property (nonatomic, copy) UIColor *mainColor;

/**
 返回箭头
 */
@property(nonatomic,strong)UIImage *backImage;

//是否裁剪成圆形
@property(nonatomic, assign)BOOL isRound;

@property (nonatomic, copy) void (^didFinishPickingImage)(UIImage *coverImage);

@end
