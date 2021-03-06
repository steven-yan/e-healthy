/**
 *
 *  ModifyPwdVc
 *  @author steven
 *  @date Otc 18 2014
 *
 **/

#import "ModifyPwdVc.h"

@implementation ModifyPwdVc
static int kLeftMargin = 15;



#pragma mark -
#pragma mark ------------------------------窗体----------------------------------
/*------------------------------------------------------------------------------
 |  窗体
 |
 -----------------------------------------------------------------------------*/
//窗体创建
- (void)onCreate {
    //顶部面板-----------
    //标题栏
    [self changeTopTitle:@"修改密码"];
    //隐藏左侧按键
    [self hideTopRightBtn];
    
    //内容面板-----------
    //用户名----------
    //tf
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(kLeftMargin, 15, self.contentPanel.width - kLeftMargin, 20)];
    tf.delegate = self;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.returnKeyType = UIReturnKeyNext;
    tf.font = [UIFont systemFontOfSize:18];
    tf.secureTextEntry = YES;
    tf.placeholder = @"旧密码";
    [tf setValue:[UIColor colorWithHexStr:@"#b3b3b3"] forKeyPath:@"_placeholderLabel.textColor"];
    [tf setValue:[UIFont systemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
    [self.contentPanel addSubview:tf];
    self.ctrlTfOldPwd = tf;
    //分隔线
    UIView *line = [UIView lineWithWidth:tf.width];
    line.left = kLeftMargin;
    line.top = tf.bottom + 10;
    [self.contentPanel addSubview:line];
    
    //密码----------
    //tf
    tf = [[UITextField alloc] initWithFrame:CGRectMake(kLeftMargin, line.bottom + 10, tf.width, 20)];
    tf.delegate = self;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
	tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tf.returnKeyType = UIReturnKeyNext;
    tf.font = [UIFont systemFontOfSize:18];
    tf.secureTextEntry = YES;
    tf.placeholder = @"密码";
    [tf setValue:[UIColor colorWithHexStr:@"#b3b3b3"] forKeyPath:@"_placeholderLabel.textColor"];
    [tf setValue:[UIFont systemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
    [self.contentPanel addSubview:tf];
    self.ctrlTfPwd = tf;
    //分隔线
    line = [UIView lineWithWidth:tf.width];
    line.left = kLeftMargin;
    line.top = tf.bottom + 10;
    [self.contentPanel addSubview:line];
    
    //确认密码----------
    //tf
    tf = [[UITextField alloc] initWithFrame:CGRectMake(kLeftMargin, line.bottom + 10, tf.width, 20)];
    tf.delegate = self;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.returnKeyType = UIReturnKeySend;
    tf.font = [UIFont systemFontOfSize:18];
    tf.secureTextEntry = YES;
    tf.placeholder = @"确认密码";
    [tf setValue:[UIColor colorWithHexStr:@"#b3b3b3"] forKeyPath:@"_placeholderLabel.textColor"];
    [tf setValue:[UIFont systemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
    [self.contentPanel addSubview:tf];
    self.ctrlTfCmfPwd = tf;
    //分隔线
    line = [UIView lineWithWidth:tf.width];
    line.left = kLeftMargin;
    line.top = tf.bottom + 10;
    [self.contentPanel addSubview:line];

    //重置密码
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, line.bottom + 25, self.contentPanel.width - 20, 40)];
    [btn setTitle:@"修改密码" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(modifyPwdBtnClicked:)];
    btn.layer.cornerRadius = 6;
    btn.backgroundColor = self.topPanel.backgroundColor;
    [self.contentPanel addSubview:btn];
    
    //底部面板-----------
    //其他--------------
}

//解析导航进
- (void)onPraseNavToParams:(NSDictionary *)params {
}

//解析导航返回
- (void)onPraseNavBackParams:(NSDictionary *)params {
}

//窗体将要显示
- (void)onWillShow {
}

//窗体显示
- (void)onShow {
    [self.ctrlTfOldPwd becomeFirstResponder];
}

//导航栏------
- (void)topLeftBtnClicked {
    [self navBack];
}

- (void)topRightBtnClicked {
}

- (void)onWillHide {
}



#pragma mark -
#pragma mark --------------------------获取和提交数据-----------------------------
/*------------------------------------------------------------------------------
 |  获取和提交数据
 |
 -----------------------------------------------------------------------------*/
- (void)loadData {
    [self httpGet:[AppUtil fillUrl:@"userlogin.UserLoginPRC.modifyPwd.submit"]];
}

- (void)onHttpRequestSuccessObj:(NSDictionary *)dic {
    Global.instance.userInfo.userPwd = self.ctrlTfCmfPwd.text;
    [Global.instance.userInfo save];
    
    [self showToast:@"密码修改成功"];
    [self navBack];
}

//完善参数
- (void)completeQueryParams {
    //TODO: 服务的有bug (服务的不验证密码)
    [self.queryParams setValue:Global.instance.userInfo.userLoginId forKey:@"userLoginId"];
    [self.queryParams setValue:self.ctrlTfCmfPwd.text forKey:@"newPwd"];
}



#pragma mark -
#pragma mark ------textField delegate------
/*------------------------------------------------------------------------------
 |  textField
 |
 -----------------------------------------------------------------------------*/
- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.ctrlTfOldPwd) {
        [self.ctrlTfPwd becomeFirstResponder];
    } else if (textField == self.ctrlTfPwd){
        [self.ctrlTfCmfPwd becomeFirstResponder];
    } else {
    
    }
    
    return YES;
}



#pragma mark -
#pragma mark -------------------------------其他---------------------------------
/*------------------------------------------------------------------------------
 |  其他
 |
 -----------------------------------------------------------------------------*/
- (void)modifyPwdBtnClicked:(UIButton *) btn {
    //reset
	[self reset];
    if ([self chkUsrInfo] == YES) {
        [self loadData];
    }
}

- (void)reset {
    //隐藏面板
    [self hideKeyBoard];
}

- (BOOL)chkUsrInfo {
    NSString *oldPwd = self.ctrlTfOldPwd.text;
    NSString *pwd = self.ctrlTfPwd.text;
    NSString *cmfPwd = self.ctrlTfPwd.text;
    
    [self hideKeyBoard];
    
    //检测旧密码------
    if ([ChkUtil isEmptyStr:oldPwd]) {
        [self showToast:@"旧密码不能为空"];
        return NO;
    }
    if ([oldPwd isEqualToString:Global.instance.userInfo.userPwd] == NO) {
        [self showToast:@"旧密码错误"];
        return NO;
    }
    
    //检测密码-------
    if ([ChkUtil isEmptyStr:pwd]) {
        [self showToast:@"密码不能为空"];
        return NO;
    }
    if (pwd.length < 6) {
        [self showToast:@"密码长度不能小于六位"];
        return NO;
    }
    if ([ChkUtil isEmptyStr:cmfPwd]) {
        [self showToast:@"确认密码不能为空"];
        return NO;
    }
    
    if ([pwd isEqualToString:cmfPwd] == NO) {
        [self showToast:@"两次密码不一致"];
        return NO;
    }
    
    return YES;
}

- (void)resetPwdBtnClicked:(UIButton *)btn {
    [self navTo:@""];
}

//hide
- (void)hideKeyBoard {
    //旧密码
    [self.ctrlTfOldPwd resignFirstResponder];
    //密码
    [self.ctrlTfPwd resignFirstResponder];
    [self.ctrlTfCmfPwd resignFirstResponder];
}



@end
