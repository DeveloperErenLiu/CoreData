//
//  Employee+CoreDataProperties.h
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/26.
//  Copyright © 2016年 刘小壮. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Employee.h"

NS_ASSUME_NONNULL_BEGIN

@interface Employee (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate     *brithday;
@property (nullable, nonatomic, retain) NSNumber   *height;
@property (nullable, nonatomic, retain) NSString   *name;
@property (nullable, nonatomic, retain) NSNumber   *age;
@property (nullable, nonatomic, retain) Department *department;

@end

NS_ASSUME_NONNULL_END
