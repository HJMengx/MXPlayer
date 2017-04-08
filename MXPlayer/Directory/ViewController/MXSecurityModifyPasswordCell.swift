//
//  MXSecurityModifyPasswordCell.swift
//  MXPlayer
//
//  Created by mx on 2017/3/3.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

class MXSecurityModifyPasswordCell: UITableViewCell {

    var passwordField : UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.initSubViews()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initSubViews(){
        self.passwordField = UITextField()
        
        self.contentView.addSubview(self.passwordField)
        
        self.passwordField.leftViewMode = .always
        
        let passwordImageView = UIImageView.init(frame: CGRect.init(x: 3, y: 0, width: 30, height: 30))
        
        passwordImageView.image = UIImage.init(named: "password2")
        
        self.passwordField.leftView = passwordImageView
        
        self.passwordField.layer.borderColor = UIColor.white.cgColor
        
        self.passwordField.layer.borderWidth = 2
        
        self.passwordField.layer.cornerRadius = 5
        
        self.passwordField.isSecureTextEntry = true
        
        self.passwordField.snp.makeConstraints { (make : ConstraintMaker) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(1)
            make.bottom.equalToSuperview().offset(-1)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
