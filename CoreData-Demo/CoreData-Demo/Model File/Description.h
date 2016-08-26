//
//  Description.h
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/26.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 *  对应Department类的depDescription属性
 */
@interface Description : NSObject <NSCoding>
@property (nonatomic, copy  ) NSString  *leaderName;
@property (nonatomic, assign) NSInteger employeeCount;
@end
