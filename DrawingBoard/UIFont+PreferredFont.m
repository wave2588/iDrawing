//
//  UIFont+PreferredFont.m
//  zhiyou
//
//  Created by wave on 16/1/26.
//  Copyright © 2016年 Folse. All rights reserved.
//

#import "UIFont+PreferredFont.h"

@implementation UIFont (PreferredFont)

+(UIFont *)bb_regularSystemFontToFitHeight:(CGFloat)fontSize{
    return [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];
}

+(UIFont *)bb_lightSystemFontToFitHeight:(CGFloat)fontSize{
    return [UIFont fontWithName:@"PingFangSC-Light" size:fontSize];
}

+(UIFont *)bb_mediumSystemFontToFitHeight:(CGFloat)fontSize{
    return [UIFont fontWithName:@"PingFangSC-Medium" size:fontSize];
}

@end
