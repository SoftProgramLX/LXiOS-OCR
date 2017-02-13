//
//  ViewController.m
//  LXOCR
//
//  Created by 李旭 on 17/2/13.
//  Copyright © 2017年 lixu. All rights reserved.
//

#import "ViewController.h"

static NSString * const kImageFileName = @"testimg";
static NSString * const kLanguage = @"chi_sim"; // 解析対象言語

@interface ViewController ()

@end

@implementation ViewController {
    UIImage *adjustedImage_;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 250, 200)];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 240, 250, 320)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor redColor];
    [self.view addSubview:label];
    self.label = label;
    
    self.imageView.image = [UIImage imageNamed:kImageFileName];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self analyze];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)analyze {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        CIImage *ciImage = [[CIImage alloc] initWithImage:self.imageView.image];
        
        CIFilter *ciFilter =
        [CIFilter filterWithName:@"CIColorMonochrome"
                   keysAndValues:kCIInputImageKey, ciImage,
         @"inputColor", [CIColor colorWithRed:0.75 green:0.75 blue:0.75],
         @"inputIntensity", [NSNumber numberWithFloat:1.0],
         nil];
        ciFilter =
        [CIFilter filterWithName:@"CIColorControls"
                   keysAndValues:kCIInputImageKey, [ciFilter outputImage],
         @"inputSaturation", [NSNumber numberWithFloat:0.0],
         @"inputBrightness", [NSNumber numberWithFloat:-1.0],
         @"inputContrast", [NSNumber numberWithFloat:4.0],
         nil];
        
        ciFilter =
        [CIFilter filterWithName:@"CIUnsharpMask"
                   keysAndValues:kCIInputImageKey, [ciFilter outputImage],
         @"inputRadius", [NSNumber numberWithFloat:2.5],
         @"inputIntensity", [NSNumber numberWithFloat:0.5],
         nil];
        
        CIContext *ciContext = [CIContext contextWithOptions:nil];
        CGImageRef cgImage =
        [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];
        
        UIImage *adjustedImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:kLanguage];
        tesseract.delegate = self;
        
        //      [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"]; //limit search
        [tesseract setImage:adjustedImage]; //image to check
        [tesseract recognize];
        NSString *recognizedText = [tesseract recognizedText];
        tesseract = nil; //deallocate and free all memory
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = recognizedText;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

#pragma mark - TesseractDelegate methods

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}
@end
