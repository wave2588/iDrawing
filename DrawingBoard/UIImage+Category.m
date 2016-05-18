//
//  UIImage+Category.m
//  DrawingBoard
//
//  Created by wave on 16/3/24.
//  Copyright © 2016年 wave. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

- (instancetype)waterMarkWithImageName:(NSString *)backgroundImage andMarkImageName:(NSString *)markName{
    
    UIImage *bgImage = [UIImage imageNamed:backgroundImage];
    
    UIGraphicsBeginImageContextWithOptions(bgImage.size, NO, 0.0);
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    
    UIImage *waterImage = [UIImage imageNamed:markName];
    CGFloat scale = 0.3;
    CGFloat margin = 5;
    CGFloat waterW = waterImage.size.width * scale;
    CGFloat waterH = waterImage.size.height * scale;
    CGFloat waterX = bgImage.size.width - waterW - margin;
    CGFloat waterY = bgImage.size.height - waterH - margin;
    
    [waterImage drawInRect:CGRectMake(waterX, waterY, waterW, waterH)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
