//
//  CoreDataManager.swift
//  MyFindMyFriendApp
//
//  Created by Ming-Ta Yang on 2018/6/28.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import CoreData
import CoreLocation
import UIKit

class CoreDataManager{

    struct EntityKey{
        static let lat = "lat"
        static let lon = "lon"
        static let lastUpdateTime = "lastUpdateTime"
    }
    
    static let shared = CoreDataManager()

    private init(){

    }

    //新增資料
    func storeLocations(_ coordinate:CLLocationCoordinate2D){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ //先取出appDelegate
            print("fail to get appDelegate")
            return
        }
        let pastLocation = PastLocationMO(context: appDelegate.persistentContainer.viewContext) //使用context創造物件
        pastLocation.lat = coordinate.latitude
        pastLocation.lon = coordinate.longitude
        pastLocation.lastUpdateTime = Date()
        
        appDelegate.saveContext() //最後存檔
        
    }
    
    //修改資料
//    ...
    
    
    //查詢資料
    func fetchPastLocations() -> [PastLocationMO]?{
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            print("fail to get appDelegate")
            return nil
        }
        
        let fetchResult:NSFetchRequest<PastLocationMO> = PastLocationMO.fetchRequest() //要創造一個NSFetchRequest物件用來指定要抓的資料型別
        let sortDescriptor = NSSortDescriptor(key: EntityKey.lastUpdateTime, ascending: true) //用來排序資料內容，這邊以資料的時間做排序；也可以也用來篩選或比較？
        fetchResult.sortDescriptors = [sortDescriptor] //指定分類器(可以有多個)
        
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchResult, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil) //要用controller來抓取資料
//        fetchResultController.delegate = self //應該可以不使用??
        
        do {
            try fetchResultController.performFetch()
            if let fetchedObjects = fetchResultController.fetchedObjects{
                return fetchedObjects

            }
        } catch  {
            print("fetch core data error: \(error)")
        }
        
        return nil
        
    }
    
    
    //刪除資料
    func deleteLocationInCoreDate(deleteFrom:Date, To:Date){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            print("fail to get appDelegate")
            return
        }
      
        let context = appDelegate.persistentContainer.viewContext
        
        guard let fetchedObjects = fetchPastLocations() else {
            assertionFailure("Fail to fetch data when try to delete fetchObjects")
            return
        }
        
        for fetchedObject in fetchedObjects{ //符合條件的資料刪除
            guard let lastUpdateTime = fetchedObject.lastUpdateTime else {
                print("fetchedObject doesn't have \"lasUpdateTime\" attribute")
                return
            }
            
            if lastUpdateTime > deleteFrom && lastUpdateTime < To{
                
                context.delete(fetchedObject) //刪除資料
            }
            
        }
        
    }
    
}
