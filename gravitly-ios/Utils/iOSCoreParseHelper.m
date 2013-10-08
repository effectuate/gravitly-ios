//
//  iOSCore.m
//  Cardinal-Iph
//
//  Created by Rai Orofino on 3/26/13.
//
//

#import "iOSCoreParseHelper.h"

@implementation iOSCoreParseHelper


+ (void)findAll:(NSString*)className :(ResultBlock)handler{
    
    NSError *error;
    @try {
        NSArray *array;
        PFQuery *query = [PFQuery queryWithClassName:className];
        array = [query findObjects];
        handler(array, error);
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
}

+ (void)findAllInBackground:(NSString*)className :(ResultBlock)handler{
    @try {
        PFQuery *query = [PFQuery queryWithClassName:className];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
           handler(objects, error);
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }


}
+ (void)findInBackground:(NSString*)className whereKey:(NSString*)whereKey equalTo:(NSString *)equalTo :(ResultBlock)handler{
    @try {
        
        PFQuery *query = [PFQuery queryWithClassName:className];
        [query whereKey:whereKey equalTo:equalTo];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            handler(objects, error);
        }];
       
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }

}

+ (void)getFirstObjectInBackground:(NSString*)className whereKey:(NSString*)whereKey equalTo:(NSString *)equalTo :(ObjectResultBlock)handler{
    @try {
        
        PFQuery *query = [PFQuery queryWithClassName:className];
        [query whereKey:whereKey equalTo:equalTo];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            handler(object, error);
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }

}

+ (void)find:(NSString*)className whereKey:(NSString*)whereKey equalTo:(NSString *)equalTo :(ResultBlock)handler{

    NSError *error;
    @try {
        NSArray *array;
        PFQuery *query = [PFQuery queryWithClassName:className];
        [query whereKey:whereKey equalTo:equalTo];
        array = [query findObjects];
        handler(array, error);
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }

}
+ (void)getContainedObject:(NSString *)className whereKey:(NSString *)whereKey containedIn:(NSArray *)containedIn :(ResultBlock)handler{

    NSError *error;
    @try {
        NSArray *array;
        PFQuery *query = [PFQuery queryWithClassName:className];
        [query whereKey:whereKey containedIn:containedIn];
        array = [query findObjects];
        handler(array, error);
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    
    

}
+ (void)getPointerSubClass:(NSString *)className subClass:(NSString *)subClass whereKey:(NSString *)whereKey objectId:(NSString *)objectId :(ResultBlock)handler{
    
    NSError *error;
    @try {
        NSArray *array;
        PFQuery *query = [PFQuery queryWithClassName:className];
        [query whereKey:whereKey equalTo:[PFObject objectWithoutDataWithClassName:subClass objectId:objectId]];
        array = [query findObjects];
        handler(array, error);
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    


}
+ (void)deleteObject:(NSString *)className objectId:(NSString *)objectId :(void(^)(int *result))handler{

    @try {
        PFQuery *query = [PFQuery queryWithClassName:className];
        PFObject *object = [query getObjectWithId:objectId];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                handler(200);
            }else{
                handler(400);
            }
            
            if (error) {
                handler(500);
            }
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        handler(500);
    }

}

+(void)launchParseLogin:(UIViewController *)uiViewController{
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:(id)uiViewController];
        [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"email", /*@"read_friendlists",*/ nil]];
        [logInViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton];
        [logInViewController.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueflame.png"]]];
        [logInViewController.logInView.usernameField setPlaceholder:@"Email Address"];
        [logInViewController.logInView.dismissButton setHidden:YES];
        // Customize the Sign Up View Controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:(id)uiViewController];
        [signUpViewController setFields:PFSignUpFieldsDefault];
        [logInViewController setSignUpController:signUpViewController];
        
        // Present Log In View Controller
        [uiViewController presentViewController:logInViewController animated:YES completion:NULL];
    
}

+ (void)isAuthenticated:(UIViewController *)viewController {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        LogInViewController *loginView = [viewController.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
        [viewController.navigationController presentViewController:loginView animated:YES completion:^{
            NSLog(@"User logout");
        }];
    }
}

@end
