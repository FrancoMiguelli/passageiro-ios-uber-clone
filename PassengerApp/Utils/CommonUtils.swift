//
//  CommonUtils.swift
//  Admin
//
//  Created by Chirag on 08/12/15.
//  Copyright © 2015 ESW.   All rights reserved.


import UIKit

class CommonUtils {
    
    static let appleAppId = "23F4T7C6HC"
    

      //  static let webServer: String = "http://webprojectsdemo.com/projects/homodriver/"
//    static var webservice_path: String = "\(webServer)webservice.php";

    static let webServer: String = "https://www.ubbom.com.br/"
    static var webservice_path: String = "\(webServer)webservice_bepay.php";
    //https://www.homodriver.com/webservice_bepay.php/vLang=PT&GeneralUserType=Passenger&IS_DEBUG_MODE=Yes&UserType=Passenger&tSessionId=&AppVersion=1.0&GeneralMemberId=&type=generalConfigData&GeneralDeviceType=Ios&vTimeZone=America/Sao_Paulo&GeneralAppVersion=1.0&Platform=IOS

    static let google_geoCode_url: String = "https://maps.googleapis.com/maps/api/geocode/json"
    static let google_direction_url: String = "https://maps.googleapis.com/maps/api/directions/json"
    static let app_user_name = "Passenger"
    
    static let user_image_url = "\(webServer)webimages/upload/Passenger/"
    static let driver_image_url = "\(webServer)webimages/upload/Driver/"
}
