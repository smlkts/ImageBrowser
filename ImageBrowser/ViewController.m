//
//  ViewController.m
//  ImageBrowser
//
//  Created by 张雁军 on 19/06/2017.
//  Copyright © 2017 张雁军. All rights reserved.
//

#import "ViewController.h"
#import "IBController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *w_iv;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)browse_w:(id)sender {
    UINavigationController *nccc = [IBController controller];
    IBController *browsevc = (IBController *)nccc.topViewController;
    NSMutableArray *temp1 = [NSMutableArray new];
    for (int i = 1; i < 6; i++) {
        IBModel *im = [[IBModel alloc] init];
        NSString *name = [NSString stringWithFormat:@"%d",i];
        im.image = [UIImage imageNamed:name];
        [temp1 addObject:im];
    }
    browsevc.startIndex = 1;
    browsevc.images = temp1;
    browsevc.fromView = _w_iv;
    [self presentViewController:nccc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
