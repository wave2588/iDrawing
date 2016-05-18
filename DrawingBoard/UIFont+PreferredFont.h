//
//  UIFont+PreferredFont.h
//  zhiyou
//
//  Created by wave on 16/1/26.
//  Copyright © 2016年 Folse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (PreferredFont)

+(UIFont *)bb_regularSystemFontToFitHeight:(CGFloat)fontSize;

+(UIFont *)bb_lightSystemFontToFitHeight:(CGFloat)fontSize;

+(UIFont *)bb_mediumSystemFontToFitHeight:(CGFloat)fontSize;
@end
