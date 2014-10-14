/**
 *
 *  HealthPackageListVc
 *  @author steven
 *  @date Sep 22 2014
 *
 **/

#import "HealthPackageListVc.h"

@implementation HealthPackageListVc
enum {
    kHttpLoadDataTag = 100,
    kHttpSetReservationTag,
    kHttpModifyReservationTag,
};



#pragma mark -
#pragma mark ------------------------------窗体----------------------------------
/*------------------------------------------------------------------------------
 |  窗体
 |
 -----------------------------------------------------------------------------*/
//窗体创建
- (void)onCreate {
    //顶部面板-----------
    [self changeTopTitle:@"套餐列表"];
    [self hideTopRightBtn];
    //内容面板-----------
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentPanel.width, 80)];
    self.ctrlHeader = v;
    //体检中心地址
    UILabel *l = [UILabel labelWithLeft:10 Top:10 Width:self.contentPanel.width - 20 Height:14 FontSize:12];
    [v addSubview:l];
    self.ctrlPeisAddr = l;
    //体检中心电话
    l = [UILabel labelWithLeft:10 Top:l.bottom + 2 Width:self.contentPanel.width - 20 Height:14 FontSize:12];
    [v addSubview:l];
    self.ctrlPeisPhone = l;
    //体检中心传真
    l = [UILabel labelWithLeft:10 Top:l.bottom + 2 Width:self.contentPanel.width - 20 Height:14 FontSize:12];
    [v addSubview:l];
    self.ctrlPeisFax = l;
    //体检中心简介
    l = [UILabel labelWithLeft:10 Top:l.bottom + 2 Width:self.contentPanel.width - 20 Height:14 FontSize:12];
    l.numberOfLines = 0;
    [v addSubview:l];
    self.ctrlPeisIntro = l;
    //分隔线
    UIView *line = [UIView lineWithWidth:self.contentPanel.width];
    [v addSubview:line];
    self.ctrlLine = line;
    
    //CSDatePicker
    CSDatePicker *dp = [[CSDatePicker alloc] initWithTitle:@"设置预约时间"];
    dp.delegate = self;
    dp.top = 40;
    dp.centerX = self.contentPanel.width / 2;
    [self.contentPanel addSubview:dp];
    self.ctrlDatePicker = dp;
    
    //底部面板-----------
    //数据------
    self.arrayOfCellData = [[NSMutableArray alloc] init];
    //其他--------------
}

//解析导航进
- (void)onPraseNavToParams:(NSDictionary *)params {
    //centerId
    self.centerId = [params valueForKey:@"centerId"];
    //fromePage
    NSString *fromePage = [params valueForKey:@"fromePage"];
    if ([fromePage isEqualToString:@"ReservationDetailVc"]) {
        self.modifyReservationTag = YES;
    } else {
        self.modifyReservationTag = NO;
    }
    //peMaster
    self.peMasterId = [params valueForKey:@"peMasterId"];
}

//解析导航返回
- (void)onPraseNavBackParams:(NSDictionary *)params {
}

//窗体将要显示------
- (void)onWillShow {
    [self loadData:kHttpLoadDataTag];
}

//窗体显示
- (void)onShow {
}

//隐藏------
- (void)onWillHide {
}

//导航栏------
- (void)topLeftBtnClicked {
    [self navBack];
}

- (void)topRightBtnClicked {
}



#pragma mark -
#pragma mark --------------------------获取和提交数据-----------------------------
/*------------------------------------------------------------------------------
 |  获取和提交数据
 |
 -----------------------------------------------------------------------------*/
- (void)loadData:(NSInteger)tag {
    if (tag == kHttpLoadDataTag) {
        [self httpGet:[AppUtil healthUrl:@"peiscenter.PeisCenterPRC.getPeisCenterDetail.submit"] tag:tag];
    } else if (tag == kHttpSetReservationTag){
        [self httpGet:[AppUtil healthUrl:@"pemaster.PEMasterPRC.reservation.submit"] tag:tag];
    } else if (tag == kHttpModifyReservationTag){
        [self httpGet:[AppUtil healthUrl:@"pemaster.PEMasterPRC.modifyReservation.submit"] tag:tag];
    }
}

- (void)onHttpRequestSuccessObj:(NSDictionary *)dic tag:(NSInteger)tag {
    if (tag == kHttpLoadDataTag) {
        [self.arrayOfCellData removeAllObjects];
        
        NSString *peisName = [dic valueForKey:@"peisName"];
        if ([ChkUtil isEmptyStr:peisName] == NO) {
            [self changeTopTitle:peisName];
        }
        
        //设置数据
        NSString *addr = kEmptyStr;
        if ([dic valueForKey:@"address"]) {
            addr = [dic valueForKey:@"address"];
        }
        NSString *tel = kEmptyStr;
        if ([dic valueForKey:@"tel"]) {
            tel = [dic valueForKey:@"tel"];
        }
        NSString *fax = kEmptyStr;
        if ([dic valueForKey:@"fax"]) {
            fax = [dic valueForKey:@"fax"];
        }
        NSString *intro = kEmptyStr;
        if ([dic valueForKey:@"introduction"]) {
            intro = [dic valueForKey:@"introduction"];
        }
        //刷新
        [self refreshWithAddr:addr phone:tel fax:fax intro:intro];
        
        NSArray *arr = [dic valueForKey:@"itemPackageList"];
        for (NSDictionary *dic in arr) {
            HealthPackageListCellData *cd = [[HealthPackageListCellData alloc] initWithObj:dic];
            [self.arrayOfCellData addObject:cd];
        }
        
        //刷新
        [self.tableView reloadData];
    } else if (tag == kHttpSetReservationTag) {
        self.ctrlDatePicker.hidden = YES;
        [self showToast:@"预约套餐成功"];
    } else if (tag == kHttpModifyReservationTag) {
        self.ctrlDatePicker.hidden = YES;
        [self showToast:@"修改套餐成功"];
    }
}

//完善参数
- (void)completeQueryParams:(NSInteger)tag {
    if (tag == kHttpLoadDataTag) {
        [self.queryParams setObject:self.centerId forKey:@"peisCenterId"];
    } else if (tag == kHttpSetReservationTag || tag == kHttpModifyReservationTag) {
        HealthPackageListCellData *cd = [self.arrayOfCellData objectAtIndex:self.selectedIndex];
        [self.queryParams setObject:self.centerId forKey:@"peisCenterId"];
        [self.queryParams setObject:cd.packageId forKey:@"itemPackageId"];
        [self.queryParams setObject:[self.ctrlDatePicker getDateStr] forKey:@"reservationDate"];
        if (tag == kHttpSetReservationTag) {
            [self.queryParams setObject:Global.instance.userInfo.userLoginId forKey:@"userLoginId"];
        } else {
            [self.queryParams setObject:self.peMasterId forKey:@"peMasterId"];
        }
    }
}



#pragma mark -
#pragma mark ------------------------------tableView----------------------------------
/*------------------------------------------------------------------------------
 |  tableView
 |
 -----------------------------------------------------------------------------*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfCellData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [HealthPackageListCell CellHeight];
}

- (void) createCell:(UITableViewCell *)cell {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    HealthPackageListCell *cd = [[HealthPackageListCell alloc] initWithVc:self];
    cd.delegate = self;
    cd.tag = 100;
    [cell addSubview:cd];
}

- (void)makeCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    //容错
    NSInteger index = indexPath.row;
    
    if (index >= self.arrayOfCellData.count) {
        return;
    }
    
    HealthPackageListCell *c = (HealthPackageListCell *)[cell viewWithTag:100];
    HealthPackageListCellData *cd = [self.arrayOfCellData objectAtIndex:index];
    
    [c refreshWithItemData:cd index:index];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    //容错
    if (row >= self.arrayOfCellData.count) {
        return;
    }
    
    HealthPackageListCellData *cd = [self.arrayOfCellData objectAtIndex:row];
    [self navTo:@"HealthPackageDetailVc" params:[NSDictionary dictionaryWithObjectsAndKeys:cd.packageId, @"packageId", self.centerId, @"centerId", nil]];
}



#pragma mark -
#pragma mark --------------------HealthPackageListCellDelegate------------------
/*------------------------------------------------------------------------------
 |  HealthPackageListCellDelegate
 |
 -----------------------------------------------------------------------------*/
- (void)onHealthPackageListCellClicked:(NSInteger)idx {
    //容错
    if (idx >= self.arrayOfCellData.count) {
        return;
    }
    
    EN_LOGIN_STATE_T state = Global.instance.userInfo.userState;
    if (state == LOGIN_STATE_NONE) {
        [self navTo:@"SignInVc"];
    } else if (state == LOGIN_STATE_NORMAL) {
        [self navTo:@"FillUserInfoVc"];
    } else {
        //index
        self.selectedIndex = idx;
        [self.ctrlDatePicker show];
    }
}



#pragma mark -
#pragma mark --------------------CSDatePickerDelegate---------------------------
/*------------------------------------------------------------------------------
 |  CSDatePickerDelegate
 |
 -----------------------------------------------------------------------------*/
- (void)onCSDatePickerDelegate:(CSDatePicker *)picker {
    //请求
    if (self.modifyReservationTag) {
        [self loadData:kHttpModifyReservationTag];
    } else {
        [self loadData:kHttpSetReservationTag];
    }
}



#pragma mark -
#pragma mark -------------------------------其他---------------------------------
/*------------------------------------------------------------------------------
 |  其他
 |
 -----------------------------------------------------------------------------*/
- (void)refreshWithAddr:(NSString *)addr phone:(NSString *)phone fax:(NSString *)fax intro:(NSString *)intro {
    self.ctrlPeisAddr.text = [@"地址: " stringByAppendingString:addr];
    self.ctrlPeisPhone.text = [@"电话: " stringByAppendingString:phone];
    self.ctrlPeisFax.text = [@"传真: " stringByAppendingString:fax];
    CGSize size = [self.ctrlPeisIntro setDynamicWithStr:[@"简介: " stringByAppendingString:intro]  fontSize:12];
    self.ctrlHeader.height = self.ctrlPeisIntro.top + size.height + 10;
    self.ctrlLine.bottom = self.ctrlHeader.height;
    self.ctrlHeader.height = self.ctrlLine.bottom;
    self.tableView.tableHeaderView = self.ctrlHeader;
}



@end