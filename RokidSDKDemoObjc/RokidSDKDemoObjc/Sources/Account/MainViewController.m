//
//  ViewController.m
//  RokidSDKDemoObjc
//
//  Created by Yock on 2017/11/29.
//  Copyright © 2017年 Rokid. All rights reserved.
//

#import "MainViewController.h"
#import "Properties.h"
#import "MBProgressHUD+Extensions.h"
#import "VerifySMSCodeViewController.h"
#import "ChangePasswordViewController.h"

@import RokidSDK;

@interface MainViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *changePwdBtn;
@property (weak, nonatomic) IBOutlet UIButton *fetchBtn;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicator];
    
    /*
     * 等 SDK init 完成后才能进行 UI 操作, 简化 Demo 的逻辑
     */
    self.view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self updateButtonState:NO];
    
    RokidMobileSDK.shared.env = SDKEnvRelease;
    RokidMobileSDK.shared.openLog = true;

    // SDK init
    [RokidMobileSDK.shared initSDKWithAppKey:Properties.shared.appKey
                                   appSecret:Properties.shared.appSecret
                                   accessKey:Properties.shared.accessKey
                                  completion:^(RKError * error) {
                                      NSLog(@"[SDK init] result = %@", error);
                                      
                                      // SDK init 完成
                                      if (!error) {
                                          NSLog(@"SDK init success");
                                          self.view.userInteractionEnabled = YES;
                                          [self addNotificationObserver];
                                      };
                                  }];
}

- (void)tapView:(UITapGestureRecognizer *)gesture {
    [self.telInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
}

- (void)updateButtonState:(BOOL)isLogin {
    self.changePwdBtn.enabled = isLogin;
    self.updateBtn.enabled = isLogin;
    self.fetchBtn.enabled = isLogin;
}

- (IBAction)login:(UIButton *)sender {
    [self tapView:nil];
    
    [RokidMobileSDK.account tempLoginWithName:self.telInput.text
                                     password:self.passwordInput.text
                                     complete:^(NSString * uid, NSString * token, RKError * error) {
                                         if (!error) {
                                             NSLog(@"[Login] OK" );
                                             [[NSNotificationCenter defaultCenter] postNotificationName: @"loginNotification" object:@"loginOK"];
                                             
                                             [MBProgressHUD showMessage:@"成功，可以其他操作了" to:self.view afterDelay:1.5];
                                             
                                             [self updateButtonState:YES];
                                             
                                         } else {
                                             [[NSNotificationCenter defaultCenter] postNotificationName: @"loginNotification" object:@"loginErr"];
                                             
                                             NSError *newError = [NSError errorWithDomain:@"RKError"
                                                                                     code:error.code
                                                                                 userInfo:@{
                                                                                            @"Message": error.message? :@""
                                                                                            }];
                                             NSLog(@"[Login] Error %@", newError);
                                             
                                             [MBProgressHUD showMessage:error.message to:self.view afterDelay:1.5];
                                             
                                         }
                                     }];
}

- (IBAction)logout:(UIBarButtonItem *)sender {
    [RokidMobileSDK.account logout];
}


- (IBAction)resetPwdClick:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VerifySMSCodeViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VerifySMSCodeViewController"];
    vc.requestSCodeFor = ResetPassword;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)changePwdClick:(id)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChangePasswordViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    vc.pwdOperate = Change;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)fetchUserInfo:(UIButton *)sender {
    [RokidMobileSDK.account fetchUserInfoWithCompletion:^(RKError * error, SDKUserInfo * userInfo) {
        if (error == nil) {
            NSLog(@"user info nickname = %@, birth = %@, gender = %@, userId = %@", userInfo.nickname, userInfo.birthday, userInfo.gender, userInfo.userId);
        }
    }];
}

- (IBAction)updateUserInfo:(UIButton *)sender {
    [RokidMobileSDK.account updateUserInfoWithNickname:@"rokiddemo"
                                                gender:@"male"
                                              birthday:@"2014/11/26"
                                            completion:^(RKError * error) {
                                                if (error == nil) {
                                                    [MBProgressHUD showMessage:@"更新成功！" to:self.view afterDelay:1.5];
                                                }
                                            }];
}


// 注册事件监听，监听 SDK 的 各种事件
- (void)addNotificationObserver {
    /*
     card manager 缓存的 cardlist 改变
     userinfo: {
     appended: card array,
     removed: card array,
     }
     */
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.CardReceived object:nil];
    
    /*
     device manager 的 current device 改变
     userinfo: {
     previousId: 之前的id
     id: 现在的id
     }
     */
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.CurrentDeviceUpdated object:nil];
    
    /*
     device manager 缓存的 device list 改变
     userinfo: {
     appended: device array,
     removed: device array,
     }
     */
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.DeviceListUpdated object:nil];
    
    /*
     device 在线状态改变
     userinfo: {
     alive: 0 / 1,
     id: device id,
     }
     */
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.DeviceStatusUpdated object:nil];
    
    /*
     设备音量改变
     object: device
     可以通过 device.alarmVolume 获取当前音量
     */
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.AlarmVolumeChanged object:nil];
    
    /*
     账号被登出 (单点登录)
     */
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.ShouldLogout object:nil];
    
    /*
     媒体播放中
     */
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.MediaPlaying object:nil];
    
    /*
     媒体暂停
     */
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.MediaPaused object:nil];
    
    /*
     媒体停止
     */
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.MediaStopped object:nil];
    
    [NSNotificationCenter.rokidsdk addObserver:self selector:@selector(handleNotification:) name:SDKNotificationName.ShouldLogout object:nil];
}

- (void)handleNotification: (NSNotification *)notification {
    NSLog(@"[ViewContoller handleNotification] %@", notification);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
