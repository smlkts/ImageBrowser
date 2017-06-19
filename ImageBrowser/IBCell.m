//
//  IBCell.m
//  ImageBrowser
//
//  Created by 张雁军 on 2017/5/19.
//  Copyright © 2017年 smlkts. All rights reserved.
//

#import "IBCell.h"
#import <MBProgressHUD.h>
#import <UIImageView+WebCache.h>
#import "UIView+Layout.h"

@interface IBCell ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@end


@implementation IBCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(10, 0, self.bounds.size.width - 20, self.bounds.size.height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = .2;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
//        
//        _imageWrapperView = [[UIView alloc] init];
//        _imageWrapperView.contentMode = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _imageWrapperView.clipsToBounds = YES;
//        [_scrollView addSubview:_imageWrapperView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.contentMode = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.clipsToBounds = YES;
        [_scrollView addSubview:_imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_scrollView addGestureRecognizer:longPress];
    }
    return self;
}

- (void)setImageModel:(IBModel *)imageModel{
    if (_imageModel != imageModel) {
        _imageModel = imageModel;
        if ([_imageModel.image isKindOfClass:[UIImage class]]) {
            self.imageView.image = _imageModel.image;
            [self ul_layoutSubviews];
        }else if ([_imageModel.image isKindOfClass:[NSString class]] && [_imageModel.image length] > 0){
            if ([[_imageModel.image lowercaseString] hasPrefix:@"http"]) {
                UIImage *theImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:_imageModel.image];
                if (theImage) {
                    self.imageView.image = theImage;
                    [self ul_layoutSubviews];
                }else{
                    UIImage *placeholderImage = nil;
                    if ([_imageModel.thumbnail isKindOfClass:[UIImage class]]) {
                        placeholderImage = _imageModel.thumbnail;
                    }else if ([_imageModel.thumbnail isKindOfClass:[NSString class]] && [_imageModel.thumbnail length] > 0){
                        if ([[_imageModel.thumbnail lowercaseString] hasPrefix:@"http"]) {
                            placeholderImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:_imageModel.thumbnail];
                        }else{
                            placeholderImage = [UIImage imageWithContentsOfFile:_imageModel.thumbnail];
                        }
                    }
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
                    hud.mode = MBProgressHUDModeAnnularDeterminate;
                    [self.imageView sd_setImageWithURL:[NSURL URLWithString:_imageModel.image] placeholderImage:placeholderImage options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        hud.progress = (CGFloat)receivedSize/expectedSize;
                    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                        [self ul_layoutSubviews];
                        [hud hideAnimated:YES];
                    }];
                }
            }else{
                self.imageView.image = [UIImage imageWithContentsOfFile:_imageModel.image];
                [self ul_layoutSubviews];
            }
        }
    }
}

- (void)rezoomScrollView {
    [_scrollView setZoomScale:1.0 animated:NO];
}

- (void)ul_layoutSubviews {
    //    self.height  image.height
    //    self.width   image.width
    _imageView.tz_origin = CGPointZero;
    _imageView.tz_width = self.scrollView.tz_width;
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.tz_height / self.scrollView.tz_width) {
        _imageView.tz_height = floor(image.size.height / (image.size.width / self.scrollView.tz_width));
    } else {
        _imageView.tz_height = image.size.height / image.size.width * self.scrollView.tz_width;
        _imageView.tz_centerY = self.tz_height / 2;
    }
    _scrollView.contentSize = CGSizeMake(self.scrollView.tz_width, MAX(_imageView.tz_height, self.tz_height));
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageView.tz_height <= self.tz_height ? NO : YES;
}

#pragma mark - UIGestureRecognizer

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTap) {
        self.singleTap();
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (self.longPress) {
            self.longPress();
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.tz_width > scrollView.contentSize.width) ? (scrollView.tz_width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.tz_height > scrollView.contentSize.height) ? (scrollView.tz_height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end
