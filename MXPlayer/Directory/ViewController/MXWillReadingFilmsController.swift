//
//  MXWillReadingFilmsController.swift
//  MXPlayer
//
//  Created by mx on 2017/1/31.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

class MXWillReadingFilmsController: UIViewController {
    
    var filmsView : UITableView!
    
    var model : MXFilmViewModel = MXFilmViewModel.share
    
    var isEditingModel = false
    
    private var isFirstEnter : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化
        self.initSubViews()
        
        self.isFirstEnter = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //每一次重新进入都需要刷新一下
        
        NotificationCenter.default.addObserver(self, selector: #selector(MXWillReadingFilmsController.filmsChange), name: NSNotification.Name.init(MXPlayerFilmsRefresh), object: nil)
        
        if !self.isFirstEnter {
            self.filmsView.reloadData()
        }
    }
    
    //MARK: Notification
    func filmsChange(){
        self.filmsView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //取消通知
        NotificationCenter.default.removeObserver(self)
    }
    //初始化
    fileprivate func initSubViews(){
        self.filmsView = UITableView(frame: CGRect(), style: UITableViewStyle.grouped)
        
        self.view.addSubview(self.filmsView)
        
        self.filmsView.register(MXFilmsCell.classForCoder(), forCellReuseIdentifier: MXFILMCELL)
        
        self.filmsView.register(MXFilmSeletedCell.classForCoder(), forCellReuseIdentifier: MXFILMSELETEDCELL)
        
        self.filmsView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 1))
        
        self.filmsView.snp.makeConstraints { (make : ConstraintMaker) in
            make.edges.equalTo(UIEdgeInsets.init(top: 34, left: 0, bottom: 0, right: 0))
            
        }
        self.filmsView.delegate = self
        
        self.filmsView.dataSource = self
    }
}


extension MXWillReadingFilmsController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!
        
        
        if self.isEditingModel {
            cell =  tableView.dequeueReusableCell(withIdentifier: MXFILMSELETEDCELL) as! MXFilmSeletedCell
            
            (cell as! MXFilmSeletedCell).settingAttributes(url: self.model.willReadingFilm[indexPath.row].fileUrl, file: self.model.willReadingFilm[indexPath.row].name, isSecurityPage: false)
            
            (cell as! MXFilmSeletedCell).delegates[0] = self
            
        }else{
            cell =  tableView.dequeueReusableCell(withIdentifier: MXFILMCELL)
            
            (cell  as! MXFilmsCell).settingAttributes(url: self.model.willReadingFilm[indexPath.row].fileUrl, file: self.model.willReadingFilm[indexPath.row].name)
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.willReadingFilm.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //播放效果
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //播放
        let ffTransitionDelegate = FFTransitionDelegate.shareInstance()
        
        let playController = MXPlayViewController()
        
        playController.selectedFilms = self.model.willReadingFilm
        
        playController.modalPresentationStyle = .custom
        
        playController.filmsViewController = self
        
        playController.currentUrl = indexPath.row
        
        playController.presented = MXFilmPresentedType.willReading
        
        playController.transitioningDelegate = ffTransitionDelegate
        
        self.present(playController, animated: true, completion: nil)
        
    }
    //高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    //删除，时间全部被监听了。
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.default, title: "删除", handler: {
            (action : UITableViewRowAction, indexPath : IndexPath) -> Void in
            //删除操作
            //删除本地
            
            //删除数据库
            
            //删除数组
            
            //刷新列表
        })
        
        let securityAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.default, title: "加密", handler: {
            (action : UITableViewRowAction, indexPath : IndexPath) -> Void in
            //删除操作
            
        })
        
        return [securityAction,deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        /*
         第一个方法canEditRowAtIndexPath允许你的cell进入编辑状态,第二个方法commitEditingStyle也需要实现,否则你无法通过左滑来显示自定义action.
         
         在iOS8中,Apple开放了editActionsForRowAtIndexPath这个方法,该方法在iOS7中是一个私有方法,Apple在iOS自带的邮件app中使用了这个方法,他们好像对一些新的特性也做了同样禽兽不如的事,比如从cell的左侧一直滑动到右侧就会触发一个action,右滑出现自定义action按钮,这两个方法在iOS8中是私有的,但是在iOS9中就被公开了.
         */
    }

}

//能正确跳转
extension MXWillReadingFilmsController : MXEditingStyleDelegate,MXFilmSelectedCellDelegate{
    func comingToEditStyle(at index: Int,isEditing : Bool) {
        if isEditing {
            //取消编辑
            self.isEditingModel = false
            
            self.reloadFilms()
        }else {
            //开始编辑
            self.isEditingModel = true
            
            self.reloadFilms()
        }
    }
    
    fileprivate func reloadFilms(){
        var rows = [IndexPath]()
        
        for row in 0..<self.model.willReadingFilm.count {
            rows.append(IndexPath.init(row: row, section: 0))
        }
        
        self.filmsView.reloadRows(at: rows, with: UITableViewRowAnimation.left)
    }
    
    func operationWith(cell: MXFilmSeletedCell, type: String) {
        switch type {
        case "unLock":
        
            break
        case "lock":
            //删除指定的位置
            if let indexPath = self.filmsView.indexPath(for: cell) {
                //改变为加密
                self.model.willReadingFilm[indexPath.row].secret = true
                //后台添加到数据库..
                operationDataBase(film: self.model.willReadingFilm[indexPath.row], type: MXDataBaseOperationType.updateSecret)
                //添加到加密
                self.model.secretFilm.append(self.model.willReadingFilm[indexPath.row])
                //删除原位置
                self.model.willReadingFilm.remove(at: indexPath.row)
                //刷新
                self.filmsView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                //刷新数据库
                
            }
            break
        default:
            //删除指定的位置
            if let indexPath = self.filmsView.indexPath(for: cell) {
                //刷新数据库
                operationDataBase(film: self.model.willReadingFilm[indexPath.row], type: MXDataBaseOperationType.delete)
                //删除
                self.model.willReadingFilm.remove(at: indexPath.row)
                //刷新
                self.filmsView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                
            }
            break
        }
    }
}
