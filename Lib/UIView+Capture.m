//
//  UIView+Capture.m
//  RichTextEditor
//
//  Created by ryohey on 2015/01/05.
//  Copyright (c) 2015年 kishikawa katsumi. All rights reserved.
//

#import "UIView+Capture.h"

@implementation UIView (Capture)

- (UIImage *)se_captureImageWithCenter:(CGPoint)center size:(CGSize)size scale:(CGFloat)scale {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGFloat x = ceilf(center.x - size.width / scale / 2);
    CGFloat y = ceilf(center.y - size.height / scale / 2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scale, scale);
    CGContextTranslateCTM(context, -x, -y);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *captureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return captureImage;
}

@end
