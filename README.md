![khipu icon](https://khipu.com//assets/logo/logo-purple-7e3f1da1a4ce55a5442af1cb7fd48d5a.png)

# demo-ios

## Resumen

Aplicación de demo para integrar khipu en aplicaciones móviles


####  Pasos para pagar invocando khipu

1. **MiApp** genera el cobro.[^1]
2. **MiApp** invoca a la aplicación móvil **khipu** con la URL del cobro
3. La aplicación móvil **khipu** procesa el cobro 
4. La aplicación móvil **khipu**, al finalizar el cobro, invoca **MiApp** con el resultado del proceso.

[^1]: Para generar el cobro, tu aplicación móvil debe comunicarse con tu aplicación de servidor. Nunca lo hagas dentro de la misma aplicación móvil, pues hay información privada necesaria para generar el cobro.


## En detalle


#### Generación del cobro
*Esta aplicación de DEMO contiene el código de generación de cobro para simplificar el proceso de demostración, pero no debe ser tomado como la norma a seguir. No debes distribuir la ["Llave del cobrador"](https://khipu.com/page/api#llave-del-cobrador) en tu código, pues podrían utilizarla para generar cobros asociados a esa cuenta de cobros.*

Para generar el cobro debes utilizar tu propio servidor web, **nunca desde tu aplicación móvil**. Para ello tienes a tu disposición nuestra [API](https://khipu.com/page/api) y más específicamente el apartado [Crear URL para un pago](https://khipu.com/page/api#crear-url).

#### Invocar aplicación móvil khipu
Para invocar la aplicación móvil **khipu**, el código de ejemplo se encuentra en **KHDComboDetailsViewController.m**. 

```
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

```

#### Resultado procesamiento del cobro
Una vez que la aplicación móvil **khipu** ha terminado de procesar tu cobro, invocará tu aplicación, y para ello debes implementar, en tu AppDelegate la función:

```
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
```
Tal como puedes ver en  **KHDAppDelegate.m**:

```
if ([url.scheme isEqualToString:@"khipuinstalled"]) {
        // khipu no estaba instalada al momento de ser requerido. Al terminar su instalación revisa si existe alguna aplicación que haya registrado el esquema khipuinstalled
        
        // Recuperamos la URL del cobro que aún no se ha podido procesar
        NSURL *myURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"pendingURL"];
        if (!myURL) {
            // En caso que la url ya no exista, respondemos que nuestra aplicación no es la que va a responder a esta invocación
            return NO;
        }else{
            // dado que tenemos la URL del cobro pendiente, realizamos nuevamente la llamada, y esta vez será capturada por khipu
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pendingURL"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[UIApplication sharedApplication] openURL:myURL];
        }
        return YES;
    }else if ([url.scheme isEqualToString:@"khipudemo"]) {
        // khipu nos ha invocado, con el resultado del cobro
        [(UINavigationController *)self.window.rootViewController popToRootViewControllerAnimated:NO];
        NSString *message = @"";

        if ([url.description containsString:@"failure"]){
            // falla al procesar el cobro
            message = @"El servicio de pago informó que no se ha realizado el pago. Por favor intenta más tarde";
            [[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }else{
            // el cobro ha sido realizado.
            KHDLandingViewController *aKHDLandingViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"KHDLandingViewController"];
            [(UINavigationController *)self.window.rootViewController pushViewController:aKHDLandingViewController animated:NO];
        }
        return YES;
    }
```

La función implementada, revisa el parámetro **url**, buscando dos posibles opciones:

1. La url usa el esquema **khipuinstalled**, que es utilizado por la aplicación móvil de khipu al momento que ésta se inicia después de haber sido instalada.
2. La url usa el esquema registrado por tu aplicación (en este caso **khipudemo**).



