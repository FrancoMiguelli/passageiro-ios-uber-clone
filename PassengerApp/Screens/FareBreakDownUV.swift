//
//  FareBreakDownUV.swift
//  PassengerApp
//
//  Created by ADMIN on 07/06/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import CoreLocation

class FareBreakDownUV: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var noteLbl: MyLabel!
    @IBOutlet weak var vehicleTypeLbl: MyLabel!
    @IBOutlet weak var fareDataContainerView: UIView!
    @IBOutlet weak var fareContainerStackView: UIStackView!
    @IBOutlet weak var fareContainerStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var detailsContainerViewHeight: NSLayoutConstraint!
    
    let generalFunc = GeneralFunctions()
    
    var selectedCabTypeId = ""
    var selectedCabTypeName = ""
    
    var promoCode = ""
    
    var loaderView:UIView!
    
    var pickUpLocation:CLLocation!
    var destLocation:CLLocation!
    
    var time = ""
    var distance = ""
    
    var isPageLoad = false
    
    var isFirstLaunch = true
    var cntView:UIView!
    
    var isDestinationAdded = "Yes"
    var eFlatTrip = false
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.layer.zPosition = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.layer.zPosition = -1
        
        if(isFirstLaunch){
            
            cntView.frame.size = CGSize(width: cntView.frame.width, height: 600)
            self.scrollView.bounces = false
            //            self.scrollView.setContentViewSize(offset: 15, currentMaxHeight: self.scrollViewCOntentViewHeight.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: 600)
            self.scrollView.backgroundColor = UIColor(hex: 0xf2f2f4)
            cntView.backgroundColor = UIColor(hex: 0xf2f2f4)
            
            isFirstLaunch = false
            
            
            self.getData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cntView = self.generalFunc.loadView(nibName: "FareBreakDownScreenDesign", uv: self, contentView: scrollView)
        
        self.scrollView.addSubview(cntView)
        
        self.addBackBarBtn()
        
        self.headerView.backgroundColor = UIColor.UCAColor.AppThemeColor
        
        vehicleTypeLbl.text = selectedCabTypeName
        vehicleTypeLbl.textColor = UIColor.UCAColor.AppThemeColor
        addLoader()
        setData()
        
        self.detailsContainerView.isHidden = true
        
    }

    func setData(){
        //Marlon - Comentado item que estava com erro
        //TODO: Verificar melhor método para adicionar titulo ao NavigationItem
//        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FARE_BREAKDOWN_TXT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FARE_BREAKDOWN_TXT")
        
//        self.noteLbl.text = self.generalFunc.getLanguageLabel(origValue: "This fare is based on our estimation. This may vary during trip and final fare.", key: "LBL_GENERAL_NOTE_FARE_EST")
        
         self.noteLbl.text = self.generalFunc.getLanguageLabel(origValue: self.eFlatTrip == true ? "This fare is based on your source to destination location. System will charge fixed fare depending on your location." : "This fare is based on our estimation. This may vary during trip and final fare.", key: self.eFlatTrip == true ? "LBL_GENERAL_NOTE_FLAT_FARE_EST" : "LBL_GENERAL_NOTE_FARE_EST")
        
        
        self.noteLbl.fitText()
        
        self.detailsContainerView.layer.shadowOpacity = 0.5
        self.detailsContainerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.detailsContainerView.layer.shadowColor = UIColor.black.cgColor
        self.detailsContainerView.layer.cornerRadius = 10
        self.detailsContainerView.layer.masksToBounds = true
    }
    
    func addLoader(){
        if(loaderView != nil){
            loaderView.removeFromSuperview()
        }
        
        loaderView =  self.generalFunc.addMDloader(contentView: self.view)
        loaderView.backgroundColor = UIColor.clear
    }
    func getData(){
        
        if(self.destLocation != nil && self.destLocation.coordinate.latitude == 0.0 && self.destLocation.coordinate.longitude == 0.0){
            self.destLocation = self.pickUpLocation
        }
        
        let destLoc = self.destLocation != nil ? self.destLocation : self.pickUpLocation
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.pickUpLocation!.coordinate.latitude),\(self.pickUpLocation!.coordinate.longitude)&destination=\(destLoc!.coordinate.latitude),\(destLoc!.coordinate.longitude)&key=\(Configurations.getGoogleServerKey())&language=\(Configurations.getGoogleMapLngCode())&sensor=true"
        
        let exeWebServerUrl = ExeServerUrl(dict_data: [String:String](), currentView: self.view, isOpenLoader: false)
        
        exeWebServerUrl.executeGetProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("status").uppercased() != "OK" || dataDict.getArrObj("routes").count == 0){
                    self.isDestinationAdded = "No"
                    self.continueEstimateFare(distance: "", time: "")
                    return
                }
                
                
                let routesArr = dataDict.getArrObj("routes")
                let legs_arr = (routesArr.object(at: 0) as! NSDictionary).getArrObj("legs")
                let duration = (legs_arr.object(at: 0) as! NSDictionary).getObj("duration").get("value")
                let distance = (legs_arr.object(at: 0) as! NSDictionary).getObj("distance").get("value")
                
                self.continueEstimateFare(distance: distance, time: duration)
                
            }else{
                //                self.generalFunc.setError(uv: self)
            }
        }, url: directionURL)
    }
    
    func continueEstimateFare(distance:String, time:String){
        var parameters = ["type":"getEstimateFareDetailsArr","SelectedCar": self.selectedCabTypeId, "distance": distance, "time": time, "iUserId": GeneralFunctions.getMemberd(), "PromoCode": promoCode, "isDestinationAdded": self.isDestinationAdded, "iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType]
        
        if(pickUpLocation != nil){
            parameters["StartLatitude"] = "\(self.pickUpLocation!.coordinate.latitude)"
            parameters["EndLongitude"] = "\(self.pickUpLocation!.coordinate.longitude)"
        }
        
        if(destLocation != nil){
            parameters["DestLatitude"] = "\(self.destLocation!.coordinate.latitude)"
            parameters["DestLongitude"] = "\(self.destLocation!.coordinate.longitude)"
        }
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
//            print("Response:\(response)")
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    self.addFareDetails(msgArr: dataDict.getArrObj(Utils.message_str))
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
            
            self.loaderView.isHidden = true
        })
    }
    
    func addFareDetails(msgArr:NSArray){
        
        var totalSeperatorViews = 0
        let seperatorViewHeight = 1
        
        for i in 0..<msgArr.count {
            
            let dict_temp = msgArr[i] as! NSDictionary
            
            for (key, value) in dict_temp {
//                print("\(key): \(value)")
                
                var totalSubViewCounts = self.fareDataContainerView.subviews.count
                var viewCus: UIView?
                if((key as! String) == "eDisplaySeperator"){
                    let viewWidth = Application.screenSize.width - 36
                    
                    viewCus = UIView(frame: CGRect(x: 10, y: CGFloat((totalSubViewCounts - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight)), width: viewWidth - 20, height: 1))
                    
                    viewCus!.backgroundColor = UIColor(hex: 0xdedede)
                    
                    //                    self.fareContainerView.addArrangedSubview(viewCus)
                    self.fareDataContainerView.addSubview(viewCus!)
                    
                    totalSeperatorViews = totalSeperatorViews + 1
                }else{
                    let viewWidth = Application.screenSize.width - 36
                    
                    var titleStr = ""
                    var valueStr = ""
                    
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
                    
//                    self.fareContainerStackView.addArrangedSubview(viewCus)
                    self.fareDataContainerView.addSubview(viewCus!)
                    
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
                        self.fareDataContainerView.addSubview(detailTarContainerView!)
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
            self.fareContainerStackViewHeight.constant = CGFloat((self.fareDataContainerView.subviews.count - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight))
        }
        
       
        self.detailsContainerViewHeight.constant = self.fareContainerStackViewHeight.constant + 55
        
        self.fareContainerStackView.layoutIfNeeded()
        self.fareDataContainerView.layoutIfNeeded()
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.cntView.frame.size = CGSize(width: self.cntView.frame.width, height: self.detailsContainerView.frame.maxY + 20)
            
            //            self.scrollView.setContentViewSize(offset: 15, currentMaxHeight: self.scrollViewCOntentViewHeight.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.detailsContainerView.frame.maxY + 20)
        })
        
        self.detailsContainerView.isHidden = false
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
                print(self.fareDataContainerView.subviews.count)
                self.detailTarContainerView!.layoutIfNeeded()
                let lineIndex = (self.fareDataContainerView.subviews.count - self.detailTarContainerView!.subviews.count) - 1
                let viewLine = self.fareDataContainerView.subviews[lineIndex]
                print(viewLine.frame.height)
                let viewLineFrame = viewLine.frame
                viewLine.frame = CGRect(x: viewLineFrame.origin.x, y: CGFloat(viewLineFrame.origin.y - self.detailViewHeight), width: viewLineFrame.width, height: viewLineFrame.height)
                
                let totalIndex = (self.fareDataContainerView.subviews.count - self.detailTarContainerView!.subviews.count)
                let viewTotal = self.fareDataContainerView.subviews[totalIndex]
                let viewTotalFrame = viewTotal.frame
                viewTotal.frame = CGRect(x: viewTotalFrame.origin.x, y: CGFloat(viewTotalFrame.origin.y - self.detailViewHeight), width: viewTotalFrame.width, height: viewTotalFrame.height)
                //self.chargesContainerViewHeight.constant = CGFloat(self.chargesContainerViewHeight.constant -
                //CGFloat(self.detailTarContainerView!.subviews.count * 40))
                let fareFrame = self.fareDataContainerView.frame
                self.fareDataContainerView.frame = CGRect(fareFrame.origin.x, fareFrame.origin.y, fareFrame.width, CGFloat(fareFrame.height - CGFloat(self.detailTarContainerView!.subviews.count * 40)))
                let detailsParentFrame = self.detailsContainerView.frame
                self.detailsContainerView.frame = CGRect(detailsParentFrame.origin.x, detailsParentFrame.origin.y, detailsParentFrame.width, CGFloat(detailsParentFrame.height - CGFloat(self.detailTarContainerView!.subviews.count * 40)))
                self.detailViewHeight = 0
                self.fareDataContainerView.layoutIfNeeded()
                self.fareContainerStackView.layoutIfNeeded()
                self.detailTarContainerView!.layoutIfNeeded()
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
                
                let lineIndex = (self.fareDataContainerView.subviews.count - self.detailTarContainerView!.subviews.count) - 1
                let viewLine = self.fareDataContainerView.subviews[lineIndex]
                let viewLineFrame = viewLine.frame
                viewLine.frame = CGRect(x: viewLineFrame.origin.x, y: CGFloat(viewLineFrame.origin.y + self.detailViewHeight), width: viewLineFrame.width, height: viewLineFrame.height)
                
                let totalIndex = (self.fareDataContainerView.subviews.count - self.detailTarContainerView!.subviews.count)
                let viewTotal = self.fareDataContainerView.subviews[totalIndex]
                let viewTotalFrame = viewTotal.frame
                viewTotal.frame = CGRect(x: viewTotalFrame.origin.x, y: CGFloat(viewTotalFrame.origin.y + self.detailViewHeight), width: viewTotalFrame.width, height: viewTotalFrame.height)
                let fareFrame = self.fareDataContainerView.frame
                self.fareDataContainerView.frame = CGRect(fareFrame.origin.x, fareFrame.origin.y, fareFrame.width, CGFloat(fareFrame.height + CGFloat(self.detailTarContainerView!.subviews.count * 40)))
                let detailsParentFrame = self.detailsContainerView.frame
                self.detailsContainerView.frame = CGRect(detailsParentFrame.origin.x, detailsParentFrame.origin.y, detailsParentFrame.width, CGFloat(detailsParentFrame.height + CGFloat(self.detailTarContainerView!.subviews.count * 40)))
                
                self.fareDataContainerView.layoutIfNeeded()
                self.fareContainerStackView.layoutIfNeeded()
                self.detailTarContainerView!.layoutIfNeeded()
            })
        }
    }
}
