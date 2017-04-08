//
//  MXFilmSeletedCell.swift
//  MXPlayer
//
//  Created by mx on 2017/2/1.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

protocol MXFilmSelectedCellDelegate {
    func operationWith(cell : MXFilmSeletedCell,type : String)
}

class MXFilmSeletedCell: UITableViewCell {
    
    var predingImage : UIImageView!
    
    var filmName : UILabel!
    
    var securityButton : UIButton!
    
    var deleteButton : UIButton!
    //笨的处理方式，考虑是否有更好的方式处理
    var delegates : [MXFilmSelectedCellDelegate] = [MXWillReadingFilmsController(),MXWillReadingFilmsController(),MXWillReadingFilmsController()]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func initSubViews(){
        self.predingImage = UIImageView()
        
        self.contentView.addSubview(self.predingImage)
        
        self.predingImage.layer.borderWidth = 0.5
        
        self.predingImage.layer.borderColor = UIColor.black.cgColor
        
        self.predingImage.layer.cornerRadius = 5
        
        self.predingImage.layer.masksToBounds = true
        
        self.predingImage.snp.makeConstraints { (make : ConstraintMaker) in
            make.left.equalTo(self.contentView).offset(4)
            make.top.equalTo(self.contentView).offset(2)
            make.bottom.equalTo(self.contentView).offset(-2)
            make.width.equalTo(60)
        }
        
        self.filmName = UILabel()
        
        self.contentView.addSubview(self.filmName)
        
        self.filmName.snp.makeConstraints { (make : ConstraintMaker) in
            make.left.equalTo(self.predingImage.snp.right).offset(4)
            make.right.equalTo(self.contentView).offset(0)
            make.height.equalToSuperview()
        }
        //删除按钮
        self.deleteButton = UIButton()
        
        self.contentView.addSubview(self.deleteButton)
        
        self.deleteButton.setBackgroundImage(UIImage.init(named: "delete"), for: UIControlState.normal)
        
        self.deleteButton.addTarget(self, action: #selector(MXFilmSeletedCell.deleteFilm), for: UIControlEvents.touchUpInside)
        
        //设置约束
        self.deleteButton.snp.makeConstraints { (make : ConstraintMaker) in
            make.right.equalToSuperview().offset(-5)
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(15)
        }
    
        //私密按钮
        self.securityButton = UIButton()
        
        self.contentView.addSubview(self.securityButton)
        
        //设置约束
        self.securityButton.snp.makeConstraints { (make : ConstraintMaker) in
            make.right.equalTo(self.deleteButton.snp.left).offset(-5)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(10)
        }
        
    }
    
    //点击删除
    func deleteFilm(){
        self.delegates[(UIApplication.shared.delegate as! AppDelegate).page.currentIndex!].operationWith(cell: self, type: "delete")
    }
    
    //点击加密
    func securityFilm(){
        self.delegates[(UIApplication.shared.delegate as! AppDelegate).page.currentIndex!].operationWith(cell: self, type: "lock")
    }
    //解锁
    func unLockFilm(){
        self.delegates[(UIApplication.shared.delegate as! AppDelegate).page.currentIndex!].operationWith(cell: self, type: "unLock")
    }
    
    //设置属性
    func settingAttributes(url imageUrl : String,file : String,isSecurityPage : Bool = false){
        self.filmName.text = " ".appending(file)
        
        self.predingImage.image = UIImage.init(named: "film")
        
        //设置解锁按钮
        if isSecurityPage {
            self.securityButton.setBackgroundImage(UIImage.init(named: "openLock"), for: UIControlState.normal)
            
            self.securityButton.addTarget(self, action: #selector(MXFilmSeletedCell.unLockFilm), for: UIControlEvents.touchUpInside)
        }else{
            self.securityButton.setBackgroundImage(UIImage.init(named: "lock"), for: UIControlState.normal)
            
            self.securityButton.addTarget(self, action: #selector(MXFilmSeletedCell.securityFilm), for: UIControlEvents.touchUpInside)
        }
        
        if file == "MXPlayercontent.mov"{
            self.deleteButton.alpha = 0
    
        }
    }
}
