//
//  SETextMagnifierRanged.m
//  SECoreTextView-iOS
//
//  Created by kishikawa katsumi on 2013/04/26.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import "SETextMagnifierRanged.h"
#import "UIView+Capture.h"

@interface SETextMagnifierRanged ()
{
    CGImageRef _maskRef;
}

@property (weak, nonatomic) UIView *magnifyToView;
@property (assign, nonatomic) CGPoint touchPoint;

@property (strong, nonatomic) UIImage *mask;
@property (strong, nonatomic) UIImageView *loupeFrameView;

@end

@implementation SETextMagnifierRanged

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *mask = [UIImage imageNamed:@"SECoreTextView.bundle/RangedMagnifierMask_Horizontal_Normal"];
        self.mask = mask;
        
        UIImage *loupeFrame = [UIImage imageNamed:@"SECoreTextView.bundle/RangedMagnifierGlass_Horizontal_Normal"];
        _loupeFrameView = [[UIImageView alloc] initWithImage:loupeFrame];
        [self addSubview:_loupeFrameView];
        
        CGImageRef maskImageRef = self.mask.CGImage;
        _maskRef = CGImageMaskCreate(CGImageGetWidth(maskImageRef),
                                     CGImageGetHeight(maskImageRef),
                                     CGImageGetBitsPerComponent(maskImageRef),
                                     CGImageGetBitsPerPixel(maskImageRef),
                                     CGImageGetBytesPerRow(maskImageRef),
                                     CGImageGetDataProvider(maskImageRef),
                                     NULL,
                                     true);
    }
    
    return self;
}

- (void)dealloc
{
    CGImageRelease(_maskRef);
}

- (void)setTouchPoint:(CGPoint)point
{
    _touchPoint = point;
    CGFloat x = point.x;
    CGFloat y = point.y;
    if (y - CGRectGetHeight(self.bounds) < CGRectGetMinY(self.magnifyToView.frame)) {
        y = CGRectGetMinY(self.magnifyToView.frame) + CGRectGetHeight(self.bounds);
    } else {
        y -= CGRectGetHeight(self.bounds);
    }
    self.center = CGPointMake(x, y);
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point
{
    self.frame = CGRectMake(0.0f, 0.0f, self.mask.size.width, self.mask.size.height);
    
    self.magnifyToView = view;
    self.touchPoint = point;
    
    [view addSubview:self];
    
    self.transform = [self makeHiddenTransform];
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:kNilOptions
                     animations:^
     {
         self.transform = CGAffineTransformIdentity;
     }
                     completion:NULL];
}

- (void)moveToPoint:(CGPoint)point
{
    self.touchPoint = point;
    [self setNeedsDisplay];
}

- (CGAffineTransform)makeHiddenTransform
{
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, 0, self.mask.size.height);
    t = CGAffineTransformScale(t, 0.001f, 0.001f);
    return t;
}

- (void)hide
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:kNilOptions
                     animations:^
     {
         self.transform = [self makeHiddenTransform];
     }
                     completion:^(BOOL finished)
     {
         self.magnifyToView = nil;
         [self removeFromSuperview];
         self.transform = CGAffineTransformIdentity;
     }];
}

- (void)drawRect:(CGRect)rect
{
    UIImage *captureImage = [self.magnifyToView se_captureImageWithCenter:self.touchPoint
                                                                     size:self.mask.size
                                                                    scale:1.2f];
    
    CGImageRef maskedImage = CGImageCreateWithMask(captureImage.CGImage, _maskRef);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -self.mask.size.height);
    
    CGRect area = (CGRect){ CGPointZero, self.mask.size };
    
    CGContextDrawImage(context, area, maskedImage);
    
    CGImageRelease(maskedImage);
}

@end
#endif
