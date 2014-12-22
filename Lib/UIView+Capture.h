//
//  UIView+Capture.h
//  RichTextEditor
//
//  Created by ryohey on 2015/01/05.
//  Copyright (c) 2015年 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Capture)

/// center を中心に size の範囲内を拡大してキャプチャーした UIImage を作成する
- (UIImage *)se_captureImageWithCenter:(CGPoint)center size:(CGSize)size scale:(CGFloat)scale;

@end
