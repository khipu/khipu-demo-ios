//
//  KHDLandingViewController.m
//  DemoKhipu
//
//  Created by Iván on 12/9/13.
//  Copyright (c) 2013 khipu. All rights reserved.
//

#import "KHDLandingViewController.h"


@interface KHDLandingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *orderUILabel;

@end

@implementation KHDLandingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self validatePayment];
}

- (void)showVerified
{
    [self performSegueWithIdentifier:@"verified" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)validatePayment
{
    // Debes realizar la verificación del estado del pago contra tu servidor y luego
    // determinar el camino a seguir
    
    
    // En esta demo, mostraremos una pantalla de éxito en 3 segs
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(showVerified)
                                   userInfo:nil
                                    repeats:NO];
}

@end
