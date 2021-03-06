//
//  RideDetailUV.swift
//  PassengerApp
//
//  Created by ADMIN on 06/06/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import GoogleMaps
import SafariServices
import SDWebImage

class RideDetailUV: UIViewController, MyBtnClickDelegate, OnDirectionUpdateDelegate , MyLabelClickDelegate{

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var helpLbl: MyLabel!
    @IBOutlet weak var userHeaderView: UIView!
    @IBOutlet weak var userHeaderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userPicBgView: UIView!
    @IBOutlet weak var userPicBgImgView: UIImageView!
    
    @IBOutlet weak var userPicImgView: UIImageView!
    @IBOutlet weak var userNameHLbl: MyLabel!
    @IBOutlet weak var userNameVLbl: MyLabel!
    @IBOutlet weak var ratingHLbl: MyLabel!
    @IBOutlet weak var ratingBar: RatingView!
    @IBOutlet weak var thanksHLbl: MyLabel!
    @IBOutlet weak var rideNoLbl: MyLabel!
    @IBOutlet weak var tripReqDateHLbl: MyLabel!
    @IBOutlet weak var tripReqDateVLbl: MyLabel!
    @IBOutlet weak var pickUpLocHLbl: MyLabel!
    @IBOutlet weak var pickUpLocVLbl: MyLabel!
    @IBOutlet weak var destLocHLbl: MyLabel!
    @IBOutlet weak var destLocVLbl: MyLabel!
    @IBOutlet weak var gMapView: GMSMapView!
    @IBOutlet weak var chargesParentView: UIView!
    @IBOutlet weak var chargesHLbl: MyLabel!
    @IBOutlet weak var vehicleTypeLbl: MyLabel!
    @IBOutlet weak var chargesDataContainerView: UIView!
    @IBOutlet weak var chargesContainerView: UIStackView!
    @IBOutlet weak var chargesContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chargesParentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var payImgView: UIImageView!
    @IBOutlet weak var paymentTypeLbl: MyLabel!
    @IBOutlet weak var tripStatusLbl: MyLabel!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tipInfoLbl: MyLabel!
    @IBOutlet weak var tipHLbl: MyLabel!
    @IBOutlet weak var tipAmountLbl: MyLabel!
    @IBOutlet weak var tipTopPlusLbl: MyLabel!
    @IBOutlet weak var tipViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var serviceAreaCenterViewOffset: NSLayoutConstraint!
    @IBOutlet weak var serviceImageAreaHeight: NSLayoutConstraint!
    @IBOutlet weak var serviceImageAreaView: UIView!
    @IBOutlet weak var beforeServiceImgArea: UIView!
    @IBOutlet weak var afterServiceImgArea: UIView!
    @IBOutlet weak var beforeServiceImgView: UIImageView!
    @IBOutlet weak var beforeServiceLbl: MyLabel!
    @IBOutlet weak var afterServiceImgView: UIImageView!
    @IBOutlet weak var afterServiceLbl: MyLabel!
    @IBOutlet weak var mapTopMargin: NSLayoutConstraint!
    
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingHintLbl: MyLabel!
    @IBOutlet weak var ufxRatingBar: RatingView!
    @IBOutlet weak var ratingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var submitRatingBtn: MyButton!
    @IBOutlet weak var commentTxtView: KMPlaceholderTextView!
    
    var tripDetailDict:NSDictionary!
    
    let generalFunc = GeneralFunctions()
        
    var isPageLoaded = false
    
    var cntView:UIView!
    
//    var PAGE_HEIGHT:CGFloat = 970
    
    var PAGE_HEIGHT:CGFloat = 735
    
    var updateDirection:UpdateDirections!
    
    var CHARGES_PARENT_VIEW_OFFSET_HEIGHT:CGFloat = 50
    
    var detailTarContainerView: UIStackView?
    var detailHeightConstraint: NSLayoutConstraint?
    var hasDetail: Bool = false
    var isDetailFinished: Bool = false
    var detailViewHeight: CGFloat = 0
    var detailViewWidth: CGFloat = 0
    var detailsCount: Int = 0
    var detailImg: UIImageView = {
        let img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.image = UIImage(named: "nextBarButton")
        img.alpha = 0
        return img
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cntView = self.generalFunc.loadView(nibName: "RideDetailScreenDesign", uv: self, contentView: scrollView)
        
        self.scrollView.addSubview(cntView)
//        self.contentView.addSubview(scrollView)
       
        scrollView.bounces = false
        scrollView.backgroundColor = UIColor(hex: 0xF2F2F4)
        cntView.frame.size = CGSize(width: cntView.frame.width, height: self.PAGE_HEIGHT)
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.PAGE_HEIGHT)
        
        self.userNameHLbl.setCustomBGColor(color: UIColor.clear)
        self.userNameHLbl.setCustomTextColor(color: UIColor.UCAColor.tripDetailHeaderBarHTxtColor)
        
        self.ratingHLbl.setCustomBGColor(color: UIColor.clear)
        self.ratingHLbl.setCustomTextColor(color: UIColor.UCAColor.tripDetailHeaderBarHTxtColor)
        
        self.ratingBar.fullStarColor = UIColor.UCAColor.tripDetailUserRatingFillColor
        
        self.addBackBarBtn()
        
        let getReceiptBtn = UIBarButtonItem(title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_GET_RECEIPT_TXT"), style: .plain, target: self, action: #selector(self.getReceiptBtnTapped))
        self.navigationItem.rightBarButtonItem = getReceiptBtn
        
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        blurEffectView.frame = userPicBgView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.userPicBgView.addSubview(blurEffectView)
        
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        setData()
    }
    
    
    func setData(){
        
//        let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)

        //Marlon - Comentado item que estava com erro
        //TODO: Verificar melhor método para adicionar titulo ao NavigationItem
//        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIPT_HEADER_TXT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIPT_HEADER_TXT")
        
        let driverDetails = self.tripDetailDict.getObj("DriverDetails")
        self.userNameVLbl.text = "\(driverDetails.get("vName").uppercased()) \(driverDetails.get("vLastName").uppercased())"
        
//        self.tripReqDateVLbl.text = self.tripDetailDict.get("tTripRequestDate")
        self.tripReqDateVLbl.text = Utils.convertDateFormateInAppLocal(date: Utils.convertDateGregorianToAppLocale(date: self.tripDetailDict.get("tTripRequestDateOrig"), dateFormate: "yyyy-MM-dd HH:mm:ss"), toDateFormate: Utils.dateFormateWithTime)
        
        
        self.commentTxtView.placeholder = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_WRITE_COMMENT_HINT_TXT")
        
        self.userNameHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_CARRIER" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_SERVICE_PROVIDER_TXT" : "LBL_DRIVER")).uppercased()
        
        self.ratingHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RATING").uppercased()
        
        self.pickUpLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "Sender's Location" : "PickUp Location", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_SENDER_LOCATION" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_JOB_LOCATION_TXT" : "LBL_PICKUP_LOCATION_TXT")).uppercased()
        
        self.destLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_DELIVERY_DETAILS_TXT" : "LBL_DEST_LOCATION").uppercased()
        
        self.tripReqDateHLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "DELIVERY REQUEST DATE" : "", key:  self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_DELIVERY_REQUEST_DATE" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_JOB_REQ_DATE" : "LBL_TRIP_REQUEST_DATE_TXT")).uppercased()
        
        self.chargesHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CHARGES_TXT").uppercased()
        self.thanksHLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "Thanks for using delivery service" : "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_THANKS_DELIVERY_TXT" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_THANKS_JOB_TXT" : "LBL_THANKS_RIDING_TXT")).uppercased()
        self.thanksHLbl.textColor = UIColor.UCAColor.AppThemeColor
        self.thanksHLbl.fitText()
        
        self.rideNoLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Ride ? "LBL_RIDE" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_BOOKING" : "LBL_DELIVERY")).uppercased())# \(Configurations.convertNumToAppLocal(numStr: self.tripDetailDict.get("vRideNo")))"
        
        self.pickUpLocVLbl.text = self.tripDetailDict.get("tSaddress")
        
        if(self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver){
            self.destLocVLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIVER_NAME")): \(self.tripDetailDict.get("vReceiverName"))\n\n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECEIVER_LOCATION")): \(self.tripDetailDict.get("tDaddress"))\n\n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PACKAGE_TYPE_TXT")): \(self.tripDetailDict.get("PackageType"))\n\n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PACKAGE_DETAILS")): \(self.tripDetailDict.get("tPackageDetails"))"
        }else{
            self.destLocVLbl.text = self.tripDetailDict.get("tDaddress") == "" ? "----" :  self.tripDetailDict.get("tDaddress")
        }
        
        self.pickUpLocVLbl.fitText()
        self.destLocVLbl.fitText()
        
        if(self.tripDetailDict.get("vTripPaymentMode") == "Cash"){
            self.paymentTypeLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CASH_PAYMENT_TXT")
            self.payImgView.image = UIImage(named: "ic_cash_new")!
        }else{
            self.paymentTypeLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CARD_PAYMENT")
            self.payImgView.image = UIImage(named: "ic_card_new")!
        }
        
        self.ratingBar.rating = GeneralFunctions.parseFloat(origValue: 0.0, data: self.tripDetailDict.get("TripRating"))
        
        
        userPicBgImgView.sd_setImage(with: URL(string: "\(CommonUtils.driver_image_url)\(tripDetailDict.get("iDriverId"))/\(driverDetails.get("vImage"))"), placeholderImage: UIImage(named: "ic_no_pic_user"))

        userPicImgView.sd_setImage(with: URL(string: "\(CommonUtils.driver_image_url)\(tripDetailDict.get("iDriverId"))/\(driverDetails.get("vImage"))"), placeholderImage: UIImage(named: "ic_no_pic_user"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            
        })
        
        Utils.createRoundedView(view: userPicImgView, borderColor: UIColor.clear, borderWidth: 0)
        
        if(tripDetailDict.get("eType").uppercased() == Utils.cabGeneralType_UberX.uppercased()){
            self.vehicleTypeLbl.text = "\(tripDetailDict.get("vVehicleCategory"))-\(tripDetailDict.get("vVehicleType"))"
        }else{
            self.vehicleTypeLbl.text = tripDetailDict.get("carTypeName")
        }
        let vTypeNameHeight = self.vehicleTypeLbl.text!.height(withConstrainedWidth: Application.screenSize.width - 56, font: UIFont(name: "Roboto-Light", size: 20)!) - 24
        self.CHARGES_PARENT_VIEW_OFFSET_HEIGHT = self.CHARGES_PARENT_VIEW_OFFSET_HEIGHT + vTypeNameHeight
        self.vehicleTypeLbl.textAlignment = .center
        self.vehicleTypeLbl.textColor = UIColor.UCAColor.AppThemeColor
//        self.tripDetailDict.get("carTypeName")
        
        let tripStatus = tripDetailDict.get("iActive")
        
        if(tripStatus == "Canceled"){
            if(tripDetailDict.get("eCancelledBy").uppercased() == "DRIVER"){
                self.tripStatusLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_PREFIX_DELIVERY_CANCEL_DRIVER" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_PREFIX_JOB_CANCEL_PROVIDER" : "LBL_PREFIX_TRIP_CANCEL_DRIVER"))) \(tripDetailDict.get("vCancelReason"))"
            }else{
                self.tripStatusLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "" : "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "LBL_CANCELED_DELIVERY_TXT" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_CANCELED_JOB" : "LBL_CANCELED_TRIP_TXT"))
            }
            
            self.navigationItem.rightBarButtonItem = nil
        }else if(tripStatus == "Finished"){
            self.tripStatusLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "This delivery was successfully finished" : "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "LBL_FINISHED_DELIVERY_TXT" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_FINISHED_JOB_TXT" : "LBL_FINISHED_TRIP_TXT"))
            
            if(tripDetailDict.get("tEndLat") != "" && tripDetailDict.get("tEndLong") != "" && (self.tripDetailDict.get("eType") != Utils.cabGeneralType_UberX || self.tripDetailDict.get("eFareType") == "Regular")){
                drawRoute()
            }
        }else{
            self.tripStatusLbl.text = tripStatus
        }
        
        if(tripDetailDict.get("eCancelled") == "Yes"){
            if(tripDetailDict.get("eCancelledBy").uppercased() == "DRIVER"){
                self.tripStatusLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_PREFIX_DELIVERY_CANCEL_DRIVER" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_PREFIX_JOB_CANCEL_PROVIDER" : "LBL_PREFIX_TRIP_CANCEL_DRIVER"))) \(tripDetailDict.get("vCancelReason"))"
            }else{
                self.tripStatusLbl.text = self.generalFunc.getLanguageLabel(origValue: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "" : "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ?  "LBL_CANCELED_DELIVERY_TXT" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_CANCELED_JOB" : "LBL_CANCELED_TRIP_TXT"))
            }
            
        }
        
        self.tripStatusLbl.fitText()
        
        self.tripStatusLbl.backgroundColor = UIColor.UCAColor.AppThemeColor
        self.tripStatusLbl.textColor = UIColor.UCAColor.AppThemeTxtColor_1
        self.tripStatusLbl.setPadding(paddingTop: 20, paddingBottom: 20, paddingLeft: 10, paddingRight: 10)
        
        Utils.createRoundedView(view: self.tripStatusLbl, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 5)
        Utils.createRoundedView(view: self.chargesParentView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        
        Utils.createRoundedView(view: self.tipView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        
        var bounds = GMSCoordinateBounds()
        
        let sourceMarker = GMSMarker()
        sourceMarker.position = (CLLocation(latitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tStartLat")), longitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tStartLong")))).coordinate
        sourceMarker.icon = UIImage(named: "ic_source_marker")!
        
        sourceMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        sourceMarker.map = self.gMapView
        
        bounds = bounds.includingCoordinate(sourceMarker.position)
        
        if(tripDetailDict.get("tEndLat") != ""){
            let destMarker = GMSMarker()
            destMarker.position = (CLLocation(latitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tEndLat")), longitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tEndLong")))).coordinate
            destMarker.icon = UIImage(named: "ic_destination_place_image")!

            destMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            destMarker.map = self.gMapView
            
            bounds = bounds.includingCoordinate(destMarker.position)
        }
        
        if(self.tripDetailDict.get("eHailTrip") == "Yes"){
            self.userHeaderView.isHidden = true
            userHeaderViewHeight.constant = 0
            self.PAGE_HEIGHT = self.PAGE_HEIGHT - 145
        }
        
        if(self.tripDetailDict.get("fTipPrice") != "" && self.tripDetailDict.get("fTipPrice") != "0" && self.tripDetailDict.get("fTipPrice") != "0.00"){
            self.PAGE_HEIGHT = self.PAGE_HEIGHT + 130
            self.tipAmountLbl.text = Configurations.convertNumToAppLocal(numStr: self.tripDetailDict.get("fTipPrice"))
            self.tipInfoLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_TIP_INFO_SHOW_USER" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_Ride ? "LBL_TIP_INFO_SHOW_RIDER" : "LBL_TIP_INFO_SHOW_DELIVERY"))
            self.tipHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TIP_AMOUNT")
            self.tipViewHeight.constant = self.tipViewHeight.constant + (self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_TIP_INFO_SHOW_USER" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_Ride ? "LBL_TIP_INFO_SHOW_RIDER" : "LBL_TIP_INFO_SHOW_DELIVERY")).height(withConstrainedWidth: Application.screenSize.width - 50, font: UIFont(name: "Roboto-Light", size: 16)!) - 20)
            self.tipInfoLbl.fitText()
            self.tipTopPlusLbl.text = "+"
        }else{
            self.tipView.isHidden = true
            self.tipViewHeight.constant = 0
            self.tipViewTopMargin.constant = 0
            self.tipTopPlusLbl.text = ""
            self.tipTopPlusLbl.fitText()
        }
        
        if(self.tripDetailDict.get("vBeforeImage") != "" || self.tripDetailDict.get("vAfterImage") != "" ){
            self.PAGE_HEIGHT = self.PAGE_HEIGHT + 115
            self.serviceImageAreaView.isHidden = false
            self.beforeServiceLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BEFORE_SERVICE")
            self.afterServiceLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_AFTER_SERVICE")
            
            let vBeforeImage = Utils.getResizeImgURL(imgUrl: self.tripDetailDict.get("vBeforeImage"), width: Utils.getValueInPixel(value: 100), height: Utils.getValueInPixel(value: 100))
            let vAfterImage = Utils.getResizeImgURL(imgUrl: self.tripDetailDict.get("vAfterImage"), width: Utils.getValueInPixel(value: 100), height: Utils.getValueInPixel(value: 100))
            
            beforeServiceImgView.sd_setImage(with: URL(string: vBeforeImage), placeholderImage: UIImage(named: "ic_no_icon"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
            })
            
            afterServiceImgView.sd_setImage(with: URL(string: vAfterImage), placeholderImage: UIImage(named: "ic_no_icon"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
            })
            
            if(self.tripDetailDict.get("vBeforeImage") == ""){
                self.beforeServiceImgArea.isHidden = true
                self.serviceAreaCenterViewOffset.constant = -60
            }
            if(self.tripDetailDict.get("vAfterImage") == ""){
                self.afterServiceImgArea.isHidden = true
                self.serviceAreaCenterViewOffset.constant = 60
            }
            
            let beforeTapGue = UITapGestureRecognizer()
            let afterTapGue = UITapGestureRecognizer()
            
            beforeTapGue.addTarget(self, action: #selector(self.openBeforeImage))
            afterTapGue.addTarget(self, action: #selector(self.openAfterImage))
            
            self.beforeServiceImgArea.isUserInteractionEnabled = true
            self.beforeServiceImgArea.addGestureRecognizer(beforeTapGue)
            
            self.afterServiceImgArea.isUserInteractionEnabled = true
            self.afterServiceImgArea.addGestureRecognizer(afterTapGue)
            
        }else{
            self.serviceImageAreaHeight.constant = 0
            self.serviceImageAreaView.isHidden = true
        }
        
        if(self.tripDetailDict.get("is_rating") == "No" && tripStatus == "Finished"){
            self.PAGE_HEIGHT = self.PAGE_HEIGHT + 130
            self.ratingView.isHidden = false
            self.submitRatingBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RATE"))
            self.submitRatingBtn.isAppTheme = true
            self.ratingHintLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: self.tripDetailDict.get("eType") == Utils.cabGeneralType_UberX ? "LBL_RATE_HEADING_PROVIDER" : (self.tripDetailDict.get("eType") == Utils.cabGeneralType_Deliver ? "LBL_RATE_HEADING_CARRIER" : "LBL_RATE_HEADING_DRIVER")).trim()
            self.submitRatingBtn.clickDelegate = self
        }else{
            self.ratingViewHeight.constant = 0
            self.ratingView.isHidden = true
        }
        
        self.helpLbl.text = self.generalFunc.getLanguageLabel(origValue: "Need help?", key: "LBL_NEED_HELP")
        self.helpLbl.setClickDelegate(clickDelegate: self)
        self.helpLbl.backgroundColor = UIColor.UCAColor.AppThemeColor
        self.helpLbl.layer.cornerRadius = 20
        self.helpLbl.layer.masksToBounds = true
        self.helpLbl.setPadding(paddingTop: 10, paddingBottom: 10, paddingLeft: 10, paddingRight: 10 )
        self.helpLbl.fitText()
        self.helpLbl.textColor = UIColor.UCAColor.AppThemeTxtColor_1
        self.helpLbl.font.withSize(14)
        self.helpLbl.textAlignment = NSTextAlignment.center
        
        if(self.tripDetailDict.get("tDaddress") == ""){
            self.destLocHLbl.isHidden = true
            mapTopMargin.constant = -70
            self.destLocVLbl.isHidden = true
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
        gMapView.animate(with: update)
        
        self.addFareDetails()
    }
    
    func myLableTapped(sender: MyLabel) {
        let helpCategoryUv = GeneralFunctions.instantiateViewController(pageName: "HelpCategoryUV") as! HelpCategoryUV
        helpCategoryUv.iTripId =  self.tripDetailDict.get("iTripId")
        self.pushToNavController(uv: helpCategoryUv)
    }
    
    @objc func openBeforeImage(){
        let url = URL(string: self.tripDetailDict.get("vBeforeImage"))!
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
    }
    
    @objc func openAfterImage(){
        let url = URL(string: self.tripDetailDict.get("vAfterImage"))!
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
    }
    
    func addFareDetails(){
        
        let HistoryFareDetailsNewArr = self.tripDetailDict.getObj(Utils.message_str).getArrObj("HistoryFareDetailsNewArr")
        var totalSeperatorViews = 0
        let seperatorViewHeight = 1
        
        for i in 0..<HistoryFareDetailsNewArr.count {
            
            let dict_temp = HistoryFareDetailsNewArr[i] as! NSDictionary
            
            for (key, value) in dict_temp {
                
                var totalSubViewCounts = self.chargesDataContainerView.subviews.count
                var viewCus: UIView?
                if((key as! String) == "eDisplaySeperator"){
                    let viewWidth = Application.screenSize.width - 36
                    
                    viewCus = UIView(frame: CGRect(x: 10, y: CGFloat((totalSubViewCounts - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight)), width: viewWidth - 20, height: 1))
                    
                    viewCus!.backgroundColor = UIColor(hex: 0xdedede)
                    
                    //                    self.fareContainerView.addArrangedSubview(viewCus)
                    self.chargesDataContainerView.addSubview(viewCus!)
                    
                    totalSeperatorViews = totalSeperatorViews + 1
                }else{
                    let viewWidth = Application.screenSize.width - 36
                    
                    var titleStr = ""
                    var valueStr = ""
                    //Marlon
                    if((key as! String) == "Detalhes"){
                        let dict_tar = value as! NSArray
                        detailsCount = dict_tar.count
                        if (dict_tar.count > 0) {
                            detailViewHeight = CGFloat(dict_tar.count * 40)
                            hasDetail = true
                            detailViewWidth = viewWidth - 30
                            detailTarContainerView = UIStackView(frame: CGRect(x: 30, y: CGFloat((totalSubViewCounts - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight) + 40), width: detailViewWidth, height: CGFloat(dict_tar.count * 40)))
                            detailTarContainerView!.translatesAutoresizingMaskIntoConstraints = false
                            detailTarContainerView!.axis = .vertical
                            detailTarContainerView!.distribution = .fillEqually
                            detailTarContainerView!.backgroundColor = UIColor.UCAColor.AppThemeColor
                            detailHeightConstraint = NSLayoutConstraint(item: detailTarContainerView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(dict_tar.count * 40))
                            print(detailTarContainerView!.frame.origin.y)
                            for i in 0..<dict_tar.count {
                                let dictTarTemp = dict_tar[i] as! NSDictionary
                                for (keyTar, valueTar) in dictTarTemp {
                                    viewCus = UIView(frame: CGRect(x: detailTarContainerView!.frame.origin.x, y: CGFloat((totalSubViewCounts - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight) + ((i+1) * 40)), width: detailViewWidth, height: 40))
                                    print(viewCus!.frame.origin.y)
                                    titleStr = Configurations.convertNumToAppLocal(numStr: keyTar as! String)
                                    valueStr = Configurations.convertNumToAppLocal(numStr: valueTar as! String)
                                    detailTarContainerView?.backgroundColor = UIColor.UCAColor.Amber
                                    let font = UIFont(name: "Roboto-Light", size: 15)!
                                    var widthOfTitle1 = titleStr.width(withConstrainedHeight: 40, font: font) + 15
                                    var widthOfvalue1 = valueStr.width(withConstrainedHeight: 40, font: font) + 15
                                    
                                    if(widthOfTitle1 > ((detailViewWidth * 20) / 100) && widthOfvalue1 > ((detailViewWidth * 80) / 100)){
                                        widthOfvalue1 = ((detailViewWidth * 80) / 100)
                                        widthOfTitle1 = ((detailViewWidth * 20) / 100)
                                    }else if(widthOfTitle1 < ((detailViewWidth * 20) / 100) && widthOfvalue1 > ((detailViewWidth * 80) / 100) && (detailViewWidth - widthOfTitle1 - widthOfvalue1) < 0){
                                        widthOfvalue1 = detailViewWidth - widthOfvalue1
                                    }
                                    
                                    let widthOfParentView = detailViewWidth - widthOfvalue1
                                    
                                    var lblTitle = MyLabel(frame: CGRect(x: 0, y: 0, width: widthOfParentView - 5, height: 40))
                                    var lblValue = MyLabel(frame: CGRect(x: widthOfParentView, y: 0, width: widthOfvalue1, height: 40))
                                    
                                    if(Configurations.isRTLMode()){
                                        lblTitle = MyLabel(frame: CGRect(x: widthOfvalue1 + 5, y: 0, width: widthOfParentView, height: 40))
                                        lblValue = MyLabel(frame: CGRect(x: 0, y: 0, width: widthOfvalue1, height: 40))
                                        
                                        lblTitle.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 15)
                                        lblValue.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 15, paddingRight: 0)
                                    }else{
                                        lblTitle.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 15, paddingRight: 0)
                                        lblValue.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 15)
                                    }
                                    
                                    lblTitle.textColor = UIColor(hex: 0x272727)
                                    lblValue.textColor = UIColor(hex: 0x272727)
                                    
                                    lblTitle.font = font
                                    lblValue.font = font
                                    
                                    lblTitle.numberOfLines = 2
                                    lblValue.numberOfLines = 2
                                    
                                    lblTitle.minimumScaleFactor = 0.5
                                    lblValue.minimumScaleFactor = 0.5
                                    
                                    lblTitle.text = titleStr
                                    lblValue.text = valueStr
                                    print(lblTitle.text)
                                    print(viewCus!.frame.height)
                                    viewCus!.addSubview(lblTitle)
                                    viewCus!.addSubview(lblValue)
                                    self.detailTarContainerView!.addSubview(viewCus!)
                                    totalSubViewCounts = totalSubViewCounts + 1
                                    if(Configurations.isRTLMode()){
                                        lblValue.textAlignment = .left
                                    }else{
                                        lblValue.textAlignment = .right
                                    }
                                }
                            }
                            isDetailFinished = true
                        }
                        continue
                    } else {
                        viewCus = UIView(frame: CGRect(x: 0, y: CGFloat((totalSubViewCounts - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight)), width: viewWidth, height: 40))
                        titleStr = Configurations.convertNumToAppLocal(numStr: key as! String)
                        valueStr = Configurations.convertNumToAppLocal(numStr: value as! String)
                    }
                    
                    let font = UIFont(name: "Roboto-Medium", size: 16)!
                    var widthOfTitle = titleStr.width(withConstrainedHeight: 40, font: font) + 15
                    var widthOfvalue = valueStr.width(withConstrainedHeight: 40, font: font) + 15
                    
                    if(widthOfTitle > ((viewWidth * 20) / 100) && widthOfvalue > ((viewWidth * 80) / 100)){
                        widthOfvalue = ((viewWidth * 80) / 100)
                        widthOfTitle = ((viewWidth * 20) / 100)
                    }else if(widthOfTitle < ((viewWidth * 20) / 100) && widthOfvalue > ((viewWidth * 80) / 100) && (viewWidth - widthOfTitle - widthOfvalue) < 0){
                        widthOfvalue = viewWidth - widthOfTitle
                    }
                    
                    let widthOfParentView = viewWidth - widthOfvalue
                    
                    var lblTitle = MyLabel(frame: CGRect(x: 0, y: 0, width: widthOfParentView - 5, height: 40))
                    var lblValue = MyLabel(frame: CGRect(x: widthOfParentView, y: 0, width: widthOfvalue, height: 40))
                    
                    if(Configurations.isRTLMode()){
                        lblTitle = MyLabel(frame: CGRect(x: widthOfvalue + 5, y: 0, width: widthOfParentView, height: 40))
                        lblValue = MyLabel(frame: CGRect(x: 0, y: 0, width: widthOfvalue, height: 40))
                        
                        lblTitle.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 15)
                        lblValue.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 15, paddingRight: 0)
                    }else{
                        lblTitle.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 15, paddingRight: 0)
                        lblValue.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 15)
                    }
                    
                    lblTitle.textColor = UIColor(hex: 0x000000)
                    lblValue.textColor = UIColor(hex: 0x000000)
                    
                    lblTitle.font = font
                    lblValue.font = font
                    
                    lblTitle.numberOfLines = 2
                    lblValue.numberOfLines = 2
                    
                    lblTitle.minimumScaleFactor = 0.5
                    lblValue.minimumScaleFactor = 0.5
                    
                    lblTitle.text = titleStr
                    lblValue.text = valueStr
                    
                    viewCus!.addSubview(lblTitle)
                    viewCus!.addSubview(lblValue)
                    
//                    self.chargesContainerView.addArrangedSubview(viewCus)
                    
                    self.chargesDataContainerView.addSubview(viewCus!)
                
                    print(viewCus!.frame.origin.y)
                    if (hasDetail && isDetailFinished) {
                        //let imgSeta = UIImageView(image: UIImage(named: "backBarButton"))
                        self.detailImg.transform = CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180))
                        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected))
                        detailImg.isUserInteractionEnabled = true
                        detailImg.addGestureRecognizer(singleTap)
                        lblTitle.addGestureRecognizer(singleTap)
                        viewCus!.isUserInteractionEnabled = true
                        viewCus!.addGestureRecognizer(singleTap)
                        
                        let lblPosition: CGRect = lblTitle.frame
                        print(lblTitle.text)
                        detailImg.frame = CGRect(lblPosition.origin.x + widthOfTitle + 5, lblPosition.midY - 5, detailImg.frame.width, detailImg.frame.height)
                        detailImg.contentMode = .scaleAspectFit
                        detailImg.alpha = 1
                        viewCus!.addSubview(detailImg)
                        print(viewCus!.frame.height)
                        
                        //hasDetail = false
                        isDetailFinished = false
                        //let containerHeight = CGFloat(detailTarContainerView!.subviews.count * 40)
                        print(detailTarContainerView!.frame.origin.y)
                        print(detailTarContainerView!.frame.height)
                        print(viewCus!.frame.origin.y)
                        
                        self.chargesDataContainerView.addSubview(detailTarContainerView!)
                        print(detailTarContainerView!.frame.origin.y)
                        print(viewCus!.frame.origin.y)
                    } else {
                        if(Configurations.isRTLMode()){
                            lblValue.textAlignment = .left
                        }else{
                            lblValue.textAlignment = .right
                        }
                    }
                }
            }
            print("TOTAL SUBVIEWS: \(self.chargesDataContainerView.subviews.count)")
            self.chargesContainerViewHeight.constant = CGFloat((self.chargesDataContainerView.subviews.count - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight))

//            self.chargesContainerViewHeight.constant = self.chargesContainerViewHeight.constant + 40
        }
        self.chargesParentViewHeight.constant = self.chargesContainerViewHeight.constant + self.CHARGES_PARENT_VIEW_OFFSET_HEIGHT
        
        self.chargesDataContainerView.layoutIfNeeded()
        self.chargesContainerView.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            
            self.cntView.frame.size = CGSize(width: self.contentView.frame.width, height: self.tripStatusLbl.frame.maxY + 20)
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.tripStatusLbl.frame.maxY + 20)
        })
        
    }
    
    @objc func tapDetected() {
        if (detailViewHeight > 0) {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.detailImg.transform = CGAffineTransform(rotationAngle: 0 * CGFloat(CGFloat.pi/180))
                let viewDetailFrame = self.detailTarContainerView!.frame
                self.detailTarContainerView?.frame = CGRect(x: viewDetailFrame.origin.x, y: viewDetailFrame.origin.y, width: viewDetailFrame.width, height: 0)
                self.detailHeightConstraint?.constant = 0
                for (view) in self.detailTarContainerView!.subviews {
                    view.frame = CGRect(view.frame.origin.x, view.frame.origin.y, view.frame.width, 0)
                    for(sv) in view.subviews {
                        sv.frame = CGRect(sv.frame.origin.x, sv.frame.origin.y, sv.frame.width, 0)
                    }
                }
                self.detailTarContainerView!.layoutIfNeeded()
                let lineIndex = (self.chargesDataContainerView.subviews.count - self.detailTarContainerView!.subviews.count) - 1
                let viewLine = self.chargesDataContainerView.subviews[lineIndex]
                print(viewLine.frame.height)
                let viewLineFrame = viewLine.frame
                viewLine.frame = CGRect(x: viewLineFrame.origin.x, y: CGFloat(viewLineFrame.origin.y - self.detailViewHeight), width: viewLineFrame.width, height: viewLineFrame.height)

                let totalIndex = (self.chargesDataContainerView.subviews.count - self.detailTarContainerView!.subviews.count)
                let viewTotal = self.chargesDataContainerView.subviews[totalIndex]
                let viewTotalFrame = viewTotal.frame
                viewTotal.frame = CGRect(x: viewTotalFrame.origin.x, y: CGFloat(viewTotalFrame.origin.y - self.detailViewHeight), width: viewTotalFrame.width, height: viewTotalFrame.height)
                //self.chargesContainerViewHeight.constant = CGFloat(self.chargesContainerViewHeight.constant -
                    //CGFloat(self.detailTarContainerView!.subviews.count * 40))
                let chargesFrame = self.chargesDataContainerView.frame
                self.chargesDataContainerView.frame = CGRect(chargesFrame.origin.x, chargesFrame.origin.y, chargesFrame.width, CGFloat(chargesFrame.height - CGFloat(self.detailTarContainerView!.subviews.count * 40)))
                let chargesParentFrame = self.chargesParentView.frame
                self.chargesParentView.frame = CGRect(chargesParentFrame.origin.x, chargesParentFrame.origin.y, chargesParentFrame.width, CGFloat(chargesParentFrame.height - CGFloat(self.detailTarContainerView!.subviews.count * 40)))
                self.detailViewHeight = 0
                self.chargesDataContainerView.layoutIfNeeded()
                self.chargesContainerView.layoutIfNeeded()
                self.chargesParentView.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.detailViewHeight = CGFloat(self.detailTarContainerView!.subviews.count * 40)
                self.detailImg.transform = CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180))
                let viewDetailFrame = self.detailTarContainerView!.frame
                self.detailTarContainerView?.frame = CGRect(x: viewDetailFrame.origin.x, y: viewDetailFrame.origin.y, width: viewDetailFrame.width, height: CGFloat(self.detailsCount * 40))
                for (view) in self.detailTarContainerView!.subviews {
                    view.frame = CGRect(view.frame.origin.x, view.frame.origin.y, view.frame.width, 40)
                    for(sv) in view.subviews {
                        sv.frame = CGRect(sv.frame.origin.x, sv.frame.origin.y, sv.frame.width, 40)
                    }
                }

                let lineIndex = (self.chargesDataContainerView.subviews.count - self.detailTarContainerView!.subviews.count) - 1
                let viewLine = self.chargesDataContainerView.subviews[lineIndex]
                let viewLineFrame = viewLine.frame
                viewLine.frame = CGRect(x: viewLineFrame.origin.x, y: CGFloat(viewLineFrame.origin.y + self.detailViewHeight), width: viewLineFrame.width, height: viewLineFrame.height)
                
                let totalIndex = (self.chargesDataContainerView.subviews.count - self.detailTarContainerView!.subviews.count)
                let viewTotal = self.chargesDataContainerView.subviews[totalIndex]
                let viewTotalFrame = viewTotal.frame
                viewTotal.frame = CGRect(x: viewTotalFrame.origin.x, y: CGFloat(viewTotalFrame.origin.y + self.detailViewHeight), width: viewTotalFrame.width, height: viewTotalFrame.height)
                let chargesFrame = self.chargesDataContainerView.frame
                self.chargesDataContainerView.frame = CGRect(chargesFrame.origin.x, chargesFrame.origin.y, chargesFrame.width, CGFloat(chargesFrame.height + CGFloat(self.detailTarContainerView!.subviews.count * 40)))
                let chargesParentFrame = self.chargesParentView.frame
                self.chargesParentView.frame = CGRect(chargesParentFrame.origin.x, chargesParentFrame.origin.y, chargesParentFrame.width, CGFloat(chargesParentFrame.height + CGFloat(self.detailTarContainerView!.subviews.count * 40)))
                
                self.chargesDataContainerView.layoutIfNeeded()
                self.chargesContainerView.layoutIfNeeded()
                self.chargesParentView.layoutIfNeeded()
            })
        }
    }
    
    @objc func getReceiptBtnTapped(){
        
        let parameters = ["type":"getReceipt","iUserId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "iTripId": self.tripDetailDict.get("iTripId")]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
        
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                 self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: dataDict.get(Utils.message_str), key: dataDict.get(Utils.message_str)))
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
        
    }
    
    func myBtnTapped(sender: MyButton) {
        if(sender == self.submitRatingBtn){
            
            if(self.ufxRatingBar.rating > 0.0){
                let parameters = ["type":"submitRating","iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "tripID": self.tripDetailDict.get("iTripId"), "rating": "\(self.ufxRatingBar.rating)", "message": "\(commentTxtView.text!)"]
                
                let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
                exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: true)
                exeWebServerUrl.currInstance = exeWebServerUrl
                exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
                    
                    if(response != ""){
                        let dataDict = response.getJsonDataDict()
                        
                        if(dataDict.get("Action") == "1"){
                            
                            
                            self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TRIP_RATING_FINISHED_TXT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                                
                                self.performSegue(withIdentifier: "unwindToRideHistoryScreen", sender: self)
                                
                                
                            })
                            
                        }else{
                            self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                        }
                        
                    }else{
                        self.generalFunc.setError(uv: self)
                    }
                })
                
            }else{
                Utils.showSnakeBar(msg: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ERROR_RATING_DIALOG_TXT"), uv: self)
                
            }
            
           
        }
    }
    
    func drawRoute(){
//        let fromLocation = CLLocation(latitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tStartLat")), longitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tStartLong")))
//        let toLocation = CLLocation(latitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tEndLat")), longitude: GeneralFunctions.parseDouble(origValue: 0.0, data: tripDetailDict.get("tEndLong")))
//        
//        updateDirection = UpdateDirections(uv: self, gMap: self.gMapView, fromLocation: fromLocation, destinationLocation: toLocation, isCurrentLocationEnabled: false)
//        updateDirection.onDirectionUpdateDelegate = self
//        updateDirection.setCurrentLocEnabled(isCurrentLocationEnabled: false)
//        updateDirection.scheduleDirectionUpdate(eTollSkipped: tripDetailDict.get("eTollSkipped"))
    }
    
    func onDirectionUpdate(directionResultDict: NSDictionary) {
        if(updateDirection != nil){
            updateDirection.releaseTask()
            updateDirection.onDirectionUpdateDelegate = nil
            updateDirection = nil
        }
    }
}
