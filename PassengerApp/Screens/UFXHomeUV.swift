//
//  UFXHomeUV.swift
//  PassengerApp
//
//  Created by ADMIN on 14/07/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import MXParallaxHeader
import CoreLocation
import SDWebImage

class UFXHomeUV: UIViewController, OnLocationUpdateDelegate, AddressFoundDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, MyLabelClickDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rduView: UIView!
    @IBOutlet weak var imgSlideShow: ImageSlideshow!
    @IBOutlet weak var imgSlideShowHeight: NSLayoutConstraint!
    @IBOutlet weak var selectServiceLbl: MyLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    //    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var noServiceAvailLbl: MyLabel!
    @IBOutlet weak var ufxDataVerticalStackView: UIStackView!
    @IBOutlet weak var ufxSubDataStackView: UIStackView!
    
    @IBOutlet weak var rduTopBarHeaderView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileLbl: MyLabel!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var walletImgView: UIImageView!
    @IBOutlet weak var walletLbl: MyLabel!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var historyImgView: UIImageView!
    @IBOutlet weak var historyLbl: MyLabel!
    @IBOutlet weak var activeJobView: UIView!
    @IBOutlet weak var activeJobImgView: UIImageView!
    @IBOutlet weak var activeJobLbl: MyLabel!
    
    @IBOutlet weak var rduScrollView: UIScrollView!
    @IBOutlet weak var rduContentView: UIView!
    @IBOutlet weak var rduCollectionView: UICollectionView!
    @IBOutlet weak var rduTableView: UITableView!
    @IBOutlet weak var rduCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var rduContentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var rduSeperatorView: UIView!
    
    var getAddressFrmLocation:GetAddressFromLocation!
    
    var bannersItemList = [SDWebImageSource]()
    var cntView:UIView!
    
    var navItem:UINavigationItem!
    let generalFunc = GeneralFunctions()
    
    var loaderView:UIView!
    
    var parentCategoryItems = [NSDictionary]()
    var subCategoryItems = [NSDictionary]()
    
    var currentItems = [NSDictionary]()
    
    var currentMode = "PARENT_MODE"
    
    var selectedLatitude = ""
    var selectedLongitude = ""
    var selectedAddress = ""
    
    var userProfileJson:NSDictionary!
    
    var getLocation:GetLocation!
    
    var enterLocLbl:MyLabel!
    var locationDialog:OpenEnableLocationView!
    
    var currentLocation:CLLocation!
    var menuImage = UIImageView()
    
    var isSafeAreaSet = false
    
    var isFronMainScreen = false
    var defaultLocation:CLLocation!
    
    var isScreenKilled = false
    
    var isLoadParentMenu = false
    
    var listOfParentGridCategories = [NSDictionary]()
    var listOfParentListCategories = [NSDictionary]()
    var listOfParentAllCategories = [NSDictionary]()
    
    var bottomSheetCnt:BottomsheetController!
    var btnSheetCollectionView:UICollectionView!
    
    var cancelBtnSheetLbl:MyLabel!
    
    var serviceId = "1"
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
//        self.setCustomNavBarColor(isCustom: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.appInBackground), name: NSNotification.Name(rawValue: Utils.appBGNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appInForground), name: NSNotification.Name(rawValue: Utils.appFGNotificationKey), object: nil)
        self.imgSlideShow.frame.origin.y = 0
        checkLocationEnabled()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Utils.appBGNotificationKey), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Utils.appFGNotificationKey), object: nil)
        
//        self.setCustomNavBarColor(isCustom: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
       
    }
    
    func setCustomNavBarColor(isCustom:Bool){
        if(self.userProfileJson != nil && self.userProfileJson.get("APP_TYPE").uppercased() == Utils.cabGeneralType_Ride_Delivery_UberX.uppercased()){
            //            Configurations.setAppColorNavBar(bgColor: UIColor.UCAColor.AppThemeColor_1, txtColor: UIColor.UCAColor.AppThemeTxtColor_1)
            
            if(isCustom && self.currentMode == "PARENT_MODE"){
                navigationController?.navigationBar.barTintColor = UIColor.UCAColor.AppThemeColor_1
            }else{
                navigationController?.navigationBar.barTintColor = UIColor.UCAColor.AppThemeColor
            }
        }
    }
    
    
    override func addBackBarBtn() {
        if(isLoadParentMenu){
            isLoadParentMenu = false
            super.addBackBarBtn()
            return
        }
        
        if(Configurations.isRTLMode()){
            self.navigationDrawerController?.isRightPanGestureEnabled = false
        }else{
            self.navigationDrawerController?.isLeftPanGestureEnabled = false
        }
        
        var backImg = UIImage(named: "ic_nav_bar_back")!
        if(Configurations.isRTLMode()){
            backImg = backImg.imageRotatedByDegrees(oldImage: backImg, deg: 180)
        }
    
    }
    
    override func closeCurrentScreen() {
        SDImageCache.shared.clearMemory()
        
        isScreenKilled = true
        
        if(getAddressFrmLocation != nil){
            getAddressFrmLocation.uv = nil
            getAddressFrmLocation.addressFoundDelegate = nil
            getAddressFrmLocation = nil
        }
        
        if(self.getLocation != nil){
            self.getLocation.locationUpdateDelegate = nil
            self.getLocation.uv = nil
            self.getLocation = nil
        }
        
        
        
        for subview in self.ufxDataVerticalStackView.subviews {
            subview.removeFromSuperview()
        }
        self.ufxDataVerticalStackView.removeFromSuperview()
        
        super.closeCurrentScreen()
    }
    
    func openProfile(){
        if(self.userProfileJson.get("eReviewModeLogin").uppercased() == "YES"){
            self.generalFunc.setAlertMessage(uv: self, title: "", content: "Please login/signup to proceed.", positiveBtn: "Ok", nagativeBtn: "") { (btn_id) in
                
                GeneralFunctions.logOutUser()
                
                GeneralFunctions.postNotificationSignal(key: Utils.releaseAllTaskObserverKey, obj: self)
                
                GeneralFunctions.restartApp(window: Application.window!)
            }
            return
        }
        
        profileView.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 3.0, options: .allowUserInteraction, animations: {
            self.profileView.transform = .identity
        }) { (_) in
            let manageProfileUv = GeneralFunctions.instantiateViewController(pageName: "ManageProfileUV") as! ManageProfileUV
            (self.navigationDrawerController?.rootViewController as! UINavigationController).pushViewController(manageProfileUv, animated: true)
        }
        
    }
    
    func openWallet(){
        if(self.userProfileJson.get("eReviewModeLogin").uppercased() == "YES"){
            self.generalFunc.setAlertMessage(uv: self, title: "", content: "Please login/signup to proceed.", positiveBtn: "Ok", nagativeBtn: "") { (btn_id) in
                
                GeneralFunctions.logOutUser()
                
                GeneralFunctions.postNotificationSignal(key: Utils.releaseAllTaskObserverKey, obj: self)
                
                GeneralFunctions.restartApp(window: Application.window!)
            }
            return
        }
        
        walletView.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 3.0, options: .allowUserInteraction, animations: {
            self.walletView.transform = .identity
        }) { (_) in
            let manageWalletUV = GeneralFunctions.instantiateViewController(pageName: "ManageWalletUV") as! ManageWalletUV
            (self.navigationDrawerController?.rootViewController as! UINavigationController).pushViewController(manageWalletUV, animated: true)
        }
        
    }
    
    func openHistory(){
        if(self.userProfileJson.get("eReviewModeLogin").uppercased() == "YES"){
            self.generalFunc.setAlertMessage(uv: self, title: "", content: "Please login/signup to proceed.", positiveBtn: "Ok", nagativeBtn: "") { (btn_id) in
                
                GeneralFunctions.logOutUser()
                
                GeneralFunctions.postNotificationSignal(key: Utils.releaseAllTaskObserverKey, obj: self)
                
                GeneralFunctions.restartApp(window: Application.window!)
            }
            return
        }
        
        historyView.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 3.0, options: .allowUserInteraction, animations: {
            self.historyView.transform = .identity
        }) { (_) in
            let rideHistoryUv = GeneralFunctions.instantiateViewController(pageName: "RideHistoryUV") as! RideHistoryUV
            let myBookingsUv = GeneralFunctions.instantiateViewController(pageName: "RideHistoryUV") as! RideHistoryUV
            rideHistoryUv.HISTORY_TYPE = "PAST"
            rideHistoryUv.pageTabBarItem.title = self.generalFunc.getLanguageLabel(origValue: "PAST", key: "LBL_PAST").uppercased()
            
            myBookingsUv.pageTabBarItem.title = self.generalFunc.getLanguageLabel(origValue: "UPCOMING", key: "LBL_UPCOMING").uppercased()
            myBookingsUv.HISTORY_TYPE = "LATER"
            
            if(self.userProfileJson.get("RIDE_LATER_BOOKING_ENABLED").uppercased() == "YES"){
                let rideHistoryTabUv = RideHistoryTabUV(viewControllers: [rideHistoryUv, myBookingsUv], selectedIndex: 0)
                (self.navigationDrawerController?.rootViewController as! UINavigationController).pushViewController(rideHistoryTabUv, animated: true)
            }else{
                rideHistoryUv.isDirectPush = true
                (self.navigationDrawerController?.rootViewController as! UINavigationController).pushViewController(rideHistoryUv, animated: true)
            }
        }
        
        
    }
    
    func openActiveJobs(){
        if(self.userProfileJson.get("eReviewModeLogin").uppercased() == "YES"){
            self.generalFunc.setAlertMessage(uv: self, title: "", content: "Please login/signup to proceed.", positiveBtn: "Ok", nagativeBtn: "") { (btn_id) in
                
                GeneralFunctions.logOutUser()
                
                GeneralFunctions.postNotificationSignal(key: Utils.releaseAllTaskObserverKey, obj: self)
                
                GeneralFunctions.restartApp(window: Application.window!)
            }
            return
        }
        
        activeJobView.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 3.0, options: .allowUserInteraction, animations: {
            self.activeJobView.transform = .identity
        }) { (_) in
           
        }
    }
    
    func addMenu(){
        if(isFronMainScreen){
            isLoadParentMenu = true
            self.addBackBarBtn()
        }else{
            let leftButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_menu_all_nav")!, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.openMenu))
            self.navItem.leftBarButtonItem = leftButton
        }
    }
    
    @objc func openMenu(){
        if(Configurations.isRTLMode()){
            self.navigationDrawerController?.isRightPanGestureEnabled = true
            self.navigationDrawerController?.toggleRightView()
            
        }else{
            self.navigationDrawerController?.isLeftPanGestureEnabled = true
            self.navigationDrawerController?.toggleLeftView()
        }
    }
    
    
    @objc func appInBackground(){
    }
    
    @objc func appInForground(){
        checkLocationEnabled()
    }
    
    func addTitleView(){
        
        
    }
    
    func checkLocationEnabled(){
        if(locationDialog != nil){
            locationDialog.closeView()
            locationDialog = nil
        }
        
        if((GeneralFunctions.hasLocationEnabled() == false && self.currentLocation == nil) || InternetConnection.isConnectedToNetwork() == false)
        {
            
            locationDialog = OpenEnableLocationView(uv: self, containerView: self.cntView, menuImgView: UIImageView())
            locationDialog.currentInst = locationDialog
            locationDialog.setViewHandler(handler: { (latitude, longitude, address, isMenuOpen) in
                //                self.currentLocation = CLLocation(latitude: latitude, longitude: longitude)
                //                self.setTripLocation(selectedAddress: address, selectedLocation: CLLocation(latitude: latitude, longitude: longitude))
                
                if(isMenuOpen){
                    self.openMenu()
                }else{
                    self.locationDialog.closeView()
                    self.locationDialog = nil
                    self.onLocationUpdate(location: CLLocation(latitude: latitude, longitude: longitude))
                }
            })
            
            locationDialog.show()
            
            return
        }
    }
    
    func setData(){
        if(self.selectServiceLbl != nil){
            self.selectServiceLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_SERVICE_TXT")
        }
        
        
        ConfigPubNub.getInstance().buildPubNub()
        
    }
    
    func titleViewTapped(){
        openPlaceFinder()
    }
    
    func loadBanners(){
        if(self.userProfileJson.get("APP_TYPE").uppercased() == Utils.cabGeneralType_Ride_Delivery_UberX.uppercased()){
            return
        }
        
        let parameters = ["type":"getBanners","iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    let msgArr = dataDict.getArrObj(Utils.message_str)
                    
                    for i in 0..<msgArr.count{
                        let tempItem = msgArr[i] as! NSDictionary
                        let vImage = Utils.getResizeImgURL(imgUrl: tempItem.get("vImage"), width: Utils.getValueInPixel(value: Utils.getWidthOfBanner(widthOffset: 0)), height: Utils.getValueInPixel(value: Utils.getHeightOfBanner(widthOffset: 0, ratio: "16:9")))
                        self.bannersItemList += [SDWebImageSource(url: NSURL(string: vImage.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)! as URL, placeholder: nil)]
                    }
                    
                    self.imgSlideShow.contentScaleMode = .scaleToFill
                    self.imgSlideShow.setImageInputs(self.bannersItemList)
                    
                    let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.sliderImgTapped))
                    self.imgSlideShow.addGestureRecognizer(recognizer)
                    
                }else{
                    //                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                //                self.generalFunc.setError(uv: self)
            }
            
        })
    }
    
    @objc func sliderImgTapped(){
        //        imgSlideShow.presentFullScreenController(from: self)
    }
 
    
    func itemTapped(sender:UITapGestureRecognizer){
        if(sender.view!.tag >=  self.currentItems.count){
            return
        }
        if(loaderView != nil && loaderView.isHidden == false){
            return
        }
      
        if(userProfileJson.get("UBERX_PARENT_CAT_ID") == "0" && self.currentMode == "PARENT_MODE"){
            self.selectServiceLbl.text = self.currentItems[sender.view!.tag].get("vCategory")
            
            UIView.animate(withDuration: 0.1, animations: {
                sender.view!.transform = .init(scaleX: 0.85, y: 0.85)
            }) { (_) in
                
                UIView.animate(withDuration: 0.1, animations: {
                    sender.view!.transform = .identity
                }) { (_) in
                   
                }
//                self.loadServiceCategory(parentCategoryId: self.currentItems[sender.view!.tag].get("iVehicleCategoryId"))
            }
            
        }else if(self.currentMode == "SUB_MODE" || userProfileJson.get("UBERX_PARENT_CAT_ID") != "0"){
            
            if(self.selectedLatitude == "" || self.selectedLongitude == ""){
                Utils.showSnakeBar(msg: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SET_LOCATION"), uv: self)
                return
            }
            
        
            return
        }
    }
    
  
 
    func openPlaceFinder(){
        let launchPlaceFinder = LaunchPlaceFinder(viewControllerUV: self)
        launchPlaceFinder.currInst = launchPlaceFinder
        
        if(currentLocation != nil){
            launchPlaceFinder.setBiasLocation(sourceLocationPlaceLatitude: currentLocation.coordinate.latitude, sourceLocationPlaceLongitude: currentLocation.coordinate.longitude)
        }
        
        launchPlaceFinder.initializeFinder { (address, latitude, longitude) in
            
            if(self.currentLocation != nil){
                self.selectedLatitude = "\(latitude)"
                self.selectedLongitude = "\(longitude)"
                self.selectedAddress = address
                self.enterLocLbl.text = address
                
            }else{
                self.onLocationUpdate(location: CLLocation(latitude: latitude, longitude: longitude))
            }
        }
    }
    
    
    func onLocationUpdate(location: CLLocation) {
        
        self.currentLocation = location
        
        if(getLocation != nil){
            getLocation.releaseLocationTask()
        }
        
       
        if(getAddressFrmLocation == nil){
            getAddressFrmLocation = GetAddressFromLocation(uv: self, addressFoundDelegate: self)
            getAddressFrmLocation.setLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            getAddressFrmLocation.setPickUpMode(isPickUpMode: true)
            getAddressFrmLocation.executeProcess(isOpenLoader: false, isAlertShow:false)
        }
    }
    
    func onAddressFound(address: String, location: CLLocation, isPickUpMode: Bool, dataResult: String) {
        self.selectedLatitude = "\(location.coordinate.latitude)"
        self.selectedLongitude = "\(location.coordinate.longitude)"
        self.selectedAddress = address
        if(self.enterLocLbl != nil){
            self.enterLocLbl.text = address
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfParentListCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.btnSheetCollectionView){
            return self.listOfParentAllCategories.count
        }else{
            return self.listOfParentGridCategories.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = Utils.getHeightOfBanner(widthOffset: 10, ratio: "16:9")
        return height + 10
    }
    
    func getWidthOfItem() -> CGFloat{
        let totalItemInRow = Int(self.view.frame.width / 75) < 3 ? 3 : Int(self.view.frame.width / 75)
        return (Application.screenSize.width / CGFloat(totalItemInRow)) - 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: getWidthOfItem(), height: 110)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UFXJekIconTVC", for: indexPath) as! UFXJekIconTVC
        
        let item = self.listOfParentListCategories[indexPath.row]
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UFXJekIconCVC", for: indexPath) as! UFXJekIconCVC
        
        
        return cell
    }
    
  
    
    func goToDeliverAllScreen(screenType:String){
       
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = tableView.cellForRow(at: indexPath) as? UFXJekIconTVC {
                cell.transform = .init(scaleX: 0.95, y: 0.95)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = tableView.cellForRow(at: indexPath) as? UFXJekIconTVC {
                cell.transform = .identity
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = collectionView.cellForItem(at: indexPath) as? UFXJekIconCVC {
                cell.transform = .init(scaleX: 0.85, y: 0.85)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = collectionView.cellForItem(at: indexPath) as? UFXJekIconCVC {
                cell.transform = .identity
            }
        }
    }
    
   
    
    func myLableTapped(sender: MyLabel) {
        if(self.cancelBtnSheetLbl != nil && sender == cancelBtnSheetLbl){
            if(self.bottomSheetCnt != nil){
                self.bottomSheetCnt.dismissView(viewDismissHandler: { (isViewDismissed) in
                    self.bottomSheetCnt = nil
                })
            }
        }
    }
    
    @IBAction func unwindToUFXHomeScreen(_ segue:UIStoryboardSegue) {
      
    }
}

