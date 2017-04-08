//
//  MXModifySecurityPasswordViewController.swift
//  MXPlayer
//
//  Created by mx on 2017/3/3.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

fileprivate let SECURITYCELL = "Security"

class MXModifySecurityPasswordViewController: UIViewController {

    var passwordView : MXSecurityPasswordView!
    
    var tableView : UITableView!
    
    var navBar : MXModifyPasswordNavView!
    
    var securityFilmsViewController : MXSecurityFilmsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置相关属性
        self.initSubViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSubViews(){
        
        self.navBar = MXModifyPasswordNavView()
        
        self.view.addSubview(self.navBar)
        
        self.navBar.delegate = self
        
        self.navBar.snp.makeConstraints { (make : ConstraintMaker) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(64)
        }
        
        self.tableView = UITableView()
        
        self.view.addSubview(self.tableView)
        
        self.tableView.register(MXSecurityModifyPasswordCell.classForCoder(), forCellReuseIdentifier: SECURITYCELL)
        
        self.tableView.delegate = self
        
        self.tableView.dataSource = self
        
        self.tableView.separatorStyle = .none
        
        self.tableView.snp.makeConstraints { (make : ConstraintMaker) in
            make.top.equalTo(self.navBar.snp.bottom).offset(0)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    
    func leftButtonClick(){
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func rightButtonClick(){
        self.view.endEditing(true)
        //保存密码
        let passwordCell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! MXSecurityModifyPasswordCell
        
        let submitPasswordCell = self.tableView.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! MXSecurityModifyPasswordCell
        
        //去除密码
        let password = passwordCell.passwordField.text
        
        let submitPassword = submitPasswordCell.passwordField.text
        
        if password != nil && submitPassword != nil {
            
            let whiteSpace = CharacterSet.whitespaces
            
            if password!.trimmingCharacters(in: whiteSpace) != "" && submitPassword!.trimmingCharacters(in: whiteSpace) != "" {
                if password! == submitPassword! {
                    //保存
                    SVProgressHUD.showInfo(withStatus: "正在修改")
                    
                    UserDefaults.standard.set(password!, forKey: "password")
                    
                    if UserDefaults.standard.synchronize() {
                        
                        SVProgressHUD.dismiss()
                        
                        self.securityFilmsViewController.password = password!
                        
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        SVProgressHUD.showError(withStatus: "修改失败")
                    }
                    
                }else{
                    SVProgressHUD.showError(withStatus: "两次密码不一致")
                }
            }else{
                SVProgressHUD.showError(withStatus: "请输入正确的密码")
            }
        }else{
            //
            SVProgressHUD.showError(withStatus: "请输入密码")
        }
    }
    

}
//MARK: delegate
extension MXModifySecurityPasswordViewController : MXModifyPasswordViewDelegate {
    func operation(at: MXModifyPasswordNavView, with: MXModifyType) {
        switch with {
        case .back:
            self.leftButtonClick()
            break
        default:
            self.rightButtonClick()
            break
        }
    }
}
//MARK:tableView
extension MXModifySecurityPasswordViewController : UITableViewDelegate,UITableViewDataSource{
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SECURITYCELL, for: indexPath) as! MXSecurityModifyPasswordCell
        
        switch indexPath.row {
        case 0:
            cell.passwordField.placeholder = "请输入新口令"
            break
        default:
            cell.passwordField.placeholder = "请确认新的口令"
            break
        }
        
        return cell
    }

}
