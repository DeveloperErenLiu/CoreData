//
//  Description.m
//  CoreData-Demo
//
//  Created by 刘小壮 on 16/8/26.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import "Description.h"

static NSString * const kLeaderNameKey    = @"leaderName";
static NSString * const kEmployeeCountKey = @"leaderName";

@implementation Description

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.leaderName    = [decoder decodeObjectForKey:kLeaderNameKey];
        self.employeeCount = [decoder decodeIntegerForKey:kEmployeeCountKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.leaderName forKey:kLeaderNameKey];
    [coder encodeInteger:self.employeeCount forKey:kEmployeeCountKey];
}

@end
