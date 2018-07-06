//
//  LocationUploader.swift
//  MyFindMyFriendApp
//
//  Created by Ming-Ta Yang on 2018/6/21.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//


import Foundation
import CoreLocation

struct JsonLogin: Codable {
    var result:Bool? = false
    var errorCode:String? = ""
    
}


typealias LocationUploadHandler = (Error?, JsonLogin?) -> Void

class LocationUploader{
    
    let targetURL: URL
    init(jsonURL: URL) {
        targetURL = jsonURL
    }
    
    func upload(doneHandler: @escaping LocationUploadHandler){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: targetURL) { (data, response, error) in
            
            if let error = error {
                
                print("Upload Fail: \(error)")
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
            
            var results:JsonLogin?
            
            do{
                
                results = try decoder.decode(JsonLogin.self, from: data)
                
            }catch{
                
                print("JSON Parse Error catched! Default Error message: \(error)")
            }
            
            if let results = results{
                
                DispatchQueue.main.async {
                    doneHandler(nil, results)
                }
                
                
            }else{
                
                let error = NSError(domain: "Results are nil", code: -1, userInfo: nil)
                DispatchQueue.main.async {
                    doneHandler(error, nil)
                    
                }
            }
        }
        task.resume()
        
    }
    
}

