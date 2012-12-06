//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Austin on 10/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(id)operand;
- (void)clear;
- (double)performOperation:(NSString *)operation;

@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;

@end
