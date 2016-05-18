//
//  BBSettings.m
//  DrawingBoard
//
//  Created by wave on 16/3/17.
//  Copyright © 2016年 wave. All rights reserved.
//

#import "BBSettings.h"

static NSString *const kIsEraserState = @"isEraserState";


@implementation BBSettings

+ (BBSettings *)defaultSettings {
    static dispatch_once_t token;
    static BBSettings *instance;
    
    dispatch_once(&token, ^{
        instance = [[BBSettings alloc] init];
    });
    
    return instance;
}


-(void)setIsEraserState:(BOOL)isEraserState{
    [[NSUserDefaults standardUserDefaults]setBool:isEraserState forKey:kIsEraserState];
}

-(BOOL)isEraserState{
    return [[NSUserDefaults standardUserDefaults]boolForKey:kIsEraserState];
}

@end
