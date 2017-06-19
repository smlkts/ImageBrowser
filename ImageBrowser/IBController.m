//
//  IBController.m
//  ImageBrowser
//
//  Created by 张雁军 on 2017/5/23.
//  Copyright © 2017年 smlkts. All rights reserved.
//

#import "IBController.h"
#import "IBCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIImageView+WebCache.h>
#import "ActionSheet.h"
#import <MBProgressHUD.h>
#import "IBPresent.h"
#import "IBDismiss.h"
#import "UIView+Layout.h"

@interface IBController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIViewControllerTransitioningDelegate>
//@property (nonatomic, strong) UIView *fromView;
@property (nonatomic) BOOL isFirstShow;
@property (nonatomic, strong) IBPresent *transitioning;
@property (nonatomic, strong) IBDismiss *dismissTrans;
@end

static NSString * const cellIdentifier = @"Cell";

@implementation IBController{
    UIPageControl *_pageControl;
    UICollectionView *_collectionView;
}

+ (UINavigationController *)controller{
    IBController *vc = [[IBController alloc] init];
    vc.automaticallyAdjustsScrollViewInsets = NO;
    vc.transitioning = [[IBPresent alloc] init];
    vc.dismissTrans = [[IBDismiss alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.navigationBarHidden = YES;
    nc.transitioningDelegate = vc;
    nc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    return nc;
}

//- (instancetype)init{
//    if (self = [super init]) {
//        self.transitioningDelegate = self;
//        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self];
//        return nc;
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor blackColor];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.bounds.size.width + 20, self.view.bounds.size.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.bounds.size.width + 20, self.view.bounds.size.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[IBCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-10-30, self.view.bounds.size.width, 30)];
    [self.view addSubview:_pageControl];

    _isFirstShow = YES;

    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_startIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    _pageControl.currentPage = _startIndex;

}
- (void)setImages:(NSArray<IBModel *> *)images{
    if (_images != images) {
        _images = images;
        [_collectionView reloadData];
        _pageControl.numberOfPages = _images.count;
    }
}

- (void)setStartIndex:(NSInteger)startIndex{
    if (_startIndex != startIndex) {
        _startIndex = startIndex;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.bounds.size.width + 20) * 0.5);
    NSInteger currentPage = offSetWidth / (self.view.bounds.size.width + 20);
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        _pageControl.currentPage = _currentPage;
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IBCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.imageModel = _images[indexPath.row];
    cell.singleTap = ^{
        [self hide];
    };
    cell.longPress = ^{
        [self storeImageToLibrary];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    IBCell *imagecell = (IBCell *)cell;
    if (_isFirstShow) {
        imagecell.imageView.tz_width = imagecell.scrollView.tz_width;
        UIImage *image = imagecell.imageView.image;
        if (image.size.width/image.size.height > imagecell.tz_width/imagecell.tz_height) {
            imagecell.imageView.tz_width = _fromView.tz_height * imagecell.imageView.tz_width / imagecell.imageView.tz_height;
            imagecell.imageView.tz_height = _fromView.tz_height;
        }else{
            imagecell.imageView.tz_height = _fromView.tz_width * imagecell.imageView.tz_height / imagecell.imageView.tz_width;
            imagecell.imageView.tz_width = _fromView.tz_width;
        }
        
        CGRect fromRect = [_fromView.superview convertRect:_fromView.frame toView:self.view];
        imagecell.imageView.center = CGPointMake(CGRectGetMidX(fromRect), CGRectGetMidY(fromRect));

        [UIView animateWithDuration:.25 animations:^{
            [imagecell ul_layoutSubviews];
        } completion:^(BOOL finished) {
            _isFirstShow = NO;
        }];
    }else{
        [imagecell ul_layoutSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(IBCell *)cell ul_layoutSubviews];
}

#pragma mark - show

- (void)show{
//    UIView *targetView = [UIApplication sharedApplication].keyWindow;
//    [targetView addSubview:self.view];
//    self.view.alpha = 0;
//    [UIView animateWithDuration:0.25 animations:^{
//        self.view.alpha = 1;
//    } completion:^(BOOL finished) {
//        
//    }];
}

- (void)hide{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    return;
    if (_currentPage == _startIndex) {
        IBCell *imagecell = (IBCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPage inSection:0]];
        CGRect toRect = [_fromView.superview convertRect:_fromView.frame toView:imagecell.scrollView];
        [UIView animateWithDuration:2.25 animations:^{
//            imagecell.imageWrapperView.frame = toRect;
            imagecell.imageView.frame = toRect;
            imagecell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }else{
        [UIView animateWithDuration:.35 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            self.view.alpha = 1;
            [self.view removeFromSuperview];
        }];
    }
}

- (UIImageView *)currentImageView{
    if (_currentPage == _startIndex) {
        IBCell *imagecell = (IBCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPage inSection:0]];
        return imagecell.imageView;
    }else{
        return nil;
    }
}

- (UIImage *)currentImage{
    UIImage *image;
    IBModel *model = self.images[_currentPage];
    if ([model.image isKindOfClass:[UIImage class]]) {
        image = model.image;
    }else if ([model.image isKindOfClass:[NSString class]] && [model.image length] > 0){
        if ([[model.image lowercaseString] hasPrefix:@"http"]) {
            image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:model.image];
        }else{
            image = [UIImage imageWithContentsOfFile:model.image];
        }
    }
    return image;
}

- (void)storeImageToLibrary{
    UIImage *image = [self currentImage];
    if (image) {
        ActionSheet *sheet = [[ActionSheet alloc] initWithTitle:nil items:@[@"保存图片"] action:^(NSUInteger selectedItem) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                lib = nil;
                if (error) {
                    //                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"图片保存失败";
                    hud.detailsLabel.text = error.localizedDescription;
                    [hud hideAnimated:YES afterDelay:0.8];
                }else{
                    //                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"已保存";
                    [hud hideAnimated:YES afterDelay:0.8];
                }
            }];
        }];
        [sheet showInView:self.view];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self.transitioning;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self.dismissTrans;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
