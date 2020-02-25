//
//  SupportUV.swift
//  PassengerApp
//
//  Created by ADMIN on 17/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import SafariServices

class SupportUV: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let generalFunc = GeneralFunctions()
    
    var MENU_ABOUTUS = "1"
    var MENU_CONTACTUS = "2"
    var MENU_HELP = "3"
    var MENU_PRIVACY = "4"
    var MENU_TERMS_CONDITION = "5"
    var MENU_SIGNOUT = "6"
    
    var isOnlyPrivacyAndTerms = false
    
    var items = [NSDictionary]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentView.addSubview(self.generalFunc.loadView(nibName: "SupportScreenDesign", uv: self, contentView: contentView))
        
        
        self.addBackBarBtn()
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "SupportItemsListTVCell", bundle: nil), forCellReuseIdentifier: "SupportItemsListTVCell")

        
        setData()
    }
    
    func setData(){

        //Marlon - Comentado item que estava com erro
        //TODO: Verificar melhor método para adicionar titulo ao NavigationItem
//        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SUPPORT_HEADER_TXT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SUPPORT_HEADER_TXT")
        
        if(isOnlyPrivacyAndTerms){
            items.append(["Title" : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PRIVACY_POLICY_TEXT"),"Image" : "ic_Lmenu_privacy","ID" : MENU_PRIVACY] as NSDictionary)
            items.append(["Title" : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TERMS_AND_CONDITION"),"Image" : "ic_Lmenu_terms_condition","ID" : MENU_TERMS_CONDITION] as NSDictionary)
        }else{
            items.append(["Title" : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ABOUT_US_TXT"),"Image" : "ic_Lmenu_aboutUs","ID" : MENU_ABOUTUS] as NSDictionary)
            items.append(["Title" : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PRIVACY_POLICY_TEXT"),"Image" : "ic_Lmenu_privacy","ID" : MENU_PRIVACY] as NSDictionary)
            items.append(["Title" : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TERMS_AND_CONDITION"),"Image" : "ic_Lmenu_terms_condition","ID" : MENU_TERMS_CONDITION] as NSDictionary)
            items.append(["Title" : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CONTACT_US_TXT"),"Image" : "ic_Lmenu_contactUs","ID" : MENU_CONTACTUS] as NSDictionary)
            items.append(["Title" : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FAQ_TXT"),"Image" : "ic_Lmenu_help","ID" : MENU_HELP] as NSDictionary)
            items.append(["Title": self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SIGNOUT_TXT"),
                          "Image": "ic_Lmenu_logOut", "ID": MENU_SIGNOUT] as NSDictionary)
        }
        

        self.tableView.reloadData()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupportItemsListTVCell", for: indexPath) as! SupportItemsListTVCell
        cell.backgroundColor = UIColor.clear
        
        let title = items[indexPath.row].object(forKey: "Title") as! String
        let imageName = items[indexPath.row].object(forKey: "Image") as! String
        cell.menuLbl.text = title
        cell.menuLbl.removeGestureRecognizer(cell.menuLbl.tapGue)
        cell.menuImgView.image = UIImage(named: imageName)
        cell.menuLbl.textColor = UIColor(hex: 0x272727)
        //GeneralFunctions.setImgTintColor(imgView: cell.menuImgView, color: UIColor(hex: 0x272727))
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedMenuId = items[indexPath.item].object(forKey: "ID") as! String
        
        switch selectedMenuId {
        
        case MENU_ABOUTUS:
            openAbout()
            break
        case MENU_PRIVACY:
            openPrivacy()
            break
        case MENU_TERMS_CONDITION:
            openTerms()
            break
        case MENU_CONTACTUS:
            openContactUs()
            break
        case MENU_HELP:
            openHelp()
            break
        case
            MENU_SIGNOUT:
            logout()
            break
        default:
            break
        }
        
    }
    
    func logout() {
//        if(self.userProfileJson.get("eReviewModeLogin").uppercased() == "YES"){
//            GeneralFunctions.logOutUser()
//
//            GeneralFunctions.postNotificationSignal(key: Utils.releaseAllTaskObserverKey, obj: self)
//
//            GeneralFunctions.restartApp(window: Application.window!)
//            return
//        }
        
        self.generalFunc.setAlertMessage(uv: (self.navigationDrawerController?.rootViewController as! UINavigationController), title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_LOGOUT"), content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_WANT_LOGOUT_APP_TXT"), positiveBtn:self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_YES"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NO"), completionHandler: {(btnClickedId) in
            
            if(btnClickedId == 0){
                
                let window = UIApplication.shared.delegate!.window!
                
                let parameters = ["type":"callOnLogout", "iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType]
                
                let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: (self.navigationDrawerController?.rootViewController as! UINavigationController).view, isOpenLoader: true)
                exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
                exeWebServerUrl.currInstance = exeWebServerUrl
                exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
                    
                    if(response != ""){
                        
                        GeneralFunctions.postNotificationSignal(key: Utils.releaseAllTaskObserverKey, obj: self)
                        
                        GeneralFunctions.logOutUser()
                        GeneralFunctions.restartApp(window: window!)
                        
                    }else{
                        self.generalFunc.setError(uv: (self.navigationDrawerController?.rootViewController as! UINavigationController))
                    }
                })
                
            }
        })
    }
    
    func openAbout(){
        let staticPageUV = GeneralFunctions.instantiateViewController(pageName: "StaticPageUV") as! StaticPageUV
        staticPageUV.STATIC_PAGE_ID = "1"
        self.pushToNavController(uv: staticPageUV)
    }
    
    func openPrivacy(){
        let staticPageUV = GeneralFunctions.instantiateViewController(pageName: "StaticPageUV") as! StaticPageUV
        staticPageUV.STATIC_PAGE_ID = "33"
        self.pushToNavController(uv: staticPageUV)
    }
    
    func openTerms(){
        let staticPageUV = GeneralFunctions.instantiateViewController(pageName: "StaticPageUV") as! StaticPageUV
        staticPageUV.STATIC_PAGE_ID = "4"
        self.pushToNavController(uv: staticPageUV)
    }
    
    func openContactUs(){
        let contactUsUv = GeneralFunctions.instantiateViewController(pageName: "ContactUsUV") as! ContactUsUV
        self.pushToNavController(uv: contactUsUv)
    }
    
    func openHelp(){
        let helpUv = GeneralFunctions.instantiateViewController(pageName: "HelpUV") as! HelpUV
        self.pushToNavController(uv: helpUv)
    }
    

}
