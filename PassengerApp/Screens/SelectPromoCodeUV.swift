//
//  SelectPromoCodeUV.swift
//  PassengerApp
//
//  Created by Admin on 23/07/18.
//  Copyright © 2018 V3Cube. All rights reserved.
//

import UIKit

class SelectPromoCodeUV: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var promoTxtField: MyTextField!
    @IBOutlet weak var applyBtn: MyButton!
    @IBOutlet weak var tableView: UITableView!

    var cntView:UIView!
    var userProfileJson:NSDictionary!
    
    var generalFunc = GeneralFunctions()
    
    var loaderView:UIView!
    
    var couponCodeList = [NSDictionary]()
    
    var isSafeAreaSet = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureRTLView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
        cntView = self.generalFunc.loadView(nibName: "SelectPromoCodeScreenDesign", uv: self, contentView: contentView)
        self.contentView.addSubview(cntView)
        
        self.addBackBarBtn()
        
        self.tableView.delegate = self
        self.tableView.bounces = false
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "SelectPromoCodeTVC", bundle: nil), forCellReuseIdentifier: "SelectPromoCodeTVC")
        
        self.tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: GeneralFunctions.getSafeAreaInsets().bottom + 6, right: 0)

        setLabels()
    }
    
    func setLabels(){
        
    }

    override func viewDidLayoutSubviews() {
        if(isSafeAreaSet == false){
            if(cntView != nil){
                self.cntView.frame = self.view.frame
                cntView.frame.size.height = cntView.frame.size.height + GeneralFunctions.getSafeAreaInsets().bottom
            }
            isSafeAreaSet = true
        }
    }
    
    func getCouponCodeList(){
        if(loaderView == nil){
            loaderView =  self.generalFunc.addMDloader(contentView: self.view)
            loaderView.backgroundColor = UIColor.clear
        }else{
            loaderView.isHidden = false
        }
        cntView.isHidden = true
        let parameters = ["type":"DisplayCouponList", "UserType": Utils.appUserType, "iMemberId": GeneralFunctions.getMemberd()]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    let dataArr = dataDict.getArrObj(Utils.message_str)
                    
                    for i in 0 ..< dataArr.count{
                        let dataTemp = dataArr[i] as! NSDictionary
                        self.couponCodeList.append(dataTemp)
                    }
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                    self.cntView.isHidden = false
                }else{
                    
                }
            }else{
                self.generalFunc.setError(uv: self, isCloseScreen: true)
            }
            
            if(self.loaderView != nil){
                self.loaderView.isHidden = true
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.couponCodeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectPromoCodeTVC", for: indexPath) as! SelectPromoCodeTVC

        return cell
    }
}
