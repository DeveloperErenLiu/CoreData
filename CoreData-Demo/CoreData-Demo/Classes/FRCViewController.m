//
//  FRCViewController.m
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/27.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "FRCViewController.h"
#import "User.h"

@interface FRCViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak,   nonatomic) IBOutlet UITableView       *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultController;
@property (strong, nonatomic) NSManagedObjectContext     *chatMOC;
@end

@implementation FRCViewController

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

- (NSManagedObjectContext *)chatMOC {
    if (!_chatMOC) {
        _chatMOC = [self contextWithModelName:@"Chat"];
    }
    return _chatMOC;
}

#pragma mark - ----- NSFetchedResultsController ------

- (IBAction)refreshView:(UIButton *)sender {
    // 创建请求对象，并指明操作User表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    // 设置排序规则，指明根据age字段升序排序
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    request.sortDescriptors = @[ageSort];
    
    // 创建NSFetchedResultsController控制器实例，并绑定MOC
    NSError *error = nil;
    self.fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                       managedObjectContext:self.chatMOC
                                                                         sectionNameKeyPath:@"sectionName"
                                                                                  cacheName:nil];
    // 设置代理，并遵守协议
    self.fetchedResultController.delegate = self;
    // 执行获取请求，执行后FRC会从持久化存储区加载数据，其他地方可以通过FRC获取数据
    [self.fetchedResultController performFetch:&error];
    
    // 错误处理
    if (error) {
        NSLog(@"NSFetchedResultsController init error : %@", error);
    }
    
    // 刷新UI
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"identifier"];
    [self.tableView reloadData];
}

#pragma mark - ----- UITableView Delegate ------

// 通过FRC的sections数组属性，获取所有section的count值，将其设置为section number
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultController.sections.count;
}

// 通过当前section的下标从sections数组中取出对应的section对象，并从section对象中获取所有对象count，将其设置为row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultController.sections[section].numberOfObjects;
}

// FRC根据indexPath获取托管对象，并给cell赋值
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.fetchedResultController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell     = [tableView dequeueReusableCellWithIdentifier:@"identifier" forIndexPath:indexPath];
    cell.textLabel.text       = user.username;
    cell.detailTextLabel.text = user.age;
    return cell;
}

// 创建FRC对象时，通过sectionNameKeyPath:传递进去的section title的属性名，在这里获取对应的属性值
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.fetchedResultController.sections[section].indexTitle;
}

// 是否可以编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 这里是简单模拟UI删除cell后，本地持久化区数据和UI同步的操作。在调用下面MOC保存上下文方法后，FRC会回调代理方法并更新UI
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除托管对象
        User *user = [self.fetchedResultController objectAtIndexPath:indexPath];
        [self.chatMOC deleteObject:user];
        
        // 保存上下文环境，并做错误处理
        NSError *error = nil;
        if (![self.chatMOC save:&error]) {
            NSLog(@"tableView delete cell error : %@", error);
        }
    }
}

#pragma mark - ----- NSFetchedResultsControllerDelegate ------

// Cell数据源发生改变会回调此方法，例如添加新的托管对象等
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate: {
            User *user = [self.fetchedResultController objectAtIndexPath:indexPath];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = user.username;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
    }
}

// Section数据源发生改变回调此方法，例如修改section title等
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

// 本地数据源发生改变，将要开始回调FRC代理方法。
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

// 本地数据源发生改变，FRC代理方法回调完成。
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

// 返回section的title，可以在这里对title做进一步处理。这里修改title后，对应section的indexTitle属性会被更新。
- (nullable NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return [NSString stringWithFormat:@"sectionName %@", sectionName];
}

#pragma mark - ----- 生成测试数据 ------

- (IBAction)createTestData:(UIButton *)sender {
    for (int i = 0; i < 15; i++) {
        User *user    = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.chatMOC];
        user.username    = [NSString stringWithFormat:@"lxz %d", i];
        user.age         = [NSString stringWithFormat:@"%d", i + 15];
        user.sectionName = [NSString stringWithFormat:@"%d", i % 5];
    }
    
    NSError *error = nil;
    if (self.chatMOC.hasChanges) {
        [self.chatMOC save:&error];
    }
}

@end









































