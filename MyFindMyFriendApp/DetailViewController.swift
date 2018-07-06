//
//  DetailViewController.swift
//  MyFindMyFriendApp
//
//  Created by Ming-Ta Yang on 2018/6/14.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData


class DetailViewController: UIViewController {
    let coreDataManager = CoreDataManager.shared
    
    struct PropertyKey {
        
        //設定走多遠更新一次位置
        static let distanceFilter = 10.0
        
        //設定軌跡樣式
        static let strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        static let strokeWidth:CGFloat = 3.0
        
    }
    
    let locationManager = CLLocationManager()
    var coordinatesToShow = [CLLocationCoordinate2D]()
    
    @IBOutlet weak var mainMapView: MKMapView!
    
    @IBOutlet weak var isUpdateLocationOnStateButton: UIButton!
    @IBAction func changeLocationUpdateState(_ sender: UIButton) {
        
        if isUpdateLocationOn{
            let alertController = UIAlertController(title: "將會停止分享您的位置", message: "您確定要這麼做嗎？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .default){ (_) in
                isUpdateLocationOn = !isUpdateLocationOn
                self.toggleUpdateLocationButton()
                return
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                return
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            
            if turnOnLocationUpdate(sender: self){
                toggleUpdateLocationButton()
            }
        }
    }
    
    
    //更新全部annotation
    func configureView() {
        
        guard let mapView = mainMapView else{
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        for object in objectsToShow {
            
            let annotation = MKPointAnnotation()
            guard let lat = Double(object.value.lat),let lon = Double(object.value.lon) else {
                
                assertionFailure("Illegal coordinate format")
                continue
                
            }
            let coordinate = CLLocationCoordinate2DMake(lat, lon)
            annotation.coordinate = coordinate
            annotation.title = object.value.friendName
            
            mapView.addAnnotation(annotation)
            
        }
        
    }
    
    //新增單一annotation
    func addAnnotation(friend:Friend){
        
        let annotation = MKPointAnnotation()
        guard let lat = Double(friend.lat),let lon = Double(friend.lon) else {
            
            assertionFailure("Illegal coordinate format")
            return
        }
        let coordinate = CLLocationCoordinate2DMake(lat, lon)
        annotation.coordinate = coordinate
        annotation.title = friend.friendName
        
        guard let mapView = mainMapView else{
            return
        }
        
        mapView.addAnnotation(annotation)
        
    }
    
    //移除單一annotation
    func removeAnnotation(friend:Friend){
        
        guard let mapView = mainMapView else{
            return
        }
        
        for annotation in mapView.annotations{
            
            if annotation.title == friend.friendName{
                mapView.removeAnnotation(annotation)
                return
            }
            
        }
        
    }
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //檢查定位權限
        locationManager.requestAlwaysAuthorization()
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        //定位按鈕顏色改變
        toggleUpdateLocationButton()
        
        //監聽回報定位的開啟關閉
        NotificationCenter.default.addObserver(self, selector: #selector(toggleUpdateLocationButton), name: Notification.Name.isUpdateLocationOnDidChange, object: nil)
        
        
        //        guard CLLocationManager.locationServicesEnabled() else {
        //            let alertController = UIAlertController(title: "請確認定位服務是否已開啟", message: "需要開啟定位服務以顯示您的位置在地圖上", preferredStyle: .alert)
        //            let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        //            alertController.addAction(okAction)
        //            self.present(alertController, animated: true, completion: nil)
        //            return
        //        }
        
        //繪製移動軌跡所需
        mainMapView.delegate = self
        
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = PropertyKey.distanceFilter
        locationManager.startUpdatingLocation()
        
        //顯示大頭針
        configureView()
        
        //刪除上次紀錄
        coreDataManager.deleteLocationInCoreDate(deleteFrom: Date(timeIntervalSince1970: 0), To: Date())
        
        mainMapView.userTrackingMode = .follow
        
    }
    
    @objc
    func toggleUpdateLocationButton(){
        if isUpdateLocationOn{
            isUpdateLocationOnStateButton.setImage(#imageLiteral(resourceName: "btn_radio_blue"), for: .normal)
        }else{
            isUpdateLocationOnStateButton.setImage(#imageLiteral(resourceName: "btn_radio_gray"), for: .normal)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var detailItem: Friend? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var objectsToShow = [String:Friend](){
        
        didSet{
            //            configureView()
        }
    }
    
    var objectToAdd: Friend?{
        
        didSet{
            if let objectToAdd = objectToAdd{
                addAnnotation(friend: objectToAdd)
                objectsToShow[objectToAdd.friendName] = objectToAdd
            }
        }
    }
    
    var objectToRemove: Friend?{
        
        didSet{
            if let objectToRemove = objectToRemove{
                removeAnnotation(friend: objectToRemove)
                objectsToShow[objectToRemove.friendName] = objectToRemove
                
            }
        }
    }
    
    
    
    
    
    
}

extension DetailViewController:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        //假如第一次定位權限沒開，就顯示提示
        if status != .authorizedAlways && status != .authorizedWhenInUse   {
            let alertController = UIAlertController(title: "提醒您，目前定位權限尚未開啟", message: "若看不到您在地圖上的位置，請於\"設定\"修改App取用定位服務的權限", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard isUpdateLocationOn else{
            return
        }
        
        //上傳自己的位置
        guard !username.isEmpty else{
            return
        }
        guard let coordinate = locations.first?.coordinate else{
            assertionFailure("Updating Location failed with nil location")
            return
        }
        
        let urlString = "http://class.softarts.cc/FindMyFriends/updateUserLocation.php?GroupName=cp101&UserName=\(username)&Lat=\(coordinate.latitude)&Lon=\(coordinate.longitude)"
        guard let url = URL(string: urlString) else {
            assertionFailure("Fail to convert upload-url")
            return
        }
        let locationUploader = LocationDownloader(jsonURL: url)
        locationUploader.download { (error, results) in
            if let error = error{
                print("uploadLocation error: \(error)")
                return
            }
        }
        
        //儲存自己的位置
        let coreDataManager = CoreDataManager.shared
        coreDataManager.storeLocations(coordinate)
        
        //更新畫面軌跡
        mainMapView.removeOverlays(mainMapView.overlays)
        guard let pastLocations = coreDataManager.fetchPastLocations() else {
            print("no pastLocations")
            return
        }
                        coordinatesToShow.removeAll()
        
                        for pastLocation in pastLocations {
                        self.coordinatesToShow.append(CLLocationCoordinate2DMake(pastLocation.lat, pastLocation.lon))
        
                        }
        let polyline = MKPolyline(coordinates: coordinatesToShow, count: coordinatesToShow.count)
        mainMapView.add(polyline)
        
    }
    
   
    
    
}

extension DetailViewController: MKMapViewDelegate{
    
    //設定線條樣式
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = PropertyKey.strokeColor
        renderer.lineWidth = PropertyKey.strokeWidth
        
        return renderer
    }
}

extension DetailViewController: NSFetchedResultsControllerDelegate{
    
    
    
}





