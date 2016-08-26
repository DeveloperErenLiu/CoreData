//
//  Teacher+CoreDataProperties.m
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/26.
//  Copyright © 2016年 刘小壮. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Teacher+CoreDataProperties.h"
#import "Student.h"

@implementation Teacher (CoreDataProperties)

@dynamic subject;
@dynamic name;
@dynamic students;

@end
