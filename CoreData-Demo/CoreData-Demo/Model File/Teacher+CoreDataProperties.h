//
//  Teacher+CoreDataProperties.h
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/26.
//  Copyright © 2016年 刘小壮. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Teacher.h"

NS_ASSUME_NONNULL_BEGIN

@interface Teacher (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *name;
// 创建一个Teacher对应多个Student的关系，所以这里用NSSet来表示
// 一个NSSet类型的实体，都会单独生成四个操作方法
@property (nullable, nonatomic, retain) NSSet<Student *> *students;

@end

@interface Teacher (CoreDataGeneratedAccessors)
// students属性对应的四个操作方法
- (void)addStudentsObject:(Student *)value;
- (void)removeStudentsObject:(Student *)value;
- (void)addStudents:(NSSet<Student *> *)values;
- (void)removeStudents:(NSSet<Student *> *)values;

@end

NS_ASSUME_NONNULL_END
