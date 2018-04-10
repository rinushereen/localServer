import UIKit
import IQKeyboardManagerSwift
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate, UNUserNotificationCenterDelegate,UITabBarControllerDelegate{
    
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var currentLocationlatitude: Double!
    var currentLocationlongitude: Double!
    var currentLocationAccuracy: Double!
    var currentSpeed: Double!
    var database =  DataBase()
    
    var isStartLocation : Bool!
    var StartLocationID : Int64!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // self.locationManager.requestAlwaysAuthorization()
        //self.locationManager.requestLocation()
        
        if UserDefaults.standard.value(forKey: "firstLoad") != nil{
            
            self.firstLoad = UserDefaults.standard.value(forKey: "firstLoad") as! Bool
        }else{
            UserDefaults.standard.set(true, forKey: "firstLoad")
            self.firstLoad = UserDefaults.standard.value(forKey: "firstLoad") as! Bool
            //  UserDefaults.standard.value(forKey: "firstLoad") as! Bool
        }
        
        
        // Override point for customization after application launch.
        IQKeyboardManager.sharedManager().enable = true
        UINavigationBar.appearance().barTintColor = UIColor(red:0.07, green:0.24, blue:0.39, alpha:1.0)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        
        
        LocalNotification.registerForLocalNotification(on: UIApplication.shared)
        let likeAction = UNNotificationAction(identifier: "LikeID",title: "Ok", options: [.foreground])
        
        let dislikeAction = UNNotificationAction(identifier: "DislikeID",title: "Stop Trip", options: [.foreground])
        
        
        
        let category = UNNotificationCategory(identifier: "app.categoryIdentifier.ios10",actions: [likeAction, dislikeAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        UNUserNotificationCenter.current().delegate = self
        
        locationManager.delegate = self
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        database.initializeDB()
        
        
        if UserDefaults.standard.value(forKey: "sessionID")  != nil{
            
            
            
            
            let locationID  = self.database.addLocationData(latitude: "\(getCurrentLocationlatitude())", latitude_text: "\(getCurrentLocationlatitude())", longitude: "\(getCurrentLocationlongitude())", longitude_text: "\(getCurrentLocationlongitude())", location_name: " ", location_type_id:  "8000" , accuracy: "\(self.getCurrentLocationAccuracy())")
            
            let date = NSDate()
            self.database.addParentLoginActivity(parent: "0", level: "0", activity: "Auto Login", activityTypeID: "5000", remarks: "", startDate: "\(date)", endDate: "\(date)", startLocationID: "\(locationID)", selectedStartLocationID: "\(locationID)", completedLocationID: "\(locationID)", selectedcompletedLocationID: "\(locationID)", parentName: "1", sync_immediate: "0", sync_immediate_status: "", userID: "")
            
            
         //   DispatchQueue.main.async {
                
//                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//                let tabBarController = mainStoryBoard.instantiateViewController(withIdentifier: "tabViewController") as! UITabBarController
//                tabBarController.delegate = self
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.window?.rootViewController = tabBarController
            
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad = mainStoryboardIpad.instantiateViewController(withIdentifier: "tabViewController") as! UITabBarController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
                
                
          //  }
        }else{
            
            
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "loginViewController") as! ViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
//            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//            let loginViewController = mainStoryBoard.instantiateViewController(withIdentifier: "loginViewController") as! ViewController
//
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = loginViewController
           
            
            
        }
        print(DataBaseManager.shared.pathToDatabase)
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        
        return viewController != tabBarController.selectedViewController
        
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Se@objc @objc nt when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if  isLocationUpdateStart() == false{
            locationUpdate()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if  isLocationUpdateStart() == false{
            locationUpdate()
        }
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    // MARK: Notification delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
        
        
        if response.actionIdentifier == "LikeID" {
            
            print("like pressed")
        }
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        //if notification.request.identifier == requestIdentifier{
        
        completionHandler( [.alert,.sound,.badge])
        
        // }
    }
    
    // MARK: Loading View
    
    
    var bgView : UIView!
    var img : UIImageView!
    
    func addLoadingIndicator(){
        
        bgView = UIView(frame: CGRect(x: 0, y: 0, width: (self.window?.frame.width)!, height: (self.window?.frame.height)!))
        bgView.backgroundColor = UIColor.black;
        bgView.alpha = 0.5
        bgView.tag = 123
        self.window?.addSubview(bgView)
        img = UIImageView(frame: CGRect(x: 0, y: (self.window?.frame.height)!/2-50, width: 50, height: 50))
        img.image = UIImage(named: "spinner")
        rotateView(imageView: img, parentView: bgView  )
        let activityindicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityindicator.center = bgView.center
        activityindicator.startAnimating()
        activityindicator.activityIndicatorViewStyle = .whiteLarge
        activityindicator.tintColor = UIColor.red
        bgView.addSubview(activityindicator)
        
    }
    
    func rotateView(imageView: UIImageView ,parentView: UIView) {
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: parentView.frame.size.width/2, y: parentView.frame.size.height/2), radius: 37.5, startAngle: 0, endAngle:CGFloat(M_PI)*2, clockwise: true)
        
        let animation = CAKeyframeAnimation(keyPath: "position");
        animation.duration = 5
        animation.repeatCount = MAXFLOAT
        animation.path = circlePath.cgPath
        UIView.animate(withDuration: 5.0 , delay: 0, options: .repeat, animations: {
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            // animation
        }, completion: { _ in
            
            
        })
        // You can also pass any unique string value for key
        imageView.layer.add(animation, forKey: nil)
        
        // circleLayer is only used to locate the circle animation path
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.backgroundColor = UIColor.clear.cgColor
        
        //imageView.layer.addSublayer(circleLayer)
    }
    
    
    
    
    //----------------------------------------
    
    func removeLoadingIndicator(){
        
        if (self.window?.viewWithTag(123) as? UIView) != nil {
            UIView.animate(withDuration: 1.0 , delay: 0.25, options: .curveEaseOut, animations: {
                self.img.frame =  CGRect(x: (self.window?.frame.width)!+100 , y: (self.window?.frame.height)!/2-50, width: 50, height: 50)
                // animation
            }, completion: { _ in
                self.img.removeFromSuperview()
                self.bgView.removeFromSuperview()
                
            })
        }
        
    }
    
    //-----------------------------------------
    
    
    // MARK: Alert Message
    
    func showAlertMessage(controller:UIViewController, title:String,message:String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - DataBase Methods
    
    
    
    // MARK: - Location Methods
    var gameTimer: Timer? = nil
    
    var noOfAlertPresented = 0
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        currentLocationlatitude = Double((location?.coordinate.latitude)!)
        currentLocationlongitude = Double((location?.coordinate.longitude)!)
        currentLocationAccuracy = Double((location?.horizontalAccuracy)!)
        currentSpeed = Double((location?.speed)!)
   
        
        locationStatus()
        
        if currentLocationlatitude != nil{
            
            
        }
        
        
    }
    
    
    var inTimer = false
    var noOfReminder = 0
    var ReminderInterval = 0
    var firstLoad : Bool = true
    func locationStatus(){
        
        
        
        
        if UserDefaults.standard.value(forKey: "tripStarted") != nil {
            if currentSpeed < 3.0{
                let idleArray = database.getIdleReminderSettings()
                
                let values = idleArray.value(forKey: "value") as! NSArray
                let settingsTypeId = idleArray.value(forKey: "config_setting_type_id") as! NSArray
                
                
                if firstLoad {
                    
                    if values.contains("on") || values.contains("On"){
                        firstLoad =  !firstLoad
                        let indexOfReminderInterval = settingsTypeId.index(of: 156)
                        let indexOfNoOfReminder = settingsTypeId.index(of: 150)
                        
                        noOfReminder = Int(values[indexOfNoOfReminder] as! String)!
                        ReminderInterval = Int(values[indexOfReminderInterval] as! String)!
                    }
                    
                }
                
                if inTimer == false && noOfReminder != 0{
                    triggerTimer()
                    noOfReminder = noOfReminder - 1
                }else{
                    UserDefaults.standard.set(false, forKey: "firstLoad")
                    print("finished remindars")
                    
                }
                
                
                
            }
            else{
                
                //speed > 3
                
            }
        }
        
        
        
        
    }
    
    
    func triggerTimer(){
        
        //        if UserDefaults.standard.value(forKey: "times") != nil{
        //            let notificationspresent = UserDefaults.standard.value(forKey: "times") as! Int
        //            if notificationspresent != noOfReminder && noOfReminder != 0{
        
        gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(ReminderInterval*60), target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
        
        
        inTimer = true
        //UserDefaults.standard.set(times, forKey: "times")
        
        
        
        //            }
        //        }else{
        //
        //
        //            gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
        //            UserDefaults.standard.set(times, forKey: "times")
        //        }
        //
        
    }
    
    var times:Int = 0;
    @objc func runTimedCode(){
        // if self.noOfReminder != 0{
        if currentSpeed < 3.0 &&  UserDefaults.standard.value(forKey: "tripStarted") != nil {
            //  times = times + 1
            LocalNotification.dispatchlocalNotification(with: "MECARS", body: "You are at the same location for extended period of time.", at: Date())
            inTimer = false
        }else{
            
            //started to move
            
        }
        //  }
        //
        //        if noOfAlertPresented == noOfReminder  && noOfReminder > 0{
        //
        //            gameTimer.invalidate()
        //            gameTimer = nil
        //
        //        }else{
        //        noOfAlertPresented = noOfAlertPresented + 1
        //
        //
        //             LocalNotification.dispatchlocalNotification(with: "Warning", body: "your location is static", at: Date())
        //        let alert = UIAlertController(title: "My Title", message: "This is my message.", preferredStyle: UIAlertControllerStyle.alert)
        //
        //        // add an action (button)
        //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        //
        //        // show the alert
        //        window?.rootViewController?.present(alert, animated: true, completion: nil)
        
        //        }
        //        }else{
        //
        //
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationUpdate()
        }
    }
    
    var isUpdatingLocation: Bool = false
    func locationUpdate(){
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        isUpdatingLocation = true;
    }
    
    
    func isLocationUpdateStart() -> Bool
    {
        
        
        if CLLocationManager.locationServicesEnabled() {
            return false
        }
        return false
        
    }
    
    
    func getCurrentLocationAccuracy() -> Double {
        if currentLocationAccuracy == nil {
            return 0
        }
        return currentLocationAccuracy
    }
    func getCurrentLocationlatitude() -> Double {
        if currentLocationlatitude == nil {
            return 0
        }
        return currentLocationlatitude
    }
    func getCurrentLocationlongitude() -> Double{
        if currentLocationlongitude == nil {
            return 0
        }
        return currentLocationlongitude
    }
    
    func getCurrentSpeed() -> Double{
        if currentSpeed == nil {
            return 0
        }
        return currentSpeed
    }
}
