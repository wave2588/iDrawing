//
//  BBPenView.m
//  DrawingBoard
//
//  Created by wave on 16/3/17.
//  Copyright © 2016年 wave. All rights reserved.
//

#import "BBPenView.h"
#import "DWBubbleMenuButton.h"

@interface BBPenView ()<DWBubbleMenuViewDelegate>

@property (nonatomic , strong) DWBubbleMenuButton *menuView;

@property (nonatomic,strong) UISlider *lineColorSlider;

@property (nonatomic,strong) UILabel *eraserStateRemind;

@end

@implementation BBPenView
{
    CGFloat currentSliderValue;
    BOOL isHiddenSlider;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self __subviewsStyle];
        
    }
    return self;
}

-(void)__subviewsStyle{
    [self addSubview:self.canvasView];
    
    [self menuAnimation];
    [self addSubview:self.lineColorSlider];
    [self addSubview:self.eraserStateRemind];
    
    self.backgroundColor = kBasis_DarkViolet_COLOR;
    self.canvasView.backgroundColor = [UIColor whiteColor];

    [self dragLineColorSlider:self.lineColorSlider];
    self.canvasView.lineColor = [self calculateSliderColor];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    if ([touch.view isKindOfClass:[DWBubbleMenuButton class]] || [touch.view isKindOfClass:[UIImageView class]]) {
        return;
    }

    [self hideenSlider:YES];
    
    if ([BBSettings defaultSettings].isEraserState) {
        self.canvasView.lineColor = [UIColor whiteColor];
    }else{
        self.canvasView.lineColor = self.lineColorSlider.thumbTintColor;
    }

    [self.canvasView drawTouches:touches withEvent:event];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    if ([touch.view isKindOfClass:[DWBubbleMenuButton class]] || [touch.view isKindOfClass:[UIImageView class]]) {
        return;
    }
    
    DLogRed(@"%@",touch.view);

    [self.canvasView drawTouches:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.canvasView drawTouches:touches withEvent:event];
    [self.canvasView endTouches:touches cancel:NO];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (!touches) {
        return;
    }
    
    [self.canvasView endTouches:touches cancel:NO];
    
}

-(void)menuAnimation{
    
    if (!self.menuView) {
        UIImageView *homeView = [self createHomeButtonView];
        
        self.menuView = [[DWBubbleMenuButton alloc] initWithFrame:CGRectMake(self.frame.size.width - homeView.frame.size.width - 5.f,
                                                                                              self.frame.size.height - homeView.frame.size.height - 5.f,
                                                                                              homeView.frame.size.width + 20,
                                                                                              homeView.frame.size.height)
                                                                expansionDirection:DirectionLeft];
        self.menuView.animationDuration = 0.25f;
        self.menuView.homeButtonView = homeView;
        [self.menuView addButtons:[self createDemoButtonArray]];
        
        self.menuView.delegate = self;
        
        [self addSubview:self.menuView];
    }else{

    }
}

- (UIImageView *)createHomeButtonView {
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    img.image = [UIImage imageNamed:@"addTools"];
    
    return img;
}

- (NSArray *)createDemoButtonArray {
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
    
    int i = 0;
    for (NSString *title in @[@"color", @"eraser", @"clear", @"save"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:title] forState:UIControlStateNormal];
        button.frame = CGRectMake(0.f, 0.f, 40.f, 40.f);
        button.clipsToBounds = YES;
        button.tag = i++;
        [button addTarget:self action:@selector(dwBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsMutable addObject:button];
    }
    return [buttonsMutable copy];
}

- (void)dwBtnClick:(UIButton *)sender {

    if (self.clickMenuBlock) {
        self.clickMenuBlock(sender);
    }
    
    switch (sender.tag) {
        case 0:
            [BBSettings defaultSettings].isEraserState = NO;
            [self hideenSlider:NO];
            break;
        
        case 1:
            [BBSettings defaultSettings].isEraserState = YES;
            break;
    }
    
    [self addEraserStateRemind];
}

-(void)addEraserStateRemind{
    
    if ([BBSettings defaultSettings].isEraserState) {
        self.eraserStateRemind.hidden = NO;
    }else{
        self.eraserStateRemind.hidden = YES;
    }
}

-(void)hideenSlider:(BOOL)isHidden{
    [UIView animateWithDuration:0.25 animations:^{
        if (isHidden) {
            self.lineColorSlider.alpha = 0;
        }else{
            self.lineColorSlider.alpha = 1;
        }
    }];
}

-(void)dragLineColorSlider:(UISlider *)slider{
    currentSliderValue = slider.value;
    slider.thumbTintColor = [self calculateSliderColor];
}

-(UIColor *)calculateSliderColor{
    return [UIColor colorWithHue:currentSliderValue saturation:1 brightness:1 alpha:1];
}

-(CanvasView *)canvasView{
    if (!_canvasView) {
        _canvasView = [[CanvasView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    }
    return _canvasView;
}

-(UISlider *)lineColorSlider{
    if (!_lineColorSlider) {
        _lineColorSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, self.menuView.top + 15, self.width - 60, 20)];
        _lineColorSlider.alpha = 0;
        _lineColorSlider.maximumValue = 1;
        [_lineColorSlider setMinimumTrackImage:[UIImage imageNamed:@"rightSlider"] forState:UIControlStateNormal];
        [_lineColorSlider setMaximumTrackImage:[UIImage imageNamed:@"rightSlider"] forState:UIControlStateNormal];
        [_lineColorSlider addTarget:self action:@selector(dragLineColorSlider:) forControlEvents:UIControlEventValueChanged];
    }
    return _lineColorSlider;
}

-(UILabel *)eraserStateRemind{
    if (!_eraserStateRemind) {
        _eraserStateRemind = [[UILabel alloc]init];
        _eraserStateRemind.text = @"橡皮擦状态:开启";
        _eraserStateRemind.font = [UIFont bb_lightSystemFontToFitHeight:15];
        _eraserStateRemind.textColor = [UIColor redColor];
        [_eraserStateRemind sizeToFit];
        _eraserStateRemind.left = 0;
        _eraserStateRemind.top = self.height - _eraserStateRemind.height;
        _eraserStateRemind.hidden = YES;
    }
    return _eraserStateRemind;
}

@end



















