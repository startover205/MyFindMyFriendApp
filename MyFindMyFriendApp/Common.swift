//
//  Common.swift
//  MyFindMyFriendApp
//
//  Created by Ming-Ta Yang on 2018/6/25.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

var isUpdateLocationOn = false
var username = ""

func turnOnLocationUpdate(sender:UIViewController) -> Bool {
    
    //要有定位權限才能打開回報
    guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse else{
        let alertController = UIAlertController(title: "目前無法分享您的位置", message: "請於\"設定\"確認是否同意App取用定位服務", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        sender.present(alertController, animated: true, completion: nil)
        return false
    }
    
    //要先登入才能打開回報
    guard username != "" else {
        let alertController = UIAlertController(title: "目前無法分享您的位置", message: "需要請您先輸入使用者名稱", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        sender.present(alertController, animated: true, completion: nil)
        return false
        
    }
    
    isUpdateLocationOn = true
    return true
    
}

