//
//  UpdateDirections.swift
//  DriverApp
//
//  Created by ADMIN on 27/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import GoogleMaps

@objc protocol OnDirectionUpdateDelegate:class
{
    func onDirectionUpdate(directionResultDict:NSDictionary)
}

class UpdateDirections: NSObject, OnLocationUpdateDelegate {
    
    var userLocation:CLLocation!
    var timer:Timer!
    var uv:UIViewController!
    
    var getLoc:GetLocation!
    var gMap:GMSMapView!
    
    var destinationLocation:CLLocation!
    var fromLocation:CLLocation!
    
//    var isSwapLocation = false
    
    var listOfPoints = [String()]
    
    var listOfPaths = [GMSPolyline]()
    
    let generalFunc = GeneralFunctions()
    
    var isCurrentLocationEnabled = true
    
    var onDirectionUpdateDelegate:OnDirectionUpdateDelegate!
    
    var eTollSkipped = ""
    
    var ENABLE_DIRECTION_SOURCE_DESTINATION_USER_APP = ""
    
    var DESTINATION_UPDATE_TIME_INTERVAL_value:Double = 0.0

    init(uv:UIViewController, gMap:GMSMapView, destinationLocation:CLLocation){
        self.uv = uv
        self.gMap = gMap
        self.destinationLocation = destinationLocation
        super.init()
    }
    
//    init(uv:UIViewController, gMap:GMSMapView, destinationLocation:CLLocation, isSwapLocation:Bool){
//        self.uv = uv
//        self.gMap = gMap
//        self.destinationLocation = destinationLocation
//        self.navigateView = navigateView
//        self.isSwapLocation = isSwapLocation
//        
//        super.init()
//    }
    
    init(uv:UIViewController, gMap:GMSMapView, fromLocation:CLLocation, destinationLocation:CLLocation, isCurrentLocationEnabled:Bool){
        self.uv = uv
        self.gMap = gMap
        self.fromLocation = fromLocation
        self.destinationLocation = destinationLocation
        self.isCurrentLocationEnabled = isCurrentLocationEnabled
        
        super.init()
    }
    
    func setCurrentLocEnabled(isCurrentLocationEnabled:Bool){
        self.isCurrentLocationEnabled = isCurrentLocationEnabled
    }
    
    func changeLocation(fromLocation:CLLocation, destinationLocation:CLLocation){
        self.fromLocation = fromLocation
        self.destinationLocation = destinationLocation
    }
    
    func addReleaseObserver(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Utils.releaseAllTaskObserverKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.releaseTask), name: NSNotification.Name(rawValue: Utils.releaseAllTaskObserverKey), object: nil)
    }
    func scheduleDirectionUpdate(eTollSkipped:String){
        self.eTollSkipped = eTollSkipped
        addReleaseObserver()
        if(timer != nil){
            timer!.invalidate()
        }

        ENABLE_DIRECTION_SOURCE_DESTINATION_USER_APP = GeneralFunctions.getValue(key: Utils.ENABLE_DIRECTION_SOURCE_DESTINATION_USER_APP_KEY) as! String

        let DESTINATION_UPDATE_TIME_INTERVAL = GeneralFunctions.getValue(key: "DESTINATION_UPDATE_TIME_INTERVAL")
        DESTINATION_UPDATE_TIME_INTERVAL_value = GeneralFunctions.parseDouble(origValue: 30, data: DESTINATION_UPDATE_TIME_INTERVAL == nil ? "30" : (DESTINATION_UPDATE_TIME_INTERVAL as! String)) * 60
        
        startTimer()
        
        if(isCurrentLocationEnabled){
            if(getLoc == nil){
                getLoc = GetLocation(uv: self.uv, isContinuous: true)
                getLoc.buildLocManager(locationUpdateDelegate: self)
            }else{
                getLoc.buildLocManager(locationUpdateDelegate: self)
                getLoc.resumeLocationUpdates()
            }
        }
        
    }
    
    private func startTimer(){
        if(timer != nil){
            timer!.invalidate()
            timer = nil
        }
        
       timer =  Timer.scheduledTimer(timeInterval: DESTINATION_UPDATE_TIME_INTERVAL_value, target: self, selector: #selector(updateDirections), userInfo: nil, repeats: true)
        
        timer.fire()
    }
    
    func startDirectionUpdate(){
        startTimer()
    }
    
    func pauseDirectionUpdate(){
        if(timer != nil){
            timer!.invalidate()
        }
    }
    
    func stopFrequentUpdate(){
        if(timer != nil){
            timer!.invalidate()
        }
        
        if(getLoc != nil){
            getLoc.releaseLocationTask()
            getLoc.locationUpdateDelegate = nil
        }
    }
    
    @objc func releaseTask(){
        if(timer != nil){
            timer!.invalidate()
            timer = nil
        }
        
        if(getLoc != nil){
            getLoc.releaseLocationTask()
            getLoc.locationUpdateDelegate = nil
            getLoc = nil
        }
        
        for i in 0..<self.listOfPaths.count{
            self.listOfPaths[i].map = nil
        }
        
        self.listOfPaths.removeAll()
        self.listOfPoints.removeAll()
        GeneralFunctions.removeObserver(obj: self)
    }
    
    func onLocationUpdate(location: CLLocation) {
        
        if(self.userLocation == nil){
            self.userLocation = location
            updateDirections()
        }
        self.userLocation = location
    }
    
    @objc func updateDirections(){
        
        let fromLocation = userLocation == nil ? self.fromLocation : userLocation
        let destinationLocation = self.destinationLocation
        
//        if(isSwapLocation){
//            fromLocation = destinationLocation
//            destinationLocation = userLocation == nil ? self.fromLocation : userLocation
//        }
        
        if(gMap == nil || destinationLocation == nil || fromLocation == nil || destinationLocation!.coordinate.latitude == 0.0 || destinationLocation!.coordinate.longitude == 0.0){
            return
        }
        
        if(ENABLE_DIRECTION_SOURCE_DESTINATION_USER_APP.uppercased() == "NO"){
            if(self.onDirectionUpdateDelegate != nil){
                self.onDirectionUpdateDelegate!.onDirectionUpdate(directionResultDict: NSDictionary())
            }
        }else{
            var directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(fromLocation!.coordinate.latitude),\(fromLocation!.coordinate.longitude)&destination=\(destinationLocation!.coordinate.latitude),\(destinationLocation!.coordinate.longitude)&key=\(Configurations.getGoogleServerKey())&language=\(Configurations.getGoogleMapLngCode())&sensor=true"
            
            if(eTollSkipped == "Yes"){
                directionURL = "\(directionURL)&avoid=tolls"
            }
            
            Utils.printLog(msgData: "UpdateDirection:called:\(directionURL)")
            
            let exeWebServerUrl = ExeServerUrl(dict_data: [String:String](), currentView: self.uv.view, isOpenLoader: false)
            
            exeWebServerUrl.executeGetProcess(completionHandler: { (response) -> Void in
                
                if(response != ""){
                    let dataDict = response.getJsonDataDict()
                    
                    if(dataDict.get("status").uppercased() != "OK" || dataDict.getArrObj("routes").count == 0){
                        return
                    }
                    
                    if(self.onDirectionUpdateDelegate != nil){
                        self.onDirectionUpdateDelegate!.onDirectionUpdate(directionResultDict: dataDict)
                    }
                    
                    let routesArr = dataDict.getArrObj("routes")
                    let legs_arr = (routesArr.object(at: 0) as! NSDictionary).getArrObj("legs")
                    let steps_arr = (legs_arr.object(at: 0) as! NSDictionary).getArrObj("steps")
                    //                let start_address = (legs_arr.object(at: 0) as! NSDictionary).get("start_address")
                    _ = (legs_arr.object(at: 0) as! NSDictionary).get("end_address")
                    
                    for i in 0..<self.listOfPaths.count{
                        self.listOfPaths[i].map = nil
                    }
                    self.listOfPaths.removeAll()
                    self.listOfPoints.removeAll()
                    
                    for i in 0..<steps_arr.count{
                        let polyPoints = (steps_arr.object(at: i) as! NSDictionary).getObj("polyline").get("points")
                        
                        self.listOfPoints += [polyPoints]
                        
                        self.addPolyLineWithEncodedStringInMap(encodedString: polyPoints)
                    }
                }else{
                    //                self.generalFunc.setError(uv: self)
                }
            }, url: directionURL)
        }
    }
    
    func addPolyLineWithEncodedStringInMap(encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = UIColor.black
        polyLine.map = gMap
        
        self.listOfPaths += [polyLine]
    }
}
