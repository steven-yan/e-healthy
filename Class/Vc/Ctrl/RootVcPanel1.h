/**
 *
 *@author steven.yan
 *
 */
@protocol RootVcPanel1Delegate <NSObject>
@optional
@end

#import "BaseVC.h"
#import "SearchPanel.h"
#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"

@interface RootVcPanel1 : UIView<TopPanelDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate>

//代理
@property (weak) NSObject<RootVcPanel1Delegate> *delegate;
//页面
@property (weak) BaseVC *nrVc;

//searchPanel
@property (nonatomic, strong) SearchPanel *ctrlSearchPanel;
//map
@property (nonatomic, strong) MKMapView *ctrlMapView;

//core
@property (nonatomic, strong) CLLocationManager *manager;

//init
- (id)initWithVc:(BaseVC *)vc;



@end
