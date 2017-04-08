//
//  AppDelegate.swift
//  MXPlayer
//
//  Created by mx on 2017/1/26.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

protocol MXEditingStyleDelegate {
    func comingToEditStyle(at index : Int,isEditing : Bool)
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    fileprivate var isEdit : [Bool] = [false,false,false]
    
     var page : TabPageViewController!
    
    var isLandScape : Bool = false
    
    fileprivate var delegates : [MXEditingStyleDelegate] = [MXEditingStyleDelegate]()

    //控制横竖屏
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if !self.isLandScape {
            return .all
        }else{
            return .landscape
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        self.pageViewController()
        
        let nav = UINavigationController.init(rootViewController: self.page)
        
        self.page.title = "电影"
        
        //设置字体颜色
        self.page.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.systemFont(ofSize:
            16.0),NSForegroundColorAttributeName:UIColor.white]
        //init(red: 143 / 255.0, green: 164 / 255.0, blue: 171 / 255.0, alpha: 1.0)
        
        self.settingNavigation()
        
        self.window?.rootViewController = nav
        
        self.window?.makeKeyAndVisible()
        
        //创建数据表和表
        self.createdDataBase()
        //加载数据
        MXFilmViewModel.share.getFilmFromLocal()
        
        print("file path is \(FILEPATH)")
        
        NSSetUncaughtExceptionHandler { (exception : NSException) in
            print("*************************\n")
            
            let symbols = exception.callStackSymbols
            
            let name = exception.name
            
            let reson = exception.reason
            
            print("symbols is \(symbols) \n name is \(name) \n reason is \(reson)")
            
            print("\n*************************\n")
            
            //上传到服务器
            
        }
        
        return true
    }
    
    fileprivate func settingNavigation(){
        let rightBarButton = UIButton.init(frame: CGRect.init(x: self.window!.frame.size.width - 34, y: 2, width: 24, height: 24))
        
        rightBarButton.setBackgroundImage(UIImage.init(named: "internet3"), for: UIControlState.normal)
        
        rightBarButton.addTarget(self, action: #selector(AppDelegate.internetSearch), for: UIControlEvents.touchUpInside)
        
        //self.page.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarButton)
        
        //设置左边按钮
        let leftBarButton = UIButton.init(frame: CGRect.init(x: 2, y: 2, width: 24, height: 24))
        
        leftBarButton.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
        
        leftBarButton.addTarget(self, action: #selector(AppDelegate.slideToEdit), for: UIControlEvents.touchUpInside)
        
        self.page.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBarButton)
    }
    
    func internetSearch(){
        //跳转一个search页面
    }
    
    fileprivate func createdDataBase(){
        
        if UserDefaults.standard.object(forKey: "isFilmExist") == nil || !UserDefaults.standard.bool(forKey: "isFilmExist") {
            
            let manager = FMDatabase.init(path: DBPATH)!

            //首先打开数据库
            manager.open()
            
            let error = manager.executeStatements("create table Film(name text primary key , fileUrl text ,duration integer,seeingTime integer,isSeeing boolean,secret boolean);")
            
            if !error {
                print("create error is \(manager.lastError())")
            }
            //判断条件
            UserDefaults.standard.set(true, forKey: "isFilmExist")
            
            UserDefaults.standard.set(nil, forKey: "password")
            
            UserDefaults.standard.set(true, forKey: "isNeedTestFilm")
            
            UserDefaults.standard.synchronize()
        }

    }
    //切换到编辑模式
    func slideToEdit(){
        
        self.delegates[self.page.currentIndex!].comingToEditStyle(at: self.page.currentIndex!,isEditing : self.isEdit[self.page.currentIndex!])
        
        self.isEdit[self.page.currentIndex!] = !self.isEdit[self.page.currentIndex!]
        
    }
    
    fileprivate func pageViewController() {
        self.page = TabPageViewController.create()
        //设置子控制器
        let willReadingViewController = MXWillReadingFilmsController()
        
        let readingViewController = MXReadingFilmsViewController()
        
        let securityViewController = MXSecurityFilmsViewController()
        
        self.delegates.append(willReadingViewController)
        
        self.delegates.append(readingViewController)
        
        self.delegates.append(securityViewController)
        //设置SubViewControllers
        self.page.tabItems = [(willReadingViewController,"本地"),(readingViewController,"历史"),(securityViewController,"个人")]
        //设置相关属性
        var options = TabPageOption.init()
    
        //在这里设置颜色
        options.tabBackgroundColor = UIColor.init(red: 85 / 255.0, green: 162 / 255.0 , blue: 217 / 255, alpha: 1.0)
        
        options.currentColor = UIColor.init(red: 123 / 255.0, green: 216 / 255.0, blue: 192 / 255.0, alpha: 1.0)
        
        options.defaultColor = UIColor.white
        
        options.tabMargin = self.window!.bounds.size.width / 7.5
        
        self.page.option = options
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //程序结束
        //通过alert提示
        //如果不加载的话就不需要提示
        if UserDefaults.standard.bool(forKey: "isNeedTestFilm"){
            let alert = UIAlertController.init(title: "", message: "还需要加载演示视频吗？", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction.init(title: "加载", style: UIAlertActionStyle.default, handler: { (action : UIAlertAction) in
                //不操作
                
            }))
            
            alert.addAction(UIAlertAction.init(title: "不加载", style: UIAlertActionStyle.cancel, handler: { (action : UIAlertAction) in
                //改变加载
                UserDefaults.standard.set(false, forKey: "isNeedTestFilm")
                //删除
                //从数据库删除
                operationDataBase(film: Film.init(name: "MXPlayercontent.mov", duration: 0, fileUrl: "", isSeeing: true, seeingTime: 0, secret: false), type: .delete)
                //重新刷新列表
                MXFilmViewModel.share.getFilmFromLocal()
                //页面也应该刷新
                NotificationCenter.default.post(Notification.init(name: Notification.Name.init(MXPlayerFilmsRefresh)))
            }))
            
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //重新刷新列表
        MXFilmViewModel.share.getFilmFromLocal()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }


}

