//
//  Department+CoreDataProperties.h
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/26.
//  Copyright © 2016年 刘小壮. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Department.h"
#import "Description.h"

NS_ASSUME_NONNULL_BEGIN

@interface Department (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate          *createDate;
@property (nullable, nonatomic, retain) NSString        *depName;
// 下面是自定义OC类型的属性，属性对应的类需要实现NSCoding协议
@property (nullable, nonatomic, retain) Description     *depDescription;
@property (nullable, nonatomic, retain) NSManagedObject *employee;

@end

NS_ASSUME_NONNULL_END
