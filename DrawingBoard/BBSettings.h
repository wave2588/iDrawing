//
//  BBSettings.h
//  DrawingBoard
//
//  Created by wave on 16/3/17.
//  Copyright © 2016年 wave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSettings : NSObject

+ (BBSettings *)defaultSettings;

@property (nonatomic,assign) BOOL isEraserState;

@end
