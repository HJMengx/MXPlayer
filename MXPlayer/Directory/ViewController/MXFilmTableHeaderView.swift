//
//  MXFilmTableHeaderView.swift
//  MXPlayer
//
//  Created by mx on 2017/1/29.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

class MXFilmTableHeaderView: UITableViewHeaderFooterView {

    var indicationImage : UIImageView!
    
    var title : UILabel!
    
    var titleConstrait : Constraint!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        //初始化代码
        self.initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func initSubViews(){
        self.indicationImage = UIImageView()
        
        self.indicationImage.image = UIImage.init(named: "arrows_next")
        
        self.addSubview(self.indicationImage)
        
        self.indicationImage.snp.makeConstraints { (make : ConstraintMaker) in
            make.right.equalTo(self).offset(-8)
            make.width.equalTo(20)
            make.top.equalTo(self).offset(self.frame.size.height / 2 - 10)
            make.height.equalTo(20)
        }
        
        self.title = UILabel()
        
        self.addSubview(self.title)
        
        self.title.snp.makeConstraints { (make : ConstraintMaker) in
            self.titleConstrait = make.left.equalTo(self).offset(10).constraint
            
            make.right.equalTo(self.indicationImage.snp.left).offset(-8)
            
            make.height.equalToSuperview()
        }
    }
    
    func settingTitle(title : String){
        self.title.text = title
    }
    
    func openAnimation(){
        //向下旋转，并修改字体
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.allowUserInteraction, animations: { [weak self] ()->Void in
            //设置旋转
            self?.title.font = UIFont.init(name: "AppleSDGothicNeo-Medium", size: 14.0)
            
            self?.title.textColor = UIColor.red
            
            self?.title.transform = CGAffineTransform()
            
            self?.title.transform = (self?.title.transform.translatedBy(x: 10, y: 0))!
            
            self?.indicationImage.transform = (self?.indicationImage.transform.rotated(by: CGFloat(M_PI_2)))!
            
        }, completion: nil)
    }
    
    func closeAniamtion(){
        //原始状态旋转，并修改字体
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.allowUserInteraction, animations: { [weak self] ()->Void in
            //设置旋转
            self?.title.font = UIFont.init(name: "AppleSDGothicNeo-Medium", size: 14.0)
            
            self?.title.textColor = UIColor.lightGray
            
            self?.title.transform = CGAffineTransform()
            
            self?.title.transform = (self?.title.transform.translatedBy(x: -10, y: 0))!
        
            self?.indicationImage.transform = (self?.indicationImage.transform.rotated(by: CGFloat(-M_PI_2)))!
            
            }, completion: nil)
    }
}
