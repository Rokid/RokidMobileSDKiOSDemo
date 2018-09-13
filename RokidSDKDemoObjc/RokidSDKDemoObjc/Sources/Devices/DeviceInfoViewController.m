//
//  DeviceInfoViewController.m
//  RokidSDKDemoObjc
//
//  Created by coco zhou on 2018/2/9.
//  Copyright © 2018年 Rokid. All rights reserved.
//

#import "DeviceInfoViewController.h"
#import "MBProgressHUD.h"
#import "UIAlertController+Rokid.h"

#define  KEY_SHOW_LOG @"showlog"
#define  KEY_TMP   @"temp"

@interface DeviceInfoTextViewCell: UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView * textview;
@end
@implementation DeviceInfoTextViewCell
@end



@interface DeviceInfoViewController ()
@property(nonatomic, strong) NSMutableArray * itemsArray;
@end

@implementation DeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.itemsArray = [[NSMutableArray alloc] initWithObjects:
                        @"4.2 获取 设备基本信息",
                        @"4.3 获取设备的 Loaction 信息",
                        @"4.4 更新设备的 Location 信息",
                        @"4.5 更新当前设备的昵称",
                        @"4.6 获取系统版本信息",
                        @"4.7 开始系统升级",
                        @"4.8 设备恢复出厂设置",
                        @"4.9 解绑设备",
                        @"4.10 设置当前设备(本地缓存)",
                        @"4.11 获取当前设备(本地缓存)",
                        @"4.12 ping当前设备",
                        @"4.13 设置夜间模式",
                        @"4.14 取消夜间模式",
                        KEY_SHOW_LOG,
                       nil];
    
    
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DeviceInfoViewControllerCell"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCell : (NSIndexPath *) indexPath  {
    if ([self.itemsArray containsObject:KEY_SHOW_LOG]){
        NSUInteger index = [self.itemsArray indexOfObject:KEY_SHOW_LOG];
        [self.itemsArray replaceObjectAtIndex:index withObject:KEY_TMP];
    }
    
    [self.itemsArray insertObject:KEY_SHOW_LOG atIndex:indexPath.row+1];
    
    if ([self.itemsArray containsObject:KEY_TMP]){
        [self.itemsArray removeObject:KEY_TMP];
    }

    [self.tableview reloadData];
}
- (NSString *)getInfo : (NSIndexPath *) indexPath {
    
    NSString * ret = @"";
    switch (indexPath.row) {
        case 0:{
            return @"....";
        }
        case 1:{ // 4.2 获取 设备基本信息
            NSDictionary * tmp = [RokidMobileSDK.device getBasicInfoWithDeviceId: self.device.id] ;
            return [tmp description];
        }
        case 2:{ // @"4.3 获取设备的 Loaction 信息"
            ret =  @"getLocation not open ";
            return ret;
        }
        case 3:{ // @"4.4 更新设备的 Location 信息"
            ret = @"update Location not open";
            return ret;
        }
        case 4:{ // @"4.5 更新当前设备的昵称"
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [RokidMobileSDK.device updateNickWithDeviceId:self.device.id newNick:@"Rokider" completion:^(RKError * error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];

            }];
            ret = [NSString stringWithFormat:@"%@ --> %@", self.device.nick, @"Rokider"];
            return ret;
        }
        case 5:{ // @"4.6 获取系统版本信息"
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [RokidMobileSDK.device getVersionWithDeviceId:self.device.id completion:^(RKError * error, SDKDeviceVersionInfo * versionInfo) {
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSString * str = [versionInfo description];
                NSLog(@"%@", [NSString stringWithFormat:@"versionInfo:%@",str]);
            }];
            
            return @"请查看log";
        }
        case 6:{ // @"4.7 开始系统升级"
            [UIAlertController showAlertFrom:self Title:@"提示" Message:@"进行系统升级" handle:^(UIAlertAction *action) {
                
                [RokidMobileSDK.device startSystemUpdateWithDeviceId:self.device.id completion:^(BOOL succeed) {
                    NSLog(succeed? @"success" : @"failed");
                }];
                
            } cancel:^(UIAlertAction *action) {
                
            }];
            
            return @"系统升级...";
        }
        case 7:{ // @"4.8 设备恢复出厂设置"
            [UIAlertController showAlertFrom:self Title:@"提示" Message:@"设备恢复出厂设置" handle:^(UIAlertAction *action) {
                
                [RokidMobileSDK.device resetDeviceWithDeviceId:self.device.id completion:^(BOOL succeed) {
                    NSLog(succeed? @"success" : @"failed");
                }];
                
            } cancel:^(UIAlertAction *action) {
                
            }];
            
            return @"设备恢复出厂设置...";
        }
        case 8:{ // 4.9 解绑设备
            [UIAlertController showAlertFrom:self Title:@"提示"  Message:@"解绑设备" handle:^(UIAlertAction *action) {
                
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [RokidMobileSDK.device unbindDeviceWithDeviceId:self.device.id completion:^(RKError * error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
               
            } cancel:^(UIAlertAction *action) {
                
            }];
            
            return @"解绑设备...";
        }
        case 9:{ // 4.10 设置当前设备(本地缓存)
            [UIAlertController showAlertFrom:self Title:@"提示"  Message:@"设置当前设备" handle:^(UIAlertAction *action) {
                [RokidMobileSDK.device setCurrentDeviceWithDevice:self.device];
                
            } cancel:^(UIAlertAction *action) {
                
            }];
            
            return @"设置当前设备...";
        }
        case 10:{ // @"4.11 获取当前设备(本地缓存)"
            RKDevice * device = [RokidMobileSDK.device getCurrentDevice];
            ret = [NSString stringWithFormat:@"ota: %@, id: %@, rcVersion:%@, maxAlarmVolume:%.f,  alarmVolume : %.f",device.ota,device.id,device.rcVersion, device.maxAlarmVolume, device.alarmVolume ];
            
            return ret;
        }
        case 11:{ // @"4.12 ping当前设备"
            RKDevice * device = [RokidMobileSDK.device getCurrentDevice];
            [RokidMobileSDK.device pingDeviceWithDevice:device completion:^(RKError * error, RKDevice * device) {
                NSLog(@"%@, %@",error.message, device);
                NSLog(@"info: %ld", (long)device.alive);
                switch (device.onlineState) {
                    case 0:
                        NSLog(@"offline");
                        break;
                    case 1:
                        NSLog(@"connecting");
                        break;
                    case 2:
                        NSLog(@"online");
                        break;

                    default:
                        break;
                }
                
            }];
      
            return [NSString stringWithFormat:@"ota: %@, id: %@, rcVersion:%@, maxAlarmVolume:%.f,  alarmVolume : %.f alive:%s",device.ota,device.id,device.rcVersion, device.maxAlarmVolume, device.alarmVolume, device.alive ? "yes" : "no" ];
        }
        case 12: { // 设置夜间模式
            RKDevice * device = [RokidMobileSDK.device getCurrentDevice];
            SDKDeviceNightMode * nightMode = [SDKDeviceNightMode init];
            nightMode.state = SDKDeviceNightModeStateOpen;
            nightMode.startTime = @"23:00";
            nightMode.endTime = @"7:00";
            
            [RokidMobileSDK.device updateNightModeWithDevice:device nightmode:nightMode completion:^(RKError * error, RKDevice * device) {
                // TODO 处理回调
            }];
            
            ret = [NSString stringWithFormat:@"startTime: %@, endTime:%@", nightMode.startTime,nightMode.endTime];
            return ret;
        }
        case 13: { // 取消夜间模式
            RKDevice * device = [RokidMobileSDK.device getCurrentDevice];
            
            [RokidMobileSDK.device getNightModeWithDevice:device completion:^(RKError * error, SDKDeviceNightMode * nightMode) {
                
                if (error != nil) {
                    return;
                }
                
                // 状态设置关闭
                nightMode.state = SDKDeviceNightModeStateClose;
                [RokidMobileSDK.device updateNightModeWithDevice:device nightmode:nightMode completion:^(RKError * error, RKDevice * device) {
                    // TODO 处理回调
                }];
            }];
            
            return @"取消夜间模式";
        }
        default:
            break;
    }
    
    return  ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[self.itemsArray objectAtIndex:indexPath.row] isEqualToString: KEY_SHOW_LOG]){
        return  100;
    }else{
        return  44;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([[self.itemsArray objectAtIndex:indexPath.row] isEqualToString: KEY_SHOW_LOG]){
       DeviceInfoTextViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceInfoTextViewCell"];
           cell.textview.text = [self getInfo:indexPath];
        return cell;
    }else{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceInfoViewControllerCell"];
        cell.backgroundColor =  UIColor.whiteColor;
        cell.textLabel.text = [self.itemsArray objectAtIndex:indexPath.row];
        return  cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.itemsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self addCell:indexPath];
}

@end
