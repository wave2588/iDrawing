//
//  UIImage+Category.h
//  DrawingBoard
//
//  Created by wave on 16/3/24.
//  Copyright © 2016年 wave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)

/**
 *  打水印
 *
 *  @param backgroundImage   背景图片
 *  @param markName 右下角的水印图片
 */
- (instancetype)waterMarkWithImageName:(NSString *)backgroundImage andMarkImageName:(NSString *)markName;

@end
