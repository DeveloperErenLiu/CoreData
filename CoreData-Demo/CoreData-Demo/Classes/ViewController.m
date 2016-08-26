//
//  ViewController.m
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/26.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

/** 
 创建上下文对象
 */
- (NSManagedObjectContext *)context {
    // 创建上下文对象，并发队列设置为主队列
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    // 创建托管对象模型，并使用Company.momd路径当做初始化参数
    NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"Company" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
    
    // 创建持久化存储调度器
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // 创建并关联SQLite数据库文件，如果已经存在则不会重复创建
    NSString *dataPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    dataPath = [dataPath stringByAppendingFormat:@"/%@.sqlite", @"Company"];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:nil error:nil];
    
    // 上下文对象设置属性为持久化存储器
    context.persistentStoreCoordinator = coordinator;
    
    return context;
}

@end



























