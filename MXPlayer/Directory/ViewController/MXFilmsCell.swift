//
//  MXFilmsCell.swift
//  MXPlayer
//
//  Created by mx on 2017/1/29.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

class MXFilmsCell: UITableViewCell {

    var predingImage : UIImageView!
    
    var filmName : UILabel!
    
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
        
        self.accessoryType = .disclosureIndicator
        
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
    }
    
    func settingAttributes(url imageUrl : String,file : String){
        self.filmName.text = " ".appending(file)
        
        self.predingImage.image = UIImage.init(named: "film")
    }
}
