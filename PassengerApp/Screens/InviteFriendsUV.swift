//
//  InviteFriendsUV.swift
//  PassengerApp
//
//  Created by ADMIN on 13/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class InviteFriendsUV: UIViewController, MyBtnClickDelegate{

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shareHLbl: MyLabel!
    @IBOutlet weak var inviteCodeLbl: MyLabel!
    @IBOutlet weak var descLbl: MyLabel!
    @IBOutlet weak var shareBtn: MyButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let generalFunc = GeneralFunctions()
    
    var userProfileJson:NSDictionary!
    
    var cntView:UIView!
    
    var PAGE_HEIGHT:CGFloat = 405
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureRTLView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cntView = self.generalFunc.loadView(nibName: "InviteFriendsScreenDesign", uv: self, contentView: scrollView)
        self.scrollView.addSubview(cntView)
        
        self.addBackBarBtn()
        
        setData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData(){
        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)

        //Marlon - Comentado item que estava com erro
        //TODO: Verificar melhor método para adicionar titulo ao NavigationItem
//        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INVITE_FRIEND_TXT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INVITE_FRIEND_TXT")
        
//        self.descLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INVITE_FRIEND_SHARE_TXT")
        
        self.descLbl.text = self.userProfileJson.get("INVITE_DESCRIPTION_CONTENT")
        
        
        self.shareHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INVITE_FRIEND_SHARE")
        
        self.shareBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INVITE_FRIEND_TXT"))
        self.inviteCodeLbl.text = userProfileJson.get("vRefCode")
        
        self.shareBtn.clickDelegate = self
        
        self.descLbl.fitText()
        
        var descTxtHeight = descLbl.text!.height(withConstrainedWidth: Application.screenSize.width - 20, font: UIFont(name: "Roboto-Light", size: 16)!) - 20
        if(descTxtHeight < 0){
            descTxtHeight = 0
        }
        PAGE_HEIGHT = PAGE_HEIGHT + descTxtHeight
        
        cntView.frame.size = CGSize(width: self.cntView.frame.width, height: PAGE_HEIGHT)
        
        self.scrollView.bounces = false
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
        
    }
    
    func myBtnTapped(sender: MyButton) {
        if(sender == self.shareBtn){
            let objectsToShare = ["\(self.userProfileJson.get("INVITE_SHARE_CONTENT"))"]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
