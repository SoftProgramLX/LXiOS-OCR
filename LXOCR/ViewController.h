//
//  ViewController.h
//  LXOCR
//
//  Created by 李旭 on 17/2/13.
//  Copyright © 2017年 lixu. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>

@interface ViewController : UIViewController<TesseractDelegate>

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label;

@end


