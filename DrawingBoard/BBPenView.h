//
//  BBPenView.h
//  DrawingBoard
//
//  Created by wave on 16/3/17.
//  Copyright © 2016年 wave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBPenView : UIView

@property (nonatomic,strong) CanvasView *canvasView;

@property (nonatomic,copy) void (^clickMenuBlock)(UIButton *);

-(void)addEraserStateRemind;

@end
