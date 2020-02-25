//
//  ExeServerUrl.swift
//  DriverApp
//
//  Created by ADMIN on 24/12/16.
//  Copyright © 2016 BBCS. All rights reserved.
//

import UIKit
import NBMaterialDialogIOS
import Alamofire
/**
 This class will communicate to server and pass required data to server and fetch response from server and then pass response in the format of string to caller in completion handler.
 */
class ExeServerUrl: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    /**
     Response of webservice is passed to this handler.
     */
    typealias CompletionHandler = (_ response:String) -> Void
    
    /**
     Post parameters which are going to be pass to server. This will only applies to post connection made for application's server.
     */
    var dict_data:[String: String]?
    
    /**
     If set to true (defaults true), a loader is shown in a particular view.
     */
    var isOpenLoader = true
    
    /**
     Instance of loading dialog.
     */
    var loadingDialog:NBMaterialLoadingDialog!
    
    /**
     Instance of view hoalder for loading dialog.
     */
    var currentView:UIView!
    
    /**
     If set to true (defaults true), registration token (Used for push notification) will be generated and will be include in post parameters.
     */
    var isDeviceTokenGenerate = false
    
    /**
     This will holds post parameters. Internal purpose only.
     */
    var currentPostString = ""
    
    /**
     This will holds Response handler. Internal purpose only.
     */
    var currCompletionHandler:CompletionHandler!
    
    /**
     This will holds current instance of post/get request. If variable 'isDeviceTokenGenerate' set to true then this must be supplied.
     */
    var currInstance:ExeServerUrl!
    
    /**
     This will holds current URL session task. Internal purpose only. By using this, we can cancel on going task.
     */
    var currentTask:URLSessionDataTask!
    
    /**
     Indicates that current task is killed or not (default set to false). If set to true then instance of request will not dispatch request to CompletionHandler.
     */
    var isTaskKilled = false
    
    var request: DataRequest?
    
    /**
     A constructor - used when initializing a class
     - parameters:
     - dict_data: Key value pair Disctionary to be sent to server (Needs only when making a request to webservice of current application).
     - currentView: View that holds loader.
     - isOpenLoader: Show Loading indictor or not for current request. This must be false if request is called from frequent task. Because frequent task           is performed in background without user interaction.
     - isDeviceTokenGenerate: Pass true if device token (Registration id - to be used for push notification) to generate for request or not. If true is pass then **currInstance* variable must be set.
     */
    init(dict_data: [String: String], currentView:UIView, isOpenLoader:Bool) {
        self.dict_data = dict_data
        self.isOpenLoader = isOpenLoader
        self.currentView = currentView
        super.init()
    }
    
    /**
     A constructor - used when initializing a class
     - parameters:
     - dict_data: Key value pair Disctionary to be sent to server (Needs only when making a request to webservice of current application).
     - currentView: View that holds loader.
     - isOpenLoader: Show Loading indictor or not for current request. This must be false if request is called from frequent task. Because frequent task           is performed in background without user interaction.
     - isDeviceTokenGenerate: Pass true if device token (Registration id - to be used for push notification) to generate for request or not. If true is pass then **currInstance* variable must be set.
     */
    init(dict_data: [String: String], currentView:UIView, isOpenLoader:Bool, isDeviceTokenGenerate:Bool) {
        self.dict_data = dict_data
        self.isOpenLoader = isOpenLoader
        self.currentView = currentView
        self.isDeviceTokenGenerate = isDeviceTokenGenerate
        super.init()
    }
    
    /**
     A constructor - used when initializing a class
     - parameters:
     - dict_data: Key value pair Disctionary to be sent to server (Needs only when making a request to webservice of current application).
     - currentView: View that holds loader.
     */
    init(dict_data: [String:String], currentView:UIView) {
        self.dict_data = dict_data
        self.currentView = currentView
        super.init()
    }
    
    /**
     This will set true/false value to variable 'isDeviceTokenGenerate'.
     - Parameters:
     - isDeviceTokenGenerate: If set to true (defaults true), registration token (Used for push notification) will be generated and will be include in post parameters.
     */
    func setDeviceTokenGenerate(isDeviceTokenGenerate:Bool){
        self.isDeviceTokenGenerate = isDeviceTokenGenerate
    }
    
    /**
     This will create a post connection to application's server.
     - Parameters:
     - completionHandler: Response of current request is dispatched to this handler.
     */
    func executePostProcess(completionHandler: @escaping CompletionHandler) {
        
        if(isDeviceTokenGenerate == true){
            GeneralFunctions.registerRemoteNotification()
        }
        
        self.appendGenarlParameters()
        
        if(isOpenLoader && currentView != nil){
            DispatchQueue.main.async() {
                /**
                 Create and show loader for this request.
                 */
                self.loadingDialog = NBMaterialLoadingDialog.showLoadingDialogWithText(self.currentView, message: (GeneralFunctions()).getLanguageLabel(origValue: "Loading", key: "LBL_LOADING_TXT"))
            }
        }
        request = Alamofire.request(CommonUtils.webservice_path, method: .post, parameters: dict_data).responseString { (response) in
            DispatchQueue.main.async() {
                if(self.loadingDialog != nil){
                    self.loadingDialog.hideDialog()
                }
            }
            completionHandler(response.result.value != nil ? response.result.value! : "")
        }
        
        //        let exeServerTask = ExeServerTask.init(dict_data, currentView: self.currentView, isOpenLoader:self.isOpenLoader, url:CommonUtils.webservice_path, appColor: UIColor.UCAColor.AppThemeColor)
        //
        //        exeServerTask?.executePostProcess({ (response) in
        //            DispatchQueue.main.async() {
        //                if(self.loadingDialog != nil){
        //                    self.loadingDialog.hideDialog()
        //                }
        //            }
        //            completionHandler(response!)
        //        })
        
    }
    
    
    /**
     This will create a get request to particular url. All direct url like calling google's direction api etc must use this function.
     - Parameters:
     - completionHandler: Response of current request will be passed to this handler.
     - url: Request url from which data needs.
     */
    func executeGetProcess(completionHandler: @escaping CompletionHandler, url:String) {
        
        self.appendGenarlParameters()
        
        if(isOpenLoader && currentView != nil){
            DispatchQueue.main.async() {
                /**
                 Create and show loader for this request.
                 */
                self.loadingDialog = NBMaterialLoadingDialog.showLoadingDialogWithText(self.currentView, message: (GeneralFunctions()).getLanguageLabel(origValue: "Loading", key: "LBL_LOADING_TXT"))
            }
        }
        
        let urlEncoded = url.replacingOccurrences(of: " ", with: "%20")
        request = Alamofire.request(urlEncoded).responseJSON(completionHandler: { (response) in
            let resp = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)! as String
            
            DispatchQueue.main.async() {
                if(self.loadingDialog != nil){
                    self.loadingDialog.hideDialog()
                }
            }
            
            completionHandler(resp)
        })
        
    }
    
    /**
     By using this fuction, we are able to upload image or any file as multipart data along with parameters to server.
     - Parameters:
     - fileData: instance of data which needs to be uploaded on server.
     - completionHandler: Response of current request will be passed to this handler.
     */
    func uploadImage(image:UIImage, completionHandler: @escaping CompletionHandler){
        let boundary = GeneralFunctions.generateBoundaryString()
        
        let request = NSMutableURLRequest(url: NSURL(string: CommonUtils.webservice_path)! as URL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = image.jpegData(compressionQuality: 0.8)
        
        if(imageData==nil)  {
            DispatchQueue.main.async() {
                completionHandler("")
            }
            return
        }
        
        /**
         A general parameters that needs to be pass along with existing parameters.
         */
        dict_data?["tSessionId"] = "\(GeneralFunctions.getSessionId())"
        dict_data?["GeneralMemberId"] = "\(GeneralFunctions.getMemberd())"
        dict_data?["GeneralUserType"] = "\(Utils.appUserType)"
        dict_data?["GeneralDeviceType"] = "\(Utils.deviceType)"
        dict_data?["GeneralAppVersion"] = "\(Utils.applicationVersion())"
        dict_data?["vTimeZone"] = "\(DateFormatter().timeZone.identifier)"
        dict_data?["IS_DEBUG_MODE"] = "\(Configurations.isDevelopmentMode() == true ? "Yes" : "No")"
        
        request.httpBody = GeneralFunctions.createBodyWithParameters(dict_data, filePathKey: "vImage", imageDataKey: imageData!, boundary: boundary)
        
        if(isOpenLoader && currentView != nil){
            DispatchQueue.main.async() {
                /**
                 Create and show loader for this request.
                 */
                self.loadingDialog = NBMaterialLoadingDialog.showLoadingDialogWithText(self.currentView, message: (GeneralFunctions()).getLanguageLabel(origValue: "Loading", key: "LBL_LOADING_TXT"))
                
            }
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            var dataString = ""
            
            if(data == nil){
                dataString = ""
            }else{
                dataString =  String(data: data!, encoding: String.Encoding.utf8)!
            }
            
            DispatchQueue.main.async() {
                if(self.loadingDialog != nil){
                    self.loadingDialog.hideDialog()
                }
                completionHandler(dataString.trim())
            }
            
        })
        
        task.resume()
        
        self.currentTask = task
    }
    //TODO: Descomentar as rotinas que utilizam a classe ExeServerTask após testes
    /**
     This function will cancel current request. If called then current request will not dispatche its response.
     */
    func cancel(){
        //        print(dict_data)
        //        let exeServerTask = ExeServerTask.init(dict_data, currentView: self.currentView, isOpenLoader:self.isOpenLoader,
        //            url:CommonUtils.webservice_path, appColor: UIColor.UCAColor.AppThemeColor)
        //        exeServerTask?.cancel()
        if request != nil {
            request!.cancel()
        }
    }
    
    func appendGenarlParameters(){
        /**
         A general parameters that needs to be pass along with existing parameters.
         */
        dict_data?["tSessionId"] = "\(GeneralFunctions.getSessionId())"
        dict_data?["GeneralMemberId"] = "\(GeneralFunctions.getMemberd())"
        dict_data?["GeneralUserType"] = "\(Utils.appUserType)"
        dict_data?["GeneralDeviceType"] = "\(Utils.deviceType)"
        dict_data?["GeneralAppVersion"] = "\(Utils.applicationVersion())"
        dict_data?["vTimeZone"] = "\(DateFormatter().timeZone.identifier)"
        dict_data?["IS_DEBUG_MODE"] = "\(Configurations.isDevelopmentMode() == true ? "Yes" : "No")"
    }
}
