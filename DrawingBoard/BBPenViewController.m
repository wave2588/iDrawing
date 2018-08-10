//
//  BBPenViewController.m
//  DrawingBoard
//
//  Created by wave on 16/3/17.
//  Copyright © 2016年 wave. All rights reserved.
//

#import "BBPenViewController.h"
#import "BBPenView.h"
#import "UIImage+Category.h"
#import "BBSaveAlertView.h"

#define screenHeight 2208.0
#define screenWidth 1242.0


@interface BBPenViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong) BBPenView *penView;

@property(nonatomic, strong) UIImage *saveImage;

@end

@implementation BBPenViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];


    [self __viewStyle];
}

- (void)__viewStyle {

    [self.view addSubview:self.penView];

    BBPenViewController __weak *weakSelf = self;

    self.penView.clickMenuBlock = ^(UIButton *button) {
        switch (button.tag) {

            case 2:
                [weakSelf clearPenView];
                break;

            case 3:
                [weakSelf saveImageToPicture];
                break;
        }

    };
}

//清空屏幕
- (void)clearPenView {

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"确定要清空吗?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.penView.canvasView clear];
    }]];

    [alertVc addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [self presentViewController:alertVc animated:YES completion:nil];
}

//保存图片
- (void)saveImageToPicture {

    UIGraphicsBeginImageContextWithOptions(self.penView.bounds.size, NO, 0.0);

    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [self.penView.layer renderInContext:ctx];

    self.saveImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    //保存到相册
    UIImageWriteToSavedPhotosAlbum(self.saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

//    CGFloat WRtaio = 300.0 / screenWidth;
//    CGFloat HRtaio = 300.0 / screenHeight;
//
//
//    CGFloat w = self.view.width * WRtaio;
//    CGFloat h = self.view.height * HRtaio;
//
//    DLog(@"%f", w);
//    DLog(@"%f", h);
//    DLog(@"%f", (self.view.width - w) * 0.5);
//    DLog(@"%f", (self.view.height - h) * 0.5);
//    BBSaveAlertView *saveAlertView = [[BBSaveAlertView alloc] initWithFrame:CGRectMake((self.view.width - w) * 0.5, (self.view.height - h) * 0.5, w, h)];
//    saveAlertView.backgroundColor = kRandomColor;
//    [self.view addSubview:saveAlertView];
//
//
//    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
//    view.alpha = 0;
//    [self.view addSubview:view];
//    [UIView animateWithDuration:1 animations:^{
//        view.backgroundColor = [UIColor whiteColor];
//        view.alpha = 1;
//    }                completion:^(BOOL finished) {
//        [UIView animateWithDuration:1 animations:^{
//            view.alpha = 0;
//        }                completion:^(BOOL finished) {
//            [view removeFromSuperview];
//        }];
//    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = @"保存成功";
    if (error != nil) {
        msg = @"保存失败!";
    }
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}


- (BBPenView *)penView {
    if (!_penView) {
        _penView = [[BBPenView alloc] initWithFrame:self.view.bounds];
    }
    return _penView;
}


@end









