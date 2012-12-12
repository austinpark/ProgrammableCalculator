//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Austin on 10/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL isMinus;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize history = _history;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize isMinus = _isMinus;

#define PI 3.141592

- (CalculatorBrain *)brain {
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    
    return _brain;
}

- (IBAction)deletePressed {
    
    NSInteger size = [self.display.text length] - 1;
    
    if (size > 0) {
        self.display.text = [self.display.text substringToIndex:size];
    } else {
        self.display.text = @"0";
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
}

- (void) displayHistory {
    self.history.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
}

- (IBAction)signChangePressed {
    if (self.isMinus) {
        self.isMinus = NO;
    } else {
        self.isMinus = YES;
    }
    
    if (self.isMinus && self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [@"-" stringByAppendingString:self.display.text];
    } else if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text hasPrefix:@"-"]) {
            self.display.text = [self.display.text substringFromIndex:1];
        }
    }
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
        
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        if (self.isMinus) {
            self.display.text =	 [@"-" stringByAppendingString:digit];
        } else {
            self.display.text = digit;
        }
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}
- (IBAction)variablePressed:(id)sender {
    NSString *variable = [sender currentTitle];
    self.display.text = variable;
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.isMinus = NO;
}

- (BOOL) isNumeric:(NSString *)input {
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:input];
    return [alphaNumbersSet isSupersetOfSet:stringSet];
}

- (IBAction)enterPressed {
    
    if ([self isNumeric:self.display.text]) {
        [self.brain pushOperand:[NSNumber numberWithDouble:[self.display.text doubleValue]]];
    } else {
        [self.brain pushOperand:self.display.text];
    }
  
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.isMinus = NO;
    
    [self displayHistory];
}

- (IBAction)operationPressed:(id)sender {
    
    NSString *operation = [sender currentTitle];
    
    [self enterPressed];
    
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self displayHistory];
}

- (IBAction)dotPressed {
    NSRange range = [self.display.text rangeOfString:@"."];
    
    if (range.location == NSNotFound) {
        if (!self.userIsInTheMiddleOfEnteringANumber) {
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
        self.display.text = [self.display.text stringByAppendingString:@"."];        	
    }
}
- (IBAction)clearPressed {
    [self.brain clear];
    self.display.text = @"0";
    self.history.text=@"";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.isMinus = NO;
}
- (IBAction)piPressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    self.display.text = @"π";
}

- (void)viewDidUnload {
    [self setHistory:nil];
    [self setVariableDisplay:nil];
    [super viewDidUnload];
}
@end
