//
//  MasterViewController.swift
//  MyFindMyFriendApp
//
//  Created by Ming-Ta Yang on 2018/6/14.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = [Friend]() //所有朋友
    var objectsToShow = [String:Friend]() //欲顯示的朋友
    
    var showedIndexes: [Int] = [] //紀錄已動畫過的cell
    var firstShowedTime: Date?
    
    @IBAction func showDetail(_ sender: Any) {
        
        performSegue(withIdentifier: "ShowDetail", sender: self)
        
    }
    
    @IBAction func selectAllFriends(_ sender: Any) {
        
        for object in objects{
            objectsToShow[object.friendName] = object
        }
        
        tableView.reloadData()
        detailViewController?.objectsToShow = objectsToShow
        detailViewController?.configureView()
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        navigationItem.leftBarButtonItem = editButtonItem
        
        //        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //        navigationItem.rightBarButtonItem = addButton
        //
        
        
        //refresh按鈕
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData(_:)))
        navigationItem.rightBarButtonItems?.append(refreshButton)
        
        
        
        //假如是iPad就隱藏按鈕map按鈕
        if UIDevice().model == "iPad"{
            navigationItem.rightBarButtonItems?.remove(at: 0)
        }
        
        //找出detailViewController供控制
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        //假如有登入就不提供回到登入頁面的按鈕
        if username != "" {
            //            let item = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
            //            navigationItem.leftBarButtonItem = item
            navigationItem.leftItemsSupplementBackButton = false
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //refresh方法
    @objc
    func refreshData(_ sender: Any) {
        
        //從server取得資料
        let urlString = "http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=cp101"
        
        guard let url = URL(string: urlString) else {
            assertionFailure("Fail to convert url")
            return
        }
        
        let locationDownloader = LocationDownloader(jsonURL: url)
        
        locationDownloader.download { (error, results) in
            //假如有下載錯誤
            if let error = error {
                
                //如果是因主動取消而產生的錯誤就不提示
                guard error.localizedDescription != "cancelled" else {
                    return
                }
                
                print("try print error: \(error)")
                let alertController = UIAlertController(title: "目前無法取得好友清單", message: error.localizedDescription
                    , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
                
            }
            
            guard let results = results else {
                
                assertionFailure("results are nil!")
                return
                
            }
            
            guard let friends = results.friends else {
                
                assertionFailure("friends are nil!")
                return
                
            }
            
            //清空舊資料(有收到新資料才清空舊資料)
            self.objects.removeAll()
            let keys = self.objectsToShow.keys //紀錄勾選要顯示的名稱
            self.objectsToShow.removeAll()
            
            guard friends.count != 0 else{
                
                let alertController = UIAlertController(title: "目前無好友資料", message: nil
                    , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            
            var friendNames = [String]()
            
            for friend in friends{
                
                //若是經緯度不合格式就不加入
                guard Double(friend.lat) != nil , Double(friend.lon) != nil else {
                    print("FriendName: \(friend.friendName) has illegal coordinate format")
                    continue
                }
                
                //若是自己就不加入
                if friend.friendName == username {
                    continue
                }
                
                self.objects.append(friend)
                friendNames.append(friend.friendName)
                
                //                //把上次已勾選的位置再次重新加回去
                //                for key in keys {
                //
                //                    if key == friend.friendName{
                //
                //                        self.objectsToShow[key] = friend
                //                    }
                //
                //                }
                
                self.firstShowedTime = nil
                self.showedIndexes = [] //清空紀錄已動畫過的cell
                self.tableView.reloadData()
                //                self.tableView
                //                self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .left)
                
                
                self.detailViewController?.objectsToShow = self.objectsToShow
                self.detailViewController?.configureView()
                
            }
            
        }
        
        
        
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            
            //傳送資料
            controller.objectsToShow = objectsToShow
            
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = objects[indexPath.row]
        cell.textLabel!.text = object.friendName
        cell.detailTextLabel?.text = "Last Update Time: \(object.lastUpdateDateTime)"
        if objectsToShow[objects[indexPath.row].friendName] == nil {
            cell.accessoryType = .none
        }else{
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        //假如已勾選就移除，並更新detail畫面
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
            objectsToShow[objects[indexPath.row].friendName] = nil
            detailViewController?.objectToRemove = objects[indexPath.row]
            
        } else {   //假如未勾選就新增，並更新detail畫面
            cell?.accessoryType = .checkmark
            objectsToShow[objects[indexPath.row].friendName] = objects[indexPath.row]
            detailViewController?.objectToAdd = objects[indexPath.row]
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        //幫cell增加動畫(以indexPath.row決定延遲時間)
        if (showedIndexes.contains(indexPath.row) == false) {

            if firstShowedTime == nil{
                firstShowedTime = Date()
                let b = tableView.visibleCells.count
//                print(b)
            }

            showedIndexes.append(indexPath.row)
            print(indexPath)

            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: tableView.frame.width, y: 0)
            cell.alpha = 0

            let c = Date().timeIntervalSince(firstShowedTime!)

            var a = Double(indexPath.row) / 5 - c

            var duration = 0.5

            if a < 0 {
                a = -a
            }


            UIView.animate(withDuration: duration, delay: TimeInterval(a), options:[.curveEaseIn, .transitionFlipFromRight], animations: {

                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1

//                print("a: \(a)")
//                print("c: \(c)")
                print("indexPath: \(indexPath.row)")
                print("cell: \(cell)")

            }, completion: nil)

            }



    }
    

    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,     forRowAtIndexPath indexPath: NSIndexPath) {
//
//        let trans = CATransform3DMakeTranslation(-cell.frame.size.width, 0.0, 0.0)
//        cell.layer.transform = trans
//
//        UIView.beginAnimations("Move", context: nil)
//        UIView.setAnimationDuration(0.3)
//        UIView.setAnimationDelay(0.1 * Double(indexPath.row))
//        cell.layer.transform = CATransform3DIdentity
//        UIView.commitAnimations()
//    }

    
    
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //            objects.remove(at: indexPath.row)
    //            tableView.deleteRows(at: [indexPath], with: .fade)
    //        } else if editingStyle == .insert {
    //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    //        }
    //    }
    
    
}

