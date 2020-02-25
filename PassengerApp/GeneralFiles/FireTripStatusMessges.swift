//
//  FireTripStatusMessges.swift
//  PassengerApp
//
//  Created by Tarwinder Singh on 18/12/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class FireTripStatusMessges: NSObject {
    
    let generalFunc = GeneralFunctions()
    
    var mainScreenUv:MainScreenUV!
    var ufxHomeScreenUv:UFXHomeUV!
    
    
    func fireTripMsg(_ messageStr:String, _ isGenerateLocalNotification:Bool){
        
        let result = messageStr.getJsonDataDict()
        
        if(result.count != 0){
            let isMsgExist = GeneralFunctions.isTripStatusMsgExist(result, isGenerateLocalNotification)
            
//            Utils.printLog(msgData: "isMsgExist:\(isMsgExist)")
            if(isMsgExist == true){
                return
            }
            
            var viewController = Application.window != nil ? (Application.window!.rootViewController != nil ? (Application.window!.rootViewController!) : nil) : nil
            
            if(viewController != nil){
                viewController = GeneralFunctions.getVisibleViewController(viewController, isCheckAll: true)
            }
            
//            Utils.printLog(msgData: "viewController:::\(String(describing: viewController))")
            
            if(viewController != nil && viewController!.isKind(of: MainScreenUV.self)){
                self.mainScreenUv = (viewController as! MainScreenUV)
            }else if(viewController != nil && viewController!.navigationController != nil){
                for i in 0..<viewController!.navigationController!.viewControllers.count{
                    let currentViewCOntroller = viewController!.navigationController!.viewControllers[i]
                    
                    if(currentViewCOntroller.isKind(of: MainScreenUV.self)){
                        self.mainScreenUv = (currentViewCOntroller as! MainScreenUV)
                       
                        break
                    }
                }
            }
           
            if(viewController?.navigationController != nil && viewController?.navigationController!.viewControllers.count == 1){
//                viewController = nil
            }
            
            let msg_str = result.get("Message")
            let msg_pub_str = result.get("MsgType")
            
            if(msg_pub_str != "" && msg_pub_str == "CHAT"){
                
                if(Application.window != nil && Application.window?.rootViewController != nil){
                    if(GeneralFunctions.getVisibleViewController(Application.window!.rootViewController) != nil && String(describing: GeneralFunctions.getVisibleViewController(Application.window!.rootViewController)!) != "ChatUV"){
                        let receiverName = result.get("FromMemberName")
                        let receiverId = result.get("iFromMemberId")
                        let tripId = result.get("iTripId")
                        let fromMemberImageName = result.get("FromMemberImageName")
                        
                        let chatUv = GeneralFunctions.instantiateViewController(pageName: "ChatUV") as! ChatUV
                        chatUv.receiverId = receiverId
                        chatUv.receiverDisplayName = receiverName
                        chatUv.assignedtripId = tripId
                        chatUv.pPicName = fromMemberImageName
                        
                        Application.window!.rootViewController?.pushToNavController(uv: chatUv, isDirect: true)
                        
                        return
                    }
                }
                return
            }
            
            let eType = result.get("eType")
            var contentMsg = result.get("vTitle")
            let driverName = result.get("driverName")
            let vRideNo = result.get("vRideNo")
            let iTripId = result.get("iTripId")
            
            if(msg_pub_str == "LocationUpdate"){
                let iDriverId = result.get("iDriverId")
                let vLatitude = result.get("vLatitude")
                let vLongitude = result.get("vLongitude")
                
                DispatchQueue.main.async {
                    self.mainScreenUv?.updateDriverLocationBeforeTrip(iDriverId: iDriverId, latitude: vLatitude, longitude: vLongitude, dataDict: result)
                }
                
            }else if(msg_pub_str == "TripRequestCancel"){
                self.mainScreenUv?.incCountOfRequestToDriver()
                
            }else if(msg_pub_str == "LocationUpdateOnTrip"){
                let iDriverId = result.get("iDriverId")
                let vLatitude = result.get("vLatitude")
                let vLongitude = result.get("vLongitude")
                
                if(self.mainScreenUv != nil){
                    DispatchQueue.main.async {
                        self.mainScreenUv?.updateDriverLocation(iDriverId: iDriverId, latitude: vLatitude, longitude: vLongitude, dataDict: result)
                    }
                }
                
            }else if(msg_pub_str == "DriverArrived"){
                
                if(contentMsg == ""){
                    if(eType == Utils.cabGeneralType_Ride){
                        contentMsg = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DRIVER_ARRIVED_TXT")
                    }else{
                        contentMsg = "\(generalFunc.getLanguageLabel(origValue: "", key: "LBL_DELIVERY_DRIVER_TXT")) \(driverName)  \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DRIVER_ARRIVED_NOTIMSG")) \(vRideNo)"
                    }
                }
                //                (self.mainScreenUv == nil ? (self.myOnGoingTripDetailsUv == nil ? self.ufxHomeScreenUv : self.myOnGoingTripDetailsUv) : self.mainScreenUv)
                self.generalFunc.setAlertMessage(uv: viewController, title: "", content: contentMsg, positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                    
                })
                
                if(self.mainScreenUv != nil){
                    DispatchQueue.main.async {
                        self.mainScreenUv?.setDriverArrivedStatus()
                    }
                }
                
            }else if(msg_str != ""){
                
                if(msg_str == "TripStarted"){
                    if(contentMsg == ""){
                        if(eType == Utils.cabGeneralType_Ride){
                            contentMsg = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_START_TRIP_DIALOG_TXT")
                        }else{
                            contentMsg = "\(generalFunc.getLanguageLabel(origValue: "", key: "LBL_DELIVERY_DRIVER_TXT")) \(driverName)  \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DRIVER_START_NOTIMSG")) \(vRideNo)"
                        }
                    }
                    //               (self.mainScreenUv == nil ? (self.myOnGoingTripDetailsUv == nil ? self.ufxHomeScreenUv : self.myOnGoingTripDetailsUv) : self.mainScreenUv)
                    self.generalFunc.setError(uv: viewController, title: "", content:  contentMsg)
                    
                }else if(msg_str == "TripCancelledByDriver" || msg_str == "TripEnd"){
                    if(contentMsg == ""){
                        
                        if(msg_str == "TripCancelledByDriver"){
                            contentMsg = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PREFIX_TRIP_CANCEL_DRIVER")) \(result.get("Reason")) \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TRIP_BY_DRIVER_MSG_SUFFIX"))"
                        }else{
                            if(eType == Utils.cabGeneralType_Ride){
                                contentMsg = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_END_TRIP_DIALOG_TXT")
                            }else{
                                contentMsg = "\(driverName) \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DRIVER_END_NOTIMSG")) \(vRideNo)"
                            }
                        }
                    }
                    
                    GeneralFunctions.postNotificationSignal(key: ConfigPubNub.removeInst_key, obj: self)
                    GeneralFunctions.postNotificationSignal(key: Utils.releaseAllTaskObserverKey, obj: self)
                    GeneralFunctions.postNotificationSignal(key: ConfigSCConnection.removeSCInst_key, obj: self)
                    
                    viewController = nil
                    
                    Utils.printLog(msgData: "viewController:TripEnd:\(String(describing: viewController))")
                    
                    //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConfigPubNub.TRIP_COMPLETE_NOTI_OBSERVER_KEY), object: self, userInfo: ["body":String(describing: result.convertToJson())])
                    
                    self.generalFunc.setAlertMessage(uv: viewController, title: "", content: contentMsg, positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                        
                        let window = Application.window
                        //                        (self.mainScreenUv == nil ? (self.myOnGoingTripDetailsUv == nil ? self.ufxHomeScreenUv : self.myOnGoingTripDetailsUv) : self.mainScreenUv)
                        let getUserData = GetUserData(uv: viewController, window: window!)
                        getUserData.getdata()
                    })
                    return
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Utils.driverCallBackNotificationKey), object: self, userInfo: ["body":String(describing: result.convertToJson())])
            }
        }else if(messageStr.trim() != ""){
            if(Application.window != nil && Application.window?.rootViewController != nil ){
                //&& Utils.isMyAppInBackground() == false
                (GeneralFunctions()).setError(uv: Application.window!.rootViewController!, title: "", content: messageStr)
            }
        }
        
    }
}
