//
//  KHDVerifiedPaymentViewController.m
//  demo-ios
//
//  Created by Iván Galaz-Jeria on 10/23/14.
//  Copyright (c) 2014 khipu. All rights reserved.
//

#define YOUR_SOFTDRINK @"Tu bebida es"
#define SUPER_SIZED_SOFTDRINK @"Agrandaste tu Bebida"
#define SUPER_SIZED_FRIES @"Agrandaste tus Papas"
#define ADDED_ICECREAM @"Agregaste Helado"

#define NO_SUPER_SIZED_SOFTDRINK @"No agrandaste tu Bebida"
#define NO_SUPER_SIZED_FRIES @"No agrandaste tus Papas"
#define NO_ADDED_ICECREAM @"No agregaste Helado"


#import "KHDVerifiedPaymentViewController.h"

@interface KHDVerifiedPaymentViewController ()
@property (weak, nonatomic) IBOutlet UILabel *comboUILabel;
@property (weak, nonatomic) IBOutlet UILabel *amountUILabel;
@property (weak, nonatomic) IBOutlet UILabel *orderUILabel;
@property (weak, nonatomic) IBOutlet UILabel *softDrinkUILabel;
@property (weak, nonatomic) IBOutlet UILabel *superSizeFriesUILabel;
@property (weak, nonatomic) IBOutlet UILabel *superSizeSoftDrinkUILabel;
@property (weak, nonatomic) IBOutlet UILabel *iceCreamUILabel;

@end

@implementation KHDVerifiedPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.softDrinkUILabel.text = [NSString stringWithFormat:@"%@ %@", YOUR_SOFTDRINK, [[NSUserDefaults standardUserDefaults] valueForKey:@"SOFT_DRINK"]];
    
    self.superSizeFriesUILabel.text = [[NSUserDefaults standardUserDefaults] boolForKey:@"SUPER_SIZE_FRIES"]? SUPER_SIZED_FRIES: NO_SUPER_SIZED_FRIES;
    self.superSizeFriesUILabel.enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"SUPER_SIZE_FRIES"];
    self.superSizeSoftDrinkUILabel.text = [[NSUserDefaults standardUserDefaults] boolForKey:@"SUPER_SIZE_SOFTDRINK"]? SUPER_SIZED_SOFTDRINK: NO_SUPER_SIZED_SOFTDRINK;
    self.superSizeSoftDrinkUILabel.enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"SUPER_SIZE_SOFTDRINK"];
    self.iceCreamUILabel.text = [[NSUserDefaults standardUserDefaults] boolForKey:@"ADD_ICECREAM"]? ADDED_ICECREAM: NO_ADDED_ICECREAM;
    self.iceCreamUILabel.enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"ADD_ICECREAM"];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"es_CL"]];
    self.amountUILabel.text = [currencyFormatter stringFromNumber:[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"AMOUNT"]]];
    
}


@end
