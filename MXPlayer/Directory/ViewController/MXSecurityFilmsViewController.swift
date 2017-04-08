//
//  MXSecurityFilmsViewController.swift
//  MXPlayer
//
//  Created by mx on 2017/1/31.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit


fileprivate func angle(angle : Double) -> Double {

    return angle / 180.0 * M_PI
}

class MXSecurityFilmsViewController: UIViewController {
    
    var filmsView : UITableView!
    
    var model : MXFilmViewModel = MXFilmViewModel.share
    
    //是否为加密页面
    fileprivate let isSecurityPage = true
    
    //是否在编辑模式
    var isEditingModel = false
    
    //是否从密码页面跳转
    var isPlaySecurity : Bool = false
    
    //保存密码
    var password : String!
    //密码View
    var passwordView : MXSecurityPasswordView!
    
    var alertPassword : UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(MXSecurityFilmsViewController.keyboardAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MXSecurityFilmsViewController.keyboardDisAppear), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MXWillReadingFilmsController.filmsChange), name: NSNotification.Name.init(MXPlayerFilmsRefresh), object: nil)
    }
    
    //MARK: Notification
    func filmsChange(){
        self.filmsView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //注销通知
        NotificationCenter.default.removeObserver(self)
        
        //
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //注册通知
        self.registerNotification()
        //检查密码
        if !self.isPlaySecurity {
            if let password = UserDefaults.standard.string(forKey: "password") {
                
                self.password = password
                //输入密码
                if self.passwordView == nil || (self.passwordView != nil && self.passwordView.isSetting) {
                    self.passwordView = MXSecurityPasswordView.init(frame: CGRect())
                    
                    self.passwordView.isSetting = false
                    
                    self.passwordView.delegate = self
                    
                    self.view.addSubview(self.passwordView)
                    
                    self.passwordView.backgroundColor = UIColor.init(red: 85 / 255.0, green: 162 / 255.0 , blue: 217 / 255, alpha: 1.0)
                    
                    self.passwordView.snp.makeConstraints({ (make : ConstraintMaker) in
                        make.left.equalToSuperview().offset(10)
                        make.right.equalToSuperview().offset(-10)
                        make.top.equalToSuperview().offset(36)
                        make.height.equalTo(119)
                    })
                    
                    self.passwordView.initSubViews()
                    
                    //self.passwordView.passwordField.becomeFirstResponder()
                    
                }else if !self.passwordView.isSetting {
                    //直接显示,上一次输入隐藏
                    //self.passwordView.alpha = 1
                    self.passwordView = MXSecurityPasswordView.init(frame: CGRect())
                    
                    self.passwordView.isSetting = false
                    
                    self.passwordView.delegate = self
                    
                    self.view.addSubview(self.passwordView)
                    
                    self.passwordView.backgroundColor = UIColor.init(red: 85 / 255.0, green: 162 / 255.0 , blue: 217 / 255, alpha: 1.0)
                    
                    self.passwordView.snp.makeConstraints({ (make : ConstraintMaker) in
                        make.left.equalToSuperview().offset(10)
                        make.right.equalToSuperview().offset(-10)
                        make.top.equalToSuperview().offset(36)
                        make.height.equalTo(119)
                    })
                    self.passwordView.initSubViews()
                    
                    //self.passwordView.passwordField.becomeFirstResponder()
                }
            }else{
                //设置密码
                self.passwordView = MXSecurityPasswordView.init(frame: CGRect())
                    
                self.passwordView.isSetting = true
                
                self.passwordView.delegate = self
                
                self.view.addSubview(self.passwordView)
                    
                self.passwordView.backgroundColor = UIColor.init(red: 85 / 255.0, green: 162 / 255.0 , blue: 217 / 255, alpha: 1.0)
                
                self.passwordView.alpha = 0.8
                
                self.passwordView.snp.makeConstraints({ (make : ConstraintMaker) in
                    make.left.equalToSuperview().offset(10)
                    make.right.equalToSuperview().offset(-10)
                    make.top.equalToSuperview().offset(36)
                    make.height.equalTo(160)
                })
                self.passwordView.initSubViews()
                
                //self.passwordView.passwordField.becomeFirstResponder()
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //出现了之后设置
        self.isPlaySecurity = false
        //清空所有SubView
        if self.filmsView != nil {
            self.filmsView.removeFromSuperview()
            self.filmsView = nil
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //初始化
    fileprivate func initSubViews(){
        self.filmsView = UITableView(frame: CGRect(), style: UITableViewStyle.grouped)
        
        self.view.addSubview(self.filmsView)
        
        self.filmsView.register(MXFilmsCell.classForCoder(), forCellReuseIdentifier: MXFILMCELL)
        
        self.filmsView.register(MXFilmSeletedCell.classForCoder(), forCellReuseIdentifier: MXFILMSELETEDCELL)
        
        self.filmsView.delegate = self
        
        self.filmsView.dataSource = self
        
        self.filmsView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 1))
        
        self.filmsView.snp.makeConstraints { (make : ConstraintMaker) in
            make.edges.equalTo(UIEdgeInsets.init(top: 34, left: 0, bottom: 0, right: 0))
        }
    }
    
    //触摸
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //结束编辑
        if self.passwordView != nil {
            
            self.passwordView.endEditing(true)
        }
    }
    
    //键盘通知
    func keyboardAppear(){
        
    }
    
    func keyboardDisAppear(){
        
    }
}

//MARK:password delegate
extension MXSecurityFilmsViewController : MXSecuryViewDelegate {
    func operation(at: MXSecurityPasswordView, with: MXSecurityViewOperationType) {
        switch with {
        case .commit:
            //判断密码
            if self.judgePassword() {
                self.hideAnimation()
                self.initSubViews()
                //保存到本地
                if self.passwordView.isSetting {
                    //保存
                    UserDefaults.standard.set(self.password, forKey: "password")
                    UserDefaults.standard.synchronize()
                }
            }else{
                self.jitterAnimation()
            }
            break
        case .cancel:
            //直接取消
            self.hideAnimation()
            break
        default:
            //修改密码
            //判断是否输入正确
            if self.judgePassword() {
                //跳转修改
                self.passwordView.passwordField.text = ""
                //跳转过去
                let mxTransitionDelegate = MXTransitionDelegate.share
                
                let modifyViewController = MXModifySecurityPasswordViewController()
            
                modifyViewController.modalPresentationStyle = .custom
                
                modifyViewController.transitioningDelegate = mxTransitionDelegate
                
                modifyViewController.securityFilmsViewController = self
                
                self.present(modifyViewController, animated: true, completion: nil)
            }else{
                //提示密码错误
                SVProgressHUD.showError(withStatus: "请输入正确的密码")
                self.jitterAnimation()
            }
            
            break
        }
    }
    
    private func judgePassword() -> Bool {
        let whiteSpaceSet = NSCharacterSet.whitespaces
        
        if self.passwordView.passwordField.text != nil && self.passwordView.passwordField.text!.trimmingCharacters(in: whiteSpaceSet) != "" {
            
            if self.password == nil {
                if self.passwordView.submitPasswordField.text == nil {
                    SVProgressHUD.showError(withStatus: "请再次输入密码")
                }else{
                    self.password = self.passwordView.submitPasswordField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
                }
            }
            
            if self.passwordView.passwordField.text! == self.password {
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    //抖动动画
    private func jitterAnimation(){
        let animation = CAKeyframeAnimation.init()
        
        animation.keyPath = "transform.rotation"
        
        animation.values = [angle(angle: -5.0),angle(angle: 5.0),angle(angle: -5.0)]
        
        animation.repeatCount = 3
        
        animation.duration = 0.15
        
        self.passwordView.layer.add(animation, forKey: nil)
    }
    
    func hideAnimation(){
        UIView.animate(withDuration: 0.5, animations: { 
            self.passwordView.alpha = 0
        }) { (isComplete : Bool) in
            self.passwordView.removeFromSuperview()
            self.passwordView = nil
        }
    }
}

//MAKR: tableView
extension MXSecurityFilmsViewController : UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell : UITableViewCell!
        
        
        if self.isEditingModel {
            cell =  tableView.dequeueReusableCell(withIdentifier: MXFILMSELETEDCELL) as! MXFilmSeletedCell
            
            (cell as! MXFilmSeletedCell).settingAttributes(url: self.model.secretFilm[indexPath.row].fileUrl, file: self.model.secretFilm[indexPath.row].name, isSecurityPage: true)
            
            (cell as! MXFilmSeletedCell).delegates[2] = self
            
        }else{
            cell =  tableView.dequeueReusableCell(withIdentifier: MXFILMCELL)
            
            (cell  as! MXFilmsCell).settingAttributes(url: self.model.secretFilm[indexPath.row].fileUrl, file: self.model.secretFilm[indexPath.row].name)
            
        }
        return cell
        
    }
    //高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.secretFilm.count
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
        
        playController.selectedFilms = self.model.secretFilm
        
        playController.modalPresentationStyle = .custom
        
        playController.filmsViewController = self
        
        playController.currentUrl = indexPath.row
        
        playController.presented = MXFilmPresentedType.security
        
        playController.transitioningDelegate = ffTransitionDelegate
        
        self.present(playController, animated: true, completion: nil)
        
    }
    //删除
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let action = UITableViewRowAction.init(style: UITableViewRowActionStyle.default, title: "删除", handler: {
            (action : UITableViewRowAction, indexPath : IndexPath) -> Void in
            //删除操作
            
        })
        
        return [action]
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

extension MXSecurityFilmsViewController : MXEditingStyleDelegate,MXFilmSelectedCellDelegate {
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
        
        for row in 0..<self.model.secretFilm.count {
            rows.append(IndexPath.init(row: row, section: 0))
        }
        
        if self.filmsView != nil {
            self.filmsView.reloadRows(at: rows, with: UITableViewRowAnimation.left)
        }
    }
    
    func operationWith(cell: MXFilmSeletedCell, type: String) {
        switch type {
        case "unLock":
            //删除指定的位置
            if let indexPath = self.filmsView.indexPath(for: cell) {
                //改变为不加密
                self.model.secretFilm[indexPath.row].secret = false
                //删除操作
                if self.model.secretFilm[indexPath.row].seeingTime > 0 {
                    //添加到已看
                    self.model.readingFilm.append(self.model.secretFilm[indexPath.row])
                }else{
                    //添加到未看
                    self.model.willReadingFilm.append(self.model.secretFilm[indexPath.row])
                }
                //刷新数据库
                operationDataBase(film: self.model.secretFilm[indexPath.row], type: .updateSecret)
                //删除原位置
                self.model.secretFilm.remove(at: indexPath.row)
                //刷新
                self.filmsView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
            break
        case "lock":
            
            break
        default:
            //删除指定的位置
            if let indexPath = self.filmsView.indexPath(for: cell) {
                //刷新数据库
                operationDataBase(film: self.model.secretFilm[indexPath.row], type: MXDataBaseOperationType.delete)
                //删除
                self.model.secretFilm.remove(at: indexPath.row)
                //刷新
                self.filmsView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
            break
        }
    }
}
