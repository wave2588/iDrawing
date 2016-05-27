//
//  ProjectSettings.h
//  DrawingBoard
//
//  Created by wave on 16/3/17.
//  Copyright © 2016年 wave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBSettings.h"
#import "UIView+Frame.h"
#import "UIColor+colorStr.h"
#import "UIFont+PreferredFont.h"
#import "DrawingBoard-Swift.h"


#define kRandomColor [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0]

#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define XCODE_COLORS_ESCAPE @"\033["
#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

#define DLogBlue(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,0,255;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)
#define DLogRed(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg255,0,0;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@" %s [L:%d T:%@]" fmt), __PRETTY_FUNCTION__, __LINE__, [NSThread currentThread], ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

//随机颜色
#define kRandomColor [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0]

//致优蓝
#define kBasis_Blue_COLOR [UIColor colorWithRed:0/255.0 green:204/255.0 blue:214/255.0 alpha:1.0]

//橙色
#define kBasis_Orange_COLOR [UIColor colorWithRed:255/255.0 green:154/255.0 blue:43/255.0 alpha:1.0]

//浅玫
#define kBasis_LightRoseRed_COLOR [UIColor colorWithRed:255/255.0 green:82/255.0 blue:115/255.0 alpha:1.0]

//粉绿
#define kBasis_DarkGreen_COLOR [UIColor colorWithRed:101/255.0 green:191/255.0 blue:140/255.0 alpha:1.0]

//暗紫色
#define kBasis_DarkViolet_COLOR [UIColor colorWithRed:112/255.0 green:86/255.0 blue:163/255.0 alpha:1.0]

//明黄
#define kBasis_BrightYellow_COLOR [UIColor colorWithRed:248/255.0 green:224/255.0 blue:28/255.0 alpha:1.0]

//草绿
#define kBasis_GrassGreen_COLOR [UIColor colorWithRed:139/255.0 green:195/255.0 blue:78/255.0 alpha:1.0]

//浅浅粉
#define kBasis_LightLightPink_COLOR [UIColor colorWithRed:255/255.0 green:244/255.0 blue:247/255.0 alpha:1.0]

//浅粉
#define kBasis_LightPink_COLOR [UIColor colorWithRed:247/255.0 green:209/255.0 blue:220/255.0 alpha:1.0]

//浅浅蓝
#define kBasis_LightLightBlue_COLOR [UIColor colorWithRed:243/255.0 green:249/255.0 blue:254/255.0 alpha:1.0]

//浅蓝
#define kBasis_LightBlue_COLOR [UIColor colorWithRed:193/255.0 green:231/255.0 blue:246/255.0 alpha:1.0]

//纯黑
#define kBasis_PureBlack_COLOR [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]

//黑色
#define kBasis_Black_COLOR [UIColor colorWithRed:41/255.0 green:47/255.0 blue:56/255.0 alpha:1.0]

//深灰
#define kBasis_DeepGray_COLOR [UIColor colorWithRed:108/255.0 green:119/255.0 blue:127/255.0 alpha:1.0]

//中灰
#define kBasis_MiddleGray_COLOR [UIColor colorWithRed:186/255.0 green:190/255.0 blue:194/255.0 alpha:1.0]

//浅灰
#define kBasis_LightGray_COLOR [UIColor colorWithRed:230/255.0 green:231/255.0 blue:231/255.0 alpha:1.0]

//浅浅灰
#define kBasis_LightLightGray_COLOR [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0]

//白色
#define kBasis_PureWhite_COLOR [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]


@interface ProjectSettings : NSObject

@end
