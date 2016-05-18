//
//  BBSaveAlertView.h
//  DrawingBoard
//
//  Created by wave on 16/3/31.
//  Copyright © 2016年 wave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSaveAlertView : UIView

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) NSArray *buttonTitle;

@property(nonatomic, copy) void (^confirmBtnActionBlock)(UIButton *);


@end
