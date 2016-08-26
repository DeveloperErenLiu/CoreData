//
//  ViewController.m
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/26.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ViewController.h"
#import "Student.h"
#import "Teacher.h"
#import "Department.h"
#import "Employee.h"


/** 
 因为是Demo，所以这里就不顾及那么多代码规范了，主要是为了讲CoreData技术点。
 */

@interface ViewController ()
@property (nonatomic, strong) NSManagedObjectContext *companyMOC;
@property (nonatomic, strong) NSManagedObjectContext *schoolMOC;
@end

@implementation ViewController

#pragma mark - ----- Create CoreData Context ------

/** 
 创建上下文对象
 */
- (NSManagedObjectContext *)contextWithModelName:(NSString *)modelName {
    // 创建上下文对象，并发队列设置为主队列
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    // 创建托管对象模型，并使用Company.momd路径当做初始化参数
    NSURL *modelPath = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
    
    // 创建持久化存储调度器
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // 创建并关联SQLite数据库文件，如果已经存在则不会重复创建
    NSString *dataPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    dataPath = [dataPath stringByAppendingFormat:@"/%@.sqlite", modelName];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:nil error:nil];
    
    // 上下文对象设置属性为持久化存储器
    context.persistentStoreCoordinator = coordinator;
    
    return context;
}

- (NSManagedObjectContext *)companyMOC {
    if (!_companyMOC) {
        _companyMOC = [self contextWithModelName:@"Company"];
    }
    return _companyMOC;
}

- (NSManagedObjectContext *)schoolMOC {
    if (!_schoolMOC) {
        _schoolMOC = [self contextWithModelName:@"School"];
    }
    return _schoolMOC;
}

#pragma mark - ----- CRUD ------

/** 
 添加Student实例
 */
- (IBAction)schoolAdd:(UIButton *)sender {
    // 创建托管对象，并指明创建的托管对象所属实体名
    Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.schoolMOC];
    student.name = @"lxz";
    // 实体中所有基础数据类型，创建类文件后默认都是NSNumber类型的
    student.age = @(23);
    
    // 通过上下文保存对象，并在保存前判断是否有更改
    NSError *error = nil;
    if (self.schoolMOC.hasChanges) {
        [self.schoolMOC save:&error];
    }
    
    // 错误处理，可以在这实现自己的错误处理逻辑
    if (error) {
        NSLog(@"CoreData Insert Data Error : %@", error);
    }
}

/** 
 删除Student实例
 */
- (IBAction)schoolDelete:(UIButton *)sender {
    // 建立获取数据的请求对象，指明对Student实体进行删除操作
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 创建谓词对象，过滤出符合要求的对象，也就是要删除的对象
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", @"lxz"];
    request.predicate = predicate;
    
    // 执行获取操作，找到要删除的对象
    NSError *error = nil;
    NSArray<Student *> *students = [self.schoolMOC executeFetchRequest:request error:&error];
    
    // 遍历符合删除要求的对象数组，执行删除操作
    [students enumerateObjectsUsingBlock:^(Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.schoolMOC deleteObject:obj];
    }];
    
    // 保存上下文，并判断当前上下文是否有改动
    if (self.schoolMOC.hasChanges) {
        [self.schoolMOC save:nil];
    }
    
    // 错误处理
    if (error) {
        NSLog(@"CoreData Delete Data Error : %@", error);
    }
}

/** 
 修改Student实例
 */
- (IBAction)schoolUpdate:(UIButton *)sender {
    // 建立获取数据的请求对象，并指明操作的实体为Student
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 创建谓词对象，设置过滤条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", @"lxz"];
    request.predicate = predicate;
    
    // 执行获取请求，获取到符合要求的托管对象
    NSError *error = nil;
    NSArray<Student *> *students = [self.schoolMOC executeFetchRequest:request error:&error];
    [students enumerateObjectsUsingBlock:^(Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.age = @(24);
    }];
    
    // 将上面的修改进行存储
    if (self.schoolMOC.hasChanges) {
        [self.schoolMOC save:nil];
    }
    
    // 错误处理
    if (error) {
        NSLog(@"CoreData Update Data Error : %@", error);
    }
}

/** 
 查找Student实例
 */
- (IBAction)schoolSearch:(UIButton *)sender {
    // 建立获取数据的请求对象，指明操作的实体为Student
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 执行获取操作，获取所有Student托管对象
    NSError *error = nil;
    NSArray<Student *> *students = [self.schoolMOC executeFetchRequest:request error:&error];
    [students enumerateObjectsUsingBlock:^(Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Student Name : %@, Age : %ld", obj.name, [obj.age integerValue]);
    }];
    
    // 错误处理
    if (error) {
        NSLog(@"CoreData Ergodic Data Error : %@", error);
    }
}

@end



























