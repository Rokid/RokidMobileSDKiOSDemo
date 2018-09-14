//
//  VuiViewController.m
//  RokidSDKDemoObjc
//
//  Created by coco zhou on 2018/2/18.
//  Copyright © 2018年 Rokid. All rights reserved.
//

#import "VuiViewController.h"
#import "UIAlertController+Rokid.h"
@import RokidSDK;

@interface VuiViewController ()
@property (strong, nonatomic)  RKDevice * device;
@end

@implementation VuiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.device = [RokidMobileSDK.device getCurrentDevice];
    if (!self.device){
        [UIAlertController showAlertFrom:self Title: @"tip"  Message:@"当前没有设备，请前往'设备'中 设置" handle:^(UIAlertAction *action) {
            
        } cancel:^(UIAlertAction *action) {
            
        }];
        return;
    }
}


- (IBAction)clickASR:(id)sender {
    [RokidMobileSDK.vui sendAsrWithAsr:@"播放白龙马" to:self.device completion:^(BOOL succeed) {
        if (succeed) {
            // TODO
        } else {
            // TODO
        }
    }];
}

- (IBAction)clickTTS:(id)sender {
    [RokidMobileSDK.vui sendTtsWithTts:@"我是若琪，有什么需要帮忙的?" to:self.device completion:^(BOOL succeed) {
        if (succeed) {
            // TODO
        } else {
            // TODO
        }
    }];
}

- (IBAction)clickSendTopicMessage:(id)sender {
    [RokidMobileSDK.vui sendMessageWithTopic:@"title" text:@"text" to:self.device completion:^(BOOL succeed) {
        if (succeed) {
            // TODO
        } else {
            // TODO
        }
    }];
}

- (IBAction)asrcfind:(id)sender {
    [RokidMobileSDK.vui asrCorrectFindWithOriginText:@"识别错误的那巨话" complete:^(RKError * error, RKTTExchangeRule * rule) {
        NSLog(@"%@",rule);
    }];
}

- (IBAction)asrcCreate:(id)sender {
    [RokidMobileSDK.vui asrCorrectCreateWithOriginText:@"识别错误的那巨话" targetText:@"识别错误的那句话"  complete:^(RKError * error, RKTTExchangeRule * rule) {
        NSLog(@"%@",rule);
    }];
}

- (IBAction)asrcUpdate:(id)sender {
    int ruleId = 2001; //当调用asrCorrectCreateWithOriginText后，才有rule，从rule中拿到id;
    [RokidMobileSDK.vui asrCorrectUpdateWithRuleId:ruleId originText:@"识别错误的那巨话" targetText:@"识别错误的那句话" complete:^(RKError * error, NSDictionary<NSString *,NSString *> * dic) {
        NSLog(@"%@",dic);
    }];
}

- (IBAction)asrcHistory:(id)sender {
    
    [RokidMobileSDK.vui asrCorrectHistoryWithPage:@"0" size:@"25" complete:^(RKError * error, NSArray<RKTTExchangeRule *> * rules) {
        NSLog(@"%@", rules);
    }];
}

- (IBAction)asrcDelete:(id)sender {
    int ruleId = 2001; //当调用asrCorrectCreateWithOriginText后，才有rule，从rule中拿到id;
    [RokidMobileSDK.vui asrCorrectDeleteWithRuleId:ruleId complete:^(RKError * error, NSDictionary* dic) {
        NSLog(@"%@", error);
    }];
}

@end
