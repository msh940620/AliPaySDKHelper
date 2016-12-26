//
//  RequestAliPay.m
//  schoolConnection
//
//  Created by Reminisce on 16/9/5.
//  Copyright (c) 2016 小马哥. All rights reserved.
//

#import <AlipaySDK/AlipaySDK.h>
#import "RequestAliPay.h"
#import "Order.h"
#import "DataSigner.h"
#import "AliPaySetting.h"
@implementation RequestAliPay

#pragma mark -- 支付宝支付
- (void)alipayRequset:(NSString *)orderID withName:(NSString *)proName withDesc:(NSString*)proDesc withPrice:(double)price
{
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */

    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *privateKey = ALI_PAY_PRIVATE_KEY;
    NSString *appID = ALI_PAY_APP_ID;
    NSString *seller = ALI_PAY_SELLER;
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/

    //partner和seller获取失败,提示
    if ([appID length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少appId或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    // NOTE: app_id设置
    order.app_id = appID;
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    // NOTE: 支付版本
    order.version = @"1.0";
    // NOTE: sign_type设置
    order.sign_type = @"RSA";
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    order.biz_content.body = proDesc;
    order.biz_content.subject = proName;
    order.biz_content.out_trade_no = orderID; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", price]; //商品价格
    order.biz_content.seller_id = seller;

    order.notify_url = ALI_PAY_NOTIFY_URL;
    order.charset = @"utf-8";

    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);

    ///       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderInfo];

    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
        NSString *appScheme = @"schoolConnection";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];

        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);

            NSInteger resultCode = [resultDic[@"resultStatus"] integerValue];

            if (resultCode == 9000)
            {
                //验证签名成功，交易结果无篡改
                //成功 跳转到  交易成功 界面

            }else{

                //支付失败
                if(resultCode == 8000)
                {
                    //正在处理中
                }else if(resultCode==4000)
                {
                    //订单支付失败
                }else if(resultCode==6001){
                    //用户中途取消
                }else if(resultCode==6002){
                    //网络连接错误
                }
            }
        }];
    }
}


@end
