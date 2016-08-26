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
 Demo和博客中所有代码都经过测试，运行都没有问题。
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
    
    // 遍历获取到的数组，并执行修改操作
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
    
    // 遍历输出查询结果
    [students enumerateObjectsUsingBlock:^(Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Student Name : %@, Age : %ld", obj.name, [obj.age integerValue]);
    }];
    
    // 错误处理
    if (error) {
        NSLog(@"CoreData Ergodic Data Error : %@", error);
    }
}

#pragma mark - ----- Page && Fuzzy ------

/** 
 分页查询
 */
- (IBAction)pageSearch:(UIButton *)sender {
    // 创建获取数据的请求对象，并指明操作Student表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 设置查找起始点，这里是从搜索结果的第六个开始获取
    request.fetchOffset = 6;
    
    // 设置分页，每次请求获取六个托管对象
    request.fetchLimit = 6;
    
    // 设置排序规则，这里设置年龄升序排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    request.sortDescriptors = @[descriptor];
    
    // 执行查询操作
    NSError *error = nil;
    NSArray<Student *> *students = [self.schoolMOC executeFetchRequest:request error:&error];
    
    // 遍历输出查询结果
    [students enumerateObjectsUsingBlock:^(Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Page Search Result Name : %@, Age : %ld", obj.name, [obj.age integerValue]);
    }];
    
    // 错误处理
    if (error) {
        NSLog(@"Page Search Data Error : %@", error);
    }
}

/** 
 模糊查询
 */
- (IBAction)fuzzySearch:(UIButton *)sender {
    // 创建获取数据的请求对象，设置对Student表进行操作
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 创建模糊查询条件。这里设置的带通配符的查询，查询条件是结果包含lxz
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", @"*lxz*"];
    request.predicate = predicate;
    
    // 执行查询操作
    NSError *error = nil;
    NSArray<Student *> *students = [self.schoolMOC executeFetchRequest:request error:&error];
    
    // 遍历输出查询结果
    [students enumerateObjectsUsingBlock:^(Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Fuzzy Search Result Name : %@, Age : %ld", obj.name, [obj.age integerValue]);
    }];
    
    // 错误处理
    if (error) {
        NSLog(@"Fuzzy Search Data Error : %@", error);
    }
    
    /** 
     模糊查询的关键在于设置模糊查询条件，除了上面的模糊查询条件，还可以设置下面三种条件
     */
    // 以lxz开头
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@", @"lxz"];
    // 以lxz结尾
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"name ENDSWITH %@"  , @"lxz"];
    // 其中包含lxz
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"name contains %@"  , @"lxz"];
    // 还可以设置正则表达式作为查找条件，这样使查询条件更加强大，下面只是给了个例子
    NSString *mobile = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobile];
}

#pragma mark - ----- Fetch Request ------

/** 
 加载模型文件中设置的FetchRequest请求模板，模板名为StudentAge，在School.xcdatamodeld中设置
 */
- (IBAction)fetchRequest:(UIButton *)sender {
    // 通过MOC获取托管对象模型，托管对象模型相当于.xcdatamodeld文件，存储着.xcdatamodeld文件的结构
    NSManagedObjectModel *model = self.schoolMOC.persistentStoreCoordinator.managedObjectModel;
    
    // 通过.xcdatamodeld文件中设置的模板名，获取请求对象
    NSFetchRequest *fetchRequest = [model fetchRequestTemplateForName:@"StudentAge"];
    
    // 请求数据，下面的操作和普通请求一样
    NSError *error = nil;
    NSArray<Student *> *dataList = [self.schoolMOC executeFetchRequest:fetchRequest error:&error];
    
    // 遍历获取结果，并打印结果
    [dataList enumerateObjectsUsingBlock:^(Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Student.count = %ld, Student.age = %ld", dataList.count, [obj.age integerValue]);
    }];
    
    // 错误处理
    if (error) {
        NSLog(@"Execute Fetch Request Error : %@", error);
    }
}

/** 
 对请求结果进行排序
 这个排序是发生在数据库一层的，并不是将结果取出后排序，所以效率比较高
 */
- (IBAction)resultSort:(UIButton *)sender {
    // 建立获取数据的请求对象，并指明操作Student表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    // 设置请求条件，通过设置的条件，来过滤出需要的数据
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", @"*lxz*"];
    request.predicate = predicate;
    
    // 设置请求结果排序方式，可以设置一个或一组排序方式，最后将所有的排序方式添加到排序数组中
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    // NSSortDescriptor的操作都是在SQLite层级完成的，不会将对象加载到内存中，所以对内存的消耗是非常小的
    // 下面request的sort对象是一个数组，也就是可以设置多种排序条件，但注意条件不要冲突
    request.sortDescriptors = @[sort];
    
    // 执行获取请求操作，获取的托管对象将会被存储在一个数组中并返回
    NSError *error = nil;
    NSArray<Student *> *students = [self.schoolMOC executeFetchRequest:request error:&error];
    
    // 遍历返回结果
    [students enumerateObjectsUsingBlock:^(Student * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Employee Name : %@, Age : %ld", obj.name, [obj.age integerValue]);
    }];
    
    // 错误处理
    if (error) {
        NSLog(@"CoreData Fetch Data Error : %@", error);
    }
}

/** 
 获取返回结果的Count值，通过设置NSFetchRequest的resultType属性
 */
- (IBAction)getResultCount1:(UIButton *)sender {
    // 设置过滤条件，可以根据需求设置自己的过滤条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age < 24"];
    
    // 创建请求对象，并指明操作Student表
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    fetchRequest.predicate = predicate;
    
    // 这一步是关键。设置返回结果类型为Count，返回结果为NSNumber类型
    fetchRequest.resultType = NSCountResultType;
    
    // 执行查询操作，返回的结果还是数组，数组中只存在一个对象，就是计算出的Count值
    NSError *error = nil;
    NSArray *dataList = [self.schoolMOC executeFetchRequest:fetchRequest error:&error];
    
    // 返回结果存在数组的第一个元素中，是一个NSNumber的对象，通过这个对象即可获得Count值
    NSInteger count = [dataList.firstObject integerValue];
    NSLog(@"fetch request result Employee.count = %ld", count);
    
    // 错误处理
    if (error) {
        NSLog(@"fetch request result error : %@", error);
    }
}

/** 
 获取返回结果的Count值，通过调用MOC提供的特定方法
 */
- (IBAction)getResultCount2:(UIButton *)sender {
    // 设置过滤条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age < 24"];
    
    // 创建请求对象，指明操作Student表
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    fetchRequest.predicate = predicate;
    
    // 通过调用MOC的countForFetchRequest:error:方法，获取请求结果count值，返回结果直接是NSUInteger类型变量
    NSError *error = nil;
    NSUInteger count = [self.schoolMOC countForFetchRequest:fetchRequest error:&error];
    NSLog(@"fetch request result count is : %ld", count);
    
    // 错误处理
    if (error) {
        NSLog(@"fetch request result error : %@", error);
    }
}

#pragma mark - ----- 连表操作 ------
/** 
 写在博客里的
 Demo只是来辅助读者更好的理解文章中的内容，应该结合博客和Demo一起学习，只看Demo还是不能理解更深层的道理。
 */


#pragma mark - ----- Test Data ------

/** 
 添加测试数据方法
 如果需要添加其他测试数据，直接改下面的调用即可
 */
- (IBAction)addTestData:(UIButton *)sender {
    [self addStudentTestData];
}

/** 
 添加Student实体的测试数据
 */
- (void)addStudentTestData {
    for (int i = 0; i < 15; i++) {
        Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.schoolMOC];
        student.name = [NSString stringWithFormat:@"lxz %d", i];
        student.age = @(i+15);
    }
    
    NSError *error = nil;
    if (self.schoolMOC.hasChanges) {
        [self.schoolMOC save:&error];
    }
}

@end



























