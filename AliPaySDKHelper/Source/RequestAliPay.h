//
//  RequestAliPay.h
//  schoolConnection
//
//  Created by Reminisce on 16/9/5.
//  Copyright (c) 2016 小马哥. All rights reserved.
//



@interface RequestAliPay : NSObject

- (void)alipayRequset:(NSString *)orderID withName:(NSString *)proName withDesc:(NSString*)proDesc withPrice:(double)price;

@end
