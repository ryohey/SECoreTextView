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
    
    CGRect frame = self.frame;
    CGPoint center = self.center;
    
    CGRect startFrame = self.frame;
    startFrame.size = CGSizeZero;
    self.frame = startFrame;
    
    CGPoint startPosition = self.center;
    startPosition.x += frame.size.width / 2;
    startPosition.y += frame.size.height;
    self.center = startPosition;
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:kNilOptions
                     animations:^
     {
         self.frame = frame;
         self.center = center;
     }
                     completion:NULL];
}

- (void)moveToPoint:(CGPoint)point
{
    self.touchPoint = point;
    [self setNeedsDisplay];
}

- (void)hide
{
    CGRect bounds = self.bounds;
    bounds.size = CGSizeZero;
    
    CGPoint position = self.touchPoint;
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:kNilOptions
                     animations:^
     {
         self.bounds = bounds;
         self.center = position;
     }
                     completion:^(BOOL finished)
     {
         self.magnifyToView = nil;
         [self removeFromSuperview];
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
