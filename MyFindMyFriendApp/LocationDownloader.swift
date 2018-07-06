//
//  LocationDownloader.swift
//  MyFindMyFriendApp
//
//  Created by Ming-Ta Yang on 2018/6/14.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import Foundation
import CoreLocation

struct PropertyKeysForLocationDownloader {
    static let currentTask = "currentTask"
}


struct JsonFriend: Codable {
    var errorCode:String? = ""
    var result:Bool? = false
    var friends: [Friend]?
    
}


struct Friend: Codable {
    var id: String = ""
    var friendName:String = ""
    var lat: String = ""
    var lon: String = ""
    var lastUpdateDateTime: String = ""
    
}

typealias LocationDownloadHandler = (Error?, JsonFriend?) -> Void

class LocationDownloader{
    
    static var currentTask = [String:URLSessionDataTask]()
    
    let targetURL: URL
    init(jsonURL: URL) {
        targetURL = jsonURL
    }
    
    func download(doneHandler: @escaping LocationDownloadHandler){
        
        
        if let previousTask = LocationDownloader.currentTask[PropertyKeysForLocationDownloader.currentTask] {
            
            previousTask.cancel()
            LocationDownloader.currentTask[PropertyKeysForLocationDownloader.currentTask] = nil
            print("A task is removed!")
            
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: targetURL) { (data, response, error) in
            
            if let error = error {
                
                print("Download Fail: \(error)")
                DispatchQueue.main.async {
                    doneHandler(error, nil)
                }
                return
                
                
            }
            
            guard let data = data else{
                
                print("Data is nil")
                let error = NSError(domain: "Data is nil", code: -1, userInfo: nil)
                DispatchQueue.main.async {
                    doneHandler(error, nil)
                }
                return
                
                
            }
            
            let decoder = JSONDecoder()
            
            var results:JsonFriend?
            
            do{
                
                results = try decoder.decode(JsonFriend.self, from: data)
                
            }catch{
                
                print("JSON Parse Error catched! Error message: \(error)")
            }
            
            if let results = results{
                
                DispatchQueue.main.async {
                    doneHandler(nil, results)
                }
                
                
            }else{
                
                let error = NSError(domain: "Results are nil", code: -1, userInfo: nil)
                DispatchQueue.main.async {
                    doneHandler(error, nil)
                    return
                    
                }
                
            }
            
            //工作完成，刪除currentTask
            LocationDownloader.currentTask[PropertyKeysForLocationDownloader.currentTask] = nil

        }
        
        task.resume()
        LocationDownloader.currentTask[PropertyKeysForLocationDownloader.currentTask] = task
        
        
    }
    
}

