//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Austin on 10/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

#define PI 3.141592;

- (NSMutableArray *)programStack {
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    
    return _programStack;
}

- (id)program {
    return [self.programStack copy];
}

+ (BOOL) isOperationTwoOperand:(NSString *)operation {
    NSSet *operations = [NSSet setWithObjects:@"+", @"-", @"*", @"-", Nil];
    
    if ([operations containsObject:operation]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isOperationOneOperand:(NSString *)operation {
    NSSet *operations = [NSSet setWithObjects:@"sin", @"cos", @"√", nil];
    
    if ([operations containsObject:operation]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isVariable:(NSString *)operation {
    if ([self isOperationOneOperand:operation] ||
        [self isOperationTwoOperand:operation] ||
        [operation isKindOfClass:[NSNumber class]] ||
        ![operation isEqualToString:@"π"]) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isOperation:(NSString*)operation {
    if ([self isOperationOneOperand:operation] ||
        [self isOperationTwoOperand:operation]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSSet *)variablesUsedInProgram:(id)program {
    NSSet *result = nil;
    if ([program isKindOfClass:[NSArray class]]) {
        
        NSMutableSet *variableUsed = [[NSMutableSet alloc] init];
        
        for (id ops in program) {
            if (!([ops isKindOfClass:[NSNumber class]] || [self isOperation:ops])) {
                [variableUsed addObject:(NSString *)ops];
            }
        }
        
        if (variableUsed.count > 0) {
            result = [NSSet setWithSet:variableUsed];
        }
        
        variableUsed = Nil;
    }
    
    return result;
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *) stack {
    NSLog(@"descriptionOfTopOfStack Enter");
    NSLog(@"stack: %@", stack);
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    NSString* result = Nil;
    
    if (topOfStack) {
        if ([topOfStack isKindOfClass:[NSNumber class]]) {
            NSNumber* operand = topOfStack;
            NSLog(@"top of stack: %g", operand);
            result = [operand stringValue];
        } else if ([topOfStack isKindOfClass:[NSString class]]) {
            NSString* item = topOfStack;
            if ([self isOperation:item]) {
                if ([self isOperationTwoOperand:item]) {
                    
                    NSString* last = [self descriptionOfTopOfStack:stack];
                    NSString* middle = item;
                    NSString* first = [self descriptionOfTopOfStack:stack];
                    
                    NSString* leftParan = @"(";
                    NSString* rightParan = @")";

                    result = [NSString stringWithFormat:@"%@%@ %@ %@%@", 
                              leftParan, first, middle, last, rightParan];
                    if ([stack count] <= 0) {
                        //remove the outer blackets
                        if ([result hasPrefix:@"("] && [result hasSuffix:@")"]) {
                            result = [result substringWithRange: NSMakeRange(1, [result length] - 2)];
                        
                        }
                    }
                } else if ([self isOperationOneOperand:item]) {
                    result = [NSString stringWithFormat:@"%@ (%@)",
                              item, [self descriptionOfTopOfStack:stack]];
                }
            } else {
                result = item;
            }
        }
    }
    
    NSLog(@"Return %@", result);
    
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    return [self descriptionOfTopOfStack:stack];

}

- (void)pushOperand:(id)operand {
     [self.programStack addObject:operand];
}

- (void) clear {
    if (self.programStack) {
        [self.programStack removeAllObjects];
    }
}

- (double)performOperation:(NSString *)operation {
        
    [self.programStack addObject:operation];
    
    NSSet *variablesUsed = [[self class] variablesUsedInProgram:[self program]];
    
    NSDictionary *variableValues = nil;
    if (variablesUsed) {
        variableValues = [[NSMutableDictionary alloc] init];
        for (NSString* variable in variablesUsed) {
            if ([variable isEqualToString:@"π"]) {
                [variableValues setValue:[NSNumber numberWithDouble:3.141592] forKey:variable];
            } else {
                [variableValues setValue:[NSNumber numberWithDouble:0] forKey:variable];
            }
        }
    }
    
    return [[self class] runProgram:self.program usingVariableValues:variableValues];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack {
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"√"]) {
            result = sqrt([self popOperandOffProgramStack:stack]);
        } 
//        else if ([operation isEqualToString:@"π"]) {
//            result = PI;
//        } 
    }
    
    return result;
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        
        if (variableValues) {
            for (int i = 0; i < [stack count]; i++) {
                id term = [stack objectAtIndex:i];
                if (term) {
                    if (([term isKindOfClass:[NSString class]]) &&
                        (![self.class isOperation:term])) {
                        NSNumber* value = [variableValues objectForKey:term];
                        [stack replaceObjectAtIndex:i withObject:value];
                    }
                }
            }
        }
    }
    
    return [self popOperandOffProgramStack:stack];
}

@end
