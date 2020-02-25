//
//  ConfigPubNub.swift
//  DriverApp
//
//  Created by ADMIN on 25/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import Foundation
import CoreLocation
import PubNub
import UIKit

class ConfigPubNub: NSObject, PNObjectEventListener, OnLocationUpdateDelegate, OnTaskRunCalledDelegate{
    
    public static var instance:ConfigPubNub?
    
    static let removeInst_key = "REMOVE_PUBNUB_INST"
    static let pauseInst_key = "PAUSE_PUBNUB_INST"
    static let resumeInst_key = "RESUME_PUBNUB_INST"
    static let TRIP_COMPLETE_NOTI_OBSERVER_KEY = "TRIP_COMPLETE_NOTI_KEY"
    
    var client: PubNub!
    
    var isRetryKilled = false
    
    var iTripId = ""
    
    var iDriverId = ""
    
    var getLocation:GetLocation!
    
    var latitude = 0.0
    var longitude = 0.0
    
    var updateTripStatusFreqTask:UpdateFreqTask!
    var scheduleAppInActiveLocalNotificationTask:UpdateFreqTask!
    
    var checkTripStatus:ExeServerUrl!
    
    var isKilled = false
    var isReleased = false
    
    let generalFunc = GeneralFunctions()
    
    var userProfileJson:NSDictionary!
    
    static func getInstance() -> ConfigPubNub{
        if(instance == nil){
            instance = ConfigPubNub()
        }
        
        return instance!
    }
    
    static func getInstance(isCheck:Bool) -> ConfigPubNub?{
        return instance
    }
    
    func buildPubNub(){
        releasePubNub()
        
        let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        self.userProfileJson = userProfileJson
        
        if(userProfileJson.get("PUBNUB_DISABLED").uppercased() == "YES" && userProfileJson.get("ENABLE_SOCKET_CLUSTER").uppercased() == "YES"){
            
            ConfigSCConnection.getInstance().buildConnection()
            
            scheduleAppInActiveLocalNotificationTask = UpdateFreqTask(interval: 10)
            scheduleAppInActiveLocalNotificationTask.onTaskRunCalled = self
            scheduleAppInActiveLocalNotificationTask.currInst = scheduleAppInActiveLocalNotificationTask
            scheduleAppInActiveLocalNotificationTask.startRepeatingTask()
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.tripStatusMsgReceived(sender:)), name: NSNotification.Name(rawValue: Utils.tripMsgNotificationKey), object: nil)
            
            return
            
        }
        
        let PUBNUB_DISABLED = GeneralFunctions.getValue(key: Utils.PUBNUB_DISABLED_KEY)
        let PUBNUB_PUB_KEY = GeneralFunctions.getValue(key: Utils.PUBNUB_PUB_KEY)
        let PUBNUB_SUB_KEY = GeneralFunctions.getValue(key: Utils.PUBNUB_SUB_KEY)
        
        if(PUBNUB_DISABLED != nil && (PUBNUB_DISABLED as! String).uppercased() == "NO" && PUBNUB_PUB_KEY != nil && (PUBNUB_PUB_KEY as! String).trim() != "" && PUBNUB_SUB_KEY != nil && (PUBNUB_SUB_KEY as! String).trim() != ""){
            print(PUBNUB_PUB_KEY)
            print(PUBNUB_SUB_KEY)
            let configuration = PNConfiguration(publishKey: PUBNUB_PUB_KEY  as! String, subscribeKey: PUBNUB_SUB_KEY as! String)
            
            configuration.uuid = GeneralFunctions.getValue(key: Utils.DEVICE_SESSION_ID_KEY) == nil ? (UIDevice.current.identifierForVendor != nil ? UIDevice.current.identifierForVendor!.uuidString : GeneralFunctions.getMemberd()) : (GeneralFunctions.getValue(key: Utils.DEVICE_SESSION_ID_KEY) as! String)
            
            configuration.stripMobilePayload = false
            self.client = PubNub.clientWithConfiguration(configuration)
            self.client.addListener(self)
            
            self.client.logger.enabled = false
            
            subscribeToPrivateChannel()
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tripStatusMsgReceived(sender:)), name: NSNotification.Name(rawValue: Utils.tripMsgNotificationKey), object: nil)

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.releaseInstance), name: NSNotification.Name(rawValue: ConfigPubNub.removeInst_key), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pausePubNub), name: NSNotification.Name(rawValue: ConfigPubNub.pauseInst_key), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.resumePubNub), name: NSNotification.Name(rawValue: ConfigPubNub.resumeInst_key), object: nil)
        
        
        getLocation = GetLocation(uv: nil , isContinuous: true)
        getLocation.buildLocManager(locationUpdateDelegate: self)
        
        let FETCH_TRIP_STATUS_TIME_INTERVAL = GeneralFunctions.getValue(key: Utils.FETCH_TRIP_STATUS_TIME_INTERVAL_KEY) != nil ? (GeneralFunctions.getValue(key: Utils.FETCH_TRIP_STATUS_TIME_INTERVAL_KEY) as! String) : "15"
        
        updateTripStatusFreqTask = UpdateFreqTask(interval: GeneralFunctions.parseDouble(origValue: 15, data: FETCH_TRIP_STATUS_TIME_INTERVAL))
        updateTripStatusFreqTask.onTaskRunCalled = self
        updateTripStatusFreqTask.currInst = updateTripStatusFreqTask
        updateTripStatusFreqTask.startRepeatingTask()
    }
    
    func onTaskRun(currInst: UpdateFreqTask) {
        if(self.updateTripStatusFreqTask != nil && currInst == self.updateTripStatusFreqTask){
            getUserTripStatus()
        }
        UIControl().sendAction(Selector(("_performMemoryWarning")), to: UIApplication.shared, for: nil)
        UIControl().sendAction(Selector(("_performMemoryWarning")), to: UIApplication.shared, for: nil)
        
    }
    
    func onLocationUpdate(location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
    
    @objc func tripStatusMsgReceived(sender: NSNotification){
        let userInfo = sender.userInfo
        let msgData = (userInfo!["body"] as! String)
        
        self.dispatchMsg(result: msgData)
    }
    
    @objc func releaseInstance(){
        releasePubNub()
        if(ConfigPubNub.getInstance(isCheck: true) != nil){
            ConfigPubNub.instance = nil
        }
    }
    
    func releasePubNub(){
//        isKilled = true
        
        if(self.client != nil){
//            unSubscribeToPrivateChannel()
            self.client.unsubscribeFromAll()
            self.client.removeListener(self)
        }
        
        if(ConfigSCConnection.retrieveInstance() != nil){
            ConfigSCConnection.getInstance().forceDestroy()
        }
        
        GeneralFunctions.removeObserver(obj: self)
        
        if(self.getLocation != nil){
            self.getLocation!.locationUpdateDelegate = nil
            self.getLocation!.releaseLocationTask()
            self.getLocation = nil
        }
        
        if(self.updateTripStatusFreqTask != nil){
            self.updateTripStatusFreqTask.stopRepeatingTask()
            self.updateTripStatusFreqTask.onTaskRunCalled = nil
            self.updateTripStatusFreqTask = nil
        }
    }
    
    @objc func pausePubNub(){
        isKilled = true
    }
    
    @objc func resumePubNub(){
        if(isReleased == false){
            isKilled = false
        }
    }
    
    func getUserTripStatus(){
        if(self.isKilled == true){
            return
        }
        var parameters = ["type": "configPassengerTripStatus", "iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType]
        if(latitude != 0.0 && longitude != 0.0){
            parameters["vLatitude"] = "\(latitude)"
            parameters["vLongitude"] = "\(longitude)"
        }
        
        var callType = "NORMAL"
        
        let visibleViewController = GeneralFunctions.getVisibleViewController(nil, isCheckAll: true)
        
        if(visibleViewController != nil){
            if(visibleViewController!.isKind(of: MainScreenUV.self)){
                let mainScreenUv = visibleViewController as! MainScreenUV
                
                parameters["CurrentDriverIds"] = mainScreenUv.assignedDriverId == "" ? mainScreenUv.getAvailableDriverIds() : mainScreenUv.assignedDriverId
                parameters["iTripId"] = mainScreenUv.assignedTripId
                
                if(mainScreenUv.assignedDriverId != ""){
                    callType = "TRIP"
                }
                
            }
        }
        
        if(checkTripStatus != nil){
            checkTripStatus.cancel()
            checkTripStatus = nil
        }
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: UIView() , isOpenLoader: false)
        checkTripStatus = exeWebServerUrl

        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get(Utils.message_str) == "SESSION_OUT"){
                    if(GeneralFunctions.isAlertViewPresentOnScreenWindow(viewTag: Utils.SESSION_OUT_VIEW_TAG, coverViewTag: Utils.SESSION_OUT_COVER_VIEW_TAG) == false){
                        self.generalFunc.setAlertMessage(uv: nil, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SESSION_TIME_OUT"), content: self.generalFunc.getLanguageLabel(origValue: "Your session is expired. Please login again.", key: "LBL_SESSION_TIME_OUT"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Ok", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", viewTag: Utils.SESSION_OUT_VIEW_TAG, coverViewTag: Utils.SESSION_OUT_COVER_VIEW_TAG, completionHandler: { (btnClickedIndex) in
                            GeneralFunctions.postNotificationSignal(key: Utils.releaseAllTaskObserverKey, obj: self)
                            GeneralFunctions.postNotificationSignal(key: ConfigPubNub.removeInst_key, obj: self)
                            GeneralFunctions.postNotificationSignal(key: ConfigSCConnection.removeSCInst_key, obj: self)
                            
                            GeneralFunctions.logOutUser()
                            GeneralFunctions.restartApp(window: Application.window!)
                        })
                    }
                    return
                }
                
                if(dataDict.get("Action") == "1"){
                    
                    if(self.isKilled == false){
                        DispatchQueue.main.async {
                            self.dispatchMsg(result: dataDict.get(Utils.message_str))
                        }
                    }
                }
                
                if(dataDict.getArrObj("currentDrivers").count > 0 && self.isKilled == false){
                    let currentDriversLocArr = dataDict.getArrObj("currentDrivers")
                    
                    let PUBNUB_DISABLED = GeneralFunctions.getValue(key: Utils.PUBNUB_DISABLED_KEY) == nil ? "" : (GeneralFunctions.getValue(key: Utils.PUBNUB_DISABLED_KEY) as! String)
                    let ENABLE_SOCKET_CLUSTER = GeneralFunctions.getValue(key: Utils.ENABLE_SOCKET_CLUSTER_KEY) == nil ? "" : (GeneralFunctions.getValue(key: Utils.ENABLE_SOCKET_CLUSTER_KEY) as! String)
                    if(PUBNUB_DISABLED.uppercased() == "YES" && ENABLE_SOCKET_CLUSTER.uppercased() == "NO"){
                        DispatchQueue.main.async {
                            for i in 0..<currentDriversLocArr.count{
                                let data_temp = currentDriversLocArr[i] as! NSDictionary
                                let dictionary = ["MsgType": callType == "TRIP" ? "LocationUpdate" : "LocationUpdateOnTrip", "iDriverId": data_temp.get("iDriverId"), "ChannelName": "ONLINE_DRIVER_LOC_\(data_temp.get("iDriverId"))", "vLatitude": data_temp.get("vLatitude"),"vLongitude": data_temp.get("vLongitude"), "LocTime": "\(Utils.currentTimeMillis())"]
                                
                                
                                let js_data = (dictionary as NSDictionary).convertToJson()
                                
                                self.dispatchMsg(result: js_data)
                                
                            }
                        }
                    }
                }
                
            }
        })
    }
    
    func subscribeToPrivateChannel() {
        if(self.client != nil){
            self.client.subscribeToChannels(["PASSENGER_\(GeneralFunctions.getMemberd())"], withPresence: true)
        }
        if(ConfigSCConnection.retrieveInstance() != nil){
            ConfigSCConnection.getInstance().subscribeToChannels(channelName: "PASSENGER_\(GeneralFunctions.getMemberd())")
        }
    }
    
    func unSubscribeToPrivateChannel() {
        if(self.client != nil){
            self.client.unsubscribeFromChannels(["PASSENGER_\(GeneralFunctions.getMemberd())"], withPresence: true)
        }
        if(ConfigSCConnection.retrieveInstance() != nil){
            ConfigSCConnection.getInstance().unSubscribeFromChannels(channelName: "PASSENGER_\(GeneralFunctions.getMemberd())")
        }
    }
    
    
    
    func subscribeToChannels(channels:[String]){
//        print("Subscribe")
//        print(channels)
        if(self.client != nil){
            self.client.subscribeToChannels(channels, withPresence: false)
        }
        if(ConfigSCConnection.retrieveInstance() != nil){
            for i in 0..<channels.count{
                ConfigSCConnection.getInstance().subscribeToChannels(channelName: channels[i])
            }
        }
    }
    
    func unSubscribeToChannels(channels:[String]){
//        print("UnSubscribe")
//        print(channels)
        if(self.client != nil){
            self.client.unsubscribeFromChannels(channels, withPresence: false)
        }
        if(ConfigSCConnection.retrieveInstance() != nil){
            for i in 0..<channels.count{
                ConfigSCConnection.getInstance().unSubscribeFromChannels(channelName: channels[i])
            }
        }
    }
    
    func publishMsg(channelName:String, content:String){
//        print("Going to publish msg::\(channelName)")
        if(self.client != nil){
            self.client.publish(content, toChannel: channelName,
                                compressed: false, withCompletion: { (status) in
                                    
                                    if !status.isError {
                                        
                                        // Message successfully published to specified channel.
                                        //                                    print("Message is published:\(channelName)")
                                    }
                                    else{
                                        
                                        /**
                                         Handle message publish error. Check 'category' property to find
                                         out possible reason because of which request did fail.
                                         Review 'errorData' property (which has PNErrorData data type) of status
                                         object to get additional information about issue.
                                         
                                         Request can be resent using: status.retry()
                                         */
                                        
                                        //                                    print("Error in published:\(status.errorData)::\(channelName)")
                                        //                                    print("Error in published:\(status)")
                                    }
            })
        }
        if(ConfigSCConnection.retrieveInstance() != nil){
            ConfigSCConnection.getInstance().publishMsg(channelName: channelName, content: content)
        }
    }
    
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {

        if(message.data.message == nil){
            return
        }
        
        var result = NSDictionary()
        
        if((message.data.message! as? NSDictionary) != nil){
            result = message.data.message! as! NSDictionary
        }else if((message.data.message! as? String) != nil){
            result = (message.data.message! as! String).getJsonDataDict()
        }
        Utils.printLog(msgData: "PUBNUBMSG:\(result)")
        DispatchQueue.main.async {
            self.dispatchMsg(result: result.convertToJson())
        }
    }
    
    private func dispatchMsg(result:String){
//        Utils.printLog(msgData: "result::\(result)")
        if(self.isKilled == true){
            return
        }
        
        FireTripStatusMessges().fireTripMsg(result, true)
    }
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        if status.operation == .subscribeOperation {
            
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                
                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
                if subscribeStatus.category == .PNConnectedCategory {
                    
                }
                else {
                    
                    /**
                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
                     an error but there is no longer any issue.
                     */
                }
                
            }
            else if status.category == .PNUnexpectedDisconnectCategory {
                
                /**
                 This is usually an issue with the internet connection, this is an error, handle
                 appropriately retry will be called automatically.
                 */
                
                isRetryKilled = false
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    status.retry()
                })
                
//                print("PubNub disconnected")
            }
                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
                // network.
            else {
                
                let errorStatus: PNErrorStatus = status as! PNErrorStatus
                if errorStatus.category == .PNAccessDeniedCategory {
                    
                    /**
                     This means that PAM does allow this client to subscribe to this channel and channel group
                     configuration. This is another explicit error.
                     */
                }
                else {
                    
                    /**
                     More errors can be directly specified by creating explicit cases for other error categories
                     of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                     `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                     or `PNNetworkIssuesCategory`
                     */
                    isRetryKilled = false
                }
            }
        }
    }
}
