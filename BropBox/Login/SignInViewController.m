//
//  SignInViewController+.m
//  BropBox
//
//  Created by cetauri on 10/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"
#import "SignUpViewController.h"
#import <baas.io/Baas.h>

@interface SignInViewController (){
    UITableView *_tableView ;
}
@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"로그인";
        
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 200;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    footerView.backgroundColor = [UIColor clearColor];

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(10, 10, 300, 44);
    [loginButton setTitle:@"BropBox에 로그인" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(signInButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    loginButton.enabled = false;
    loginButton.tag = 3;
    [footerView addSubview:loginButton];

    UIButton *signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signUpButton.frame = CGRectMake(10, 50, 300, 44);
    signUpButton.titleLabel.font = [UIFont systemFontOfSize:13.];
    [signUpButton setTitle:@"▶ BropBox 처음 사용함. (계정생성)" forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:signUpButton];

    return footerView;
}

#pragma mark - event

- (void)signUpButtonPressed
{
    SignUpViewController *vc = [[SignUpViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)signInButtonPressed
{
    UITextField *idField = (UITextField *)[self.view viewWithTag:20];
    UITextField *passwdField = (UITextField *)[self.view viewWithTag:21];

    [BaasioUser signInBackground:idField.text
                        password:passwdField.text
                    successBlock:^(void){
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:APP_LOGIN_FINISH_NOTIFICATION object:nil];
                        
                    }
                    failureBlock:^(NSError *error){
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인에 실패하였습니다.\n다시 시도해주세요."
                                                                            message:error.localizedDescription
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        
                    }];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self checkButtonEnable];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self checkButtonEnable];
}

- (void)checkButtonEnable
{
    UITextField *idField = (UITextField *)[self.view viewWithTag:20];
    UITextField *passwdField = (UITextField *)[self.view viewWithTag:21];
    idField.text = [idField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    passwdField.text = [passwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    UIButton *button = (UIButton*)[self.view viewWithTag:3];
    if (![idField.text isEqualToString:@""] && ![passwdField.text isEqualToString:@""]){
        button.enabled = YES;
    } else{
        button.enabled = NO;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *idField = (UITextField *)[self.view viewWithTag:20];
    UITextField *passwdField = (UITextField *)[self.view viewWithTag:21];
    
    idField.text = [idField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    passwdField.text = [passwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    switch (textField.tag - 20){
        case 0:
        {
            [passwdField becomeFirstResponder];
            break;
        }
        case 1:
        {
            if (![idField.text isEqualToString:@""] && ![passwdField.text isEqualToString:@""]){
                [self signInButtonPressed];
            }
            break;
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellName = @"loginCell";

    UITableViewCell *loginCell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (loginCell == nil) {
        loginCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 44)];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1;
        [loginCell addSubview:label];
        
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 200, 44)];
        field.delegate = self;
        
        field.backgroundColor = [UIColor clearColor];
        field.tag = 20 + indexPath.row;
        
        if (indexPath.row == 1){
            field.secureTextEntry = YES;
        }
        
        field.placeholder = @"필수 입력 항목";
        
        [loginCell addSubview:field ];
    }
    
    UILabel *label = (UILabel*)[loginCell viewWithTag:1];
    UITextField *field = (UITextField*)[loginCell viewWithTag:2 + indexPath.row];
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    switch (indexPath.row){
        case 0:
            label.text = @"아이디";
            break;
        case 1:
            label.text = @"암호";
            break;
    }
    
    return loginCell;
}

@end
