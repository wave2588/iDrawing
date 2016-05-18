//
//  BBSaveAlertView.m
//  DrawingBoard
//
//  Created by wave on 16/3/31.
//  Copyright © 2016年 wave. All rights reserved.
//

#import "BBSaveAlertView.h"

@interface BBSaveAlertView ()

@property (nonatomic,strong) UILabel *label;

@end

@implementation BBSaveAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height * 0.8)];
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc]init];
        self.label.text = @"保存成功,是否要分享一下";
        [self.label sizeToFit];
        self.left = (self.width - self.label.width) * 0.5;
        self.top = self.imageView.bottom;
        [self addSubview:self.label];
        
        CGFloat buttonW = self.width * 0.5;
        for (int i = 0; i < self.buttonTitle.count; i++) {
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(i * buttonW, self.label.bottom, buttonW, self.height - self.imageView.height - self.label.height)];
            [button setTitle:self.buttonTitle[i] forState:UIControlStateNormal];
            [self addSubview:button];
        }
        
    }
    return self;
}

@end
