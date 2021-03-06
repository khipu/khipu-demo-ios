//
//  KHDComboDetailsViewController.m
//  DemoKhipu
//
//  Created by Iván on 12/6/13.
//  Copyright (c) 2013 khipu. All rights reserved.
//

#import "KHDComboDetailsViewController.h"

#define SUPER_SIZE_FRIES    200
#define SUPER_SIZE_SOFTDRINK    200
#define ADD_ICECREAM    400

@interface KHDComboDetailsViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *drinksUIPickerView;
@property (strong, nonatomic) NSArray *drinks;
@property (weak, nonatomic) IBOutlet UISwitch *superSizeFriesUISwitch;
@property (weak, nonatomic) IBOutlet UISwitch *superSizeSoftDrinkUISwitch;
@property (weak, nonatomic) IBOutlet UISwitch *addIceCreamUISwitch;
@property (weak, nonatomic) IBOutlet UILabel *amountUILabel;
@property (nonatomic, retain) NSNumberFormatter *currencyFormatter;

@property (weak, nonatomic) IBOutlet UIView *overlayUIView;
@property (nonatomic) NSInteger amount;
@end

@implementation KHDComboDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"SOFT_DRINK"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SUPER_SIZE_FRIES"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SUPER_SIZE_SOFTDRINK"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ADD_ICECREAM"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.overlayUIView setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.overlayUIView setHidden:YES];
	// Do any additional setup after loading the view.
    self.drinks = [[NSArray alloc] initWithObjects:@"Sprite", @"Fanta", @"Coca-Cola Normal", @"Coca-Cola Zero", @"Coca-Cola Life", @"Coca-Cola Light", nil];
    [[NSUserDefaults standardUserDefaults] setObject:@"Coca-Cola Normal" forKey:@"SOFT_DRINK"];
    self.drinksUIPickerView.dataSource = self;
    self.drinksUIPickerView.delegate = self;
    self.drinksUIPickerView.showsSelectionIndicator = YES;


    [self.drinksUIPickerView selectRow:2 inComponent:0 animated:NO];


	self.currencyFormatter = [[NSNumberFormatter alloc] init];
	[self.currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[self.currencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"es_CL"]];


    self.amount = AMOUNT_DEMO;
    self.amountUILabel.text = [NSString stringWithFormat:@"%ld", (long)self.amount];

	self.amountUILabel.text = [self.currencyFormatter stringFromNumber:[NSNumber numberWithInteger:self.amount]];

    [self.superSizeFriesUISwitch addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
    [self.superSizeSoftDrinkUISwitch addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
    [self.addIceCreamUISwitch addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
}

- (void)changedState:(id)sender
{
    self.amount = AMOUNT_DEMO + (self.superSizeFriesUISwitch.isOn? SUPER_SIZE_FRIES:0) + (self.superSizeSoftDrinkUISwitch.isOn? SUPER_SIZE_SOFTDRINK:0) + (self.addIceCreamUISwitch.isOn? ADD_ICECREAM:0);
	self.amountUILabel.text = [self.currencyFormatter stringFromNumber:[NSNumber numberWithInteger:self.amount]];

	[[NSUserDefaults standardUserDefaults] setBool:self.superSizeFriesUISwitch.isOn forKey:@"SUPER_SIZE_FRIES"];
	[[NSUserDefaults standardUserDefaults] setBool:self.superSizeSoftDrinkUISwitch.isOn forKey:@"SUPER_SIZE_SOFTDRINK"];
	[[NSUserDefaults standardUserDefaults] setBool:self.addIceCreamUISwitch.isOn forKey:@"ADD_ICECREAM"];
	[[NSUserDefaults standardUserDefaults] setInteger:self.amount forKey:@"AMOUNT"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 6;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.textColor = SYSTEM_VERSION_LESS_THAN(@"7.0")? [UIColor blackColor]: [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [label setShadowColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
        label.shadowOffset = CGSizeMake(1, 1);
    }else{
        [label setBackgroundColor:[UIColor clearColor]];
    }

    label.font = [UIFont fontWithName:@"Baskerville-SemiBold" size:25];
    label.text = [self.drinks objectAtIndex:row];
    return label;    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[[NSUserDefaults standardUserDefaults] setObject:[self.drinks objectAtIndex:row] forKey:@"SOFT_DRINK"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)goPayUIButton:(id)sender {
    [UIView animateWithDuration:0.1 animations:^{
        [self.overlayUIView setHidden:NO];
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(createPaymentAndProcess) userInfo:nil repeats:NO];
    }];
}

- (void)processPayment:(NSURL *)myURL {
    if (![[UIApplication sharedApplication] canOpenURL:myURL]) {
        // No está instalado khipu.
        [self.overlayUIView setHidden:YES];
        // Guardamos la URL con la información del pago.
        // Esta información se utiliza cuando nuestra aplicación es invocada por khipu luego de su instalación.
        [[NSUserDefaults standardUserDefaults] setURL:myURL forKey:@"pendingURL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // Le avisamos al usuario que es necesario instalar khipu.
        [[[UIAlertView alloc] initWithTitle:nil message:@"Debes instalar khipu" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [[UIApplication sharedApplication] openURL:myURL];
}

// Esta funcionalidad debe llamar a tu servidor web para crear el pago. No lo hagas dentro de la aplicación móvil, pues hay información privada
// que debes utilizar para crear el pago.
- (void)createPaymentAndProcess {
    
    // Para crear Pagos, no olvides revisar la documentación de nuestra API https://khipu.com/page/api
   
    
    NSString*   receiver_id = [NSString stringWithFormat:@"%d", ID_DEL_COBRADOR];
    // EL SECRET_DEL_COBRADOR NUNCA DEBE QUEDAR EN TU APP. Esta es información privada
    NSString*           secret = SECRET_DEL_COBRADOR;
    NSString*           method = @"POST";
    NSString*           url = @"https://khipu.com/api/2.0/payments";
    NSMutableString*    toSign = [[NSString stringWithFormat:@"%@&%@",[method uppercaseString],[self percentEncode:url]] mutableCopy];
    
    NSString*           amount = [NSString stringWithFormat:@"%ld", (long)self.amount];
    NSString*           subject = SUBJECT_DEMO;
    NSString*           payer_email = EMAIL_DEMO;
    
    NSDictionary<NSString*,NSString*>*  map = @{@"subject"      :subject,
                                                @"amount"       :amount,
                                                @"currency"     :@"CLP",
                                                @"payer_email"  :payer_email,
                                                @"return_url"   : @"khipudemo://return.khipu.com",
                                                @"cancel_url"   : @"khipudemo://failure.khipu.com"};
    
    NSArray *sortedMapKeys =  [[map allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    
    for (NSString* key in sortedMapKeys) {
        
        [toSign appendString:[NSString stringWithFormat:@"&%@=%@",[self percentEncode:key], [self percentEncode:[map objectForKey:key]]]];
    }
    
    NSString*   sign = [self hmacSHA256Secret:secret
                                       toSign:toSign];
    
    NSString*   authorization = [NSString stringWithFormat:@"%@:%@", receiver_id, sign];
    
    NSMutableURLRequest *aNSMutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [aNSMutableURLRequest setHTTPMethod:method];

    NSMutableString*    postData = [NSMutableString new];
    
    for (NSString* key in sortedMapKeys) {
        
        if (postData.length > 0) {
            
            [postData appendString:@"&"];
        }
        [postData appendString:[NSString stringWithFormat:@"%@=%@",[self percentEncode:key], [self percentEncode:[map objectForKey:key]]]];
    }
    
    NSData* postDataBytes = [postData dataUsingEncoding:NSUTF8StringEncoding];
    
    [aNSMutableURLRequest setValue:authorization
                forHTTPHeaderField:@"Authorization"];
    
    [aNSMutableURLRequest setValue:@"application/x-www-form-urlencoded"
                forHTTPHeaderField:@"Content-Type"];
    
    [aNSMutableURLRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[postDataBytes length]]
                forHTTPHeaderField:@"Content-Length"];
    
    [aNSMutableURLRequest setHTTPBody:postDataBytes];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *conn = [NSURLConnection sendSynchronousRequest:aNSMutableURLRequest
                                         returningResponse:&response
                                                     error:&error];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:conn
                                                         options:0
                                                           error:nil];
    
    NSURL *myURL = [NSURL URLWithString:[json valueForKey:@"app_url"]];
    
    [self processPayment:myURL];
}

- (NSString*)hmacSHA256Secret: (NSString*) secret toSign:(NSString*) toSign {
    
    NSData *saltData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *paramData = [toSign dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, saltData.bytes, saltData.length, paramData.bytes, paramData.length, hash.mutableBytes);
    
    NSString *hashNSString = [[[[hash description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];

    return hashNSString;
}

- (NSString*) percentEncode:(NSString*)string {
    
    if (!string) {
        
        return @"";
    }
    
    NSString *result = [[self safeUserURLEncode:string] stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    
    result = [result stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"];
    result = [result stringByReplacingOccurrencesOfString:@"%7E" withString:@"~"];
    
    return result;
}

- (NSString*) safeUserURLEncode:(NSString *) URLString {
    
    return [[NSURL URLWithString:[URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]]] absoluteString];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // Invocamos la AppStore con la URL de khipu.
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cl/app/khipu-terminal-de-pagos/id590942451?mt=8"]];
}

@end
