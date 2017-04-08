//
//  MXRootViewController.swift
//  MXPlayer
//
//  Created by mx on 2017/1/26.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

class MXRootViewController: TabPageViewController {
    
    //ViewModel
    var filmsView : UITableView!
    
    override func viewDidLoad() {
        //设置导航栏
        self.settingNavigationBar()
        //然后设置一些东西？
        self.settingPageController()
        //加载之后调用
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func settingNavigationBar(){
        
    }
    
    fileprivate func settingPageController(){

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

/*
extension MXFilmsViewController {
 //头部View
 func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
 
 var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MXFILMHEADER) as? MXFilmTableHeaderView
 
 if headerView == nil {
 headerView = MXFilmTableHeaderView()
 }
 
 switch section {
 case 0:
 headerView!.title.text = "当前"
 break
 case 1:
 headerView!.title.text = "已看"
 break
 default:
 headerView!.title.text = "私密"
 break
 }
 //增加点击事件
 headerView!.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(MXFilmsViewController.headerClickedIn(section:headerView:))))
 
 return headerView
 }
 
 
    func headerClickedIn(section : Int,headerView : MXFilmTableHeaderView){
        //点击的是标题，展开缩放
        var indexPaths = [IndexPath]()
 
        if self.isExpanding[section] {
            //缩放
            for row in 0..<self.model.films[section].count {
                indexPaths.append(IndexPath.init(row: section, section: row))
            }
            
            self.filmsView.deleteRows(at: indexPaths, with: UITableViewRowAnimation.fade)
        }else{
            //加密的一组，首先需要弹出密码框
            if section == 2{
                
                //密码正确继续执行
            }
            
            //展开
            for row in 0..<self.model.films[section].count {
                indexPaths.append(IndexPath.init(row: section, section: row))
            }
            
            self.filmsView.insertRows(at: indexPaths, with: UITableViewRowAnimation.fade)
        }

    }
}
*/
