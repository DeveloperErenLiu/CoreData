//
//  User+CoreDataProperties.h
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/27.
//  Copyright © 2016年 刘小壮. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *age;
@property (nullable, nonatomic, retain) NSString *sectionName;

@end

NS_ASSUME_NONNULL_END
