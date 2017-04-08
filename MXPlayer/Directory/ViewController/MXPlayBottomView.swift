//
//  MXPlayBottomView.swift
//  MXPlayer
//
//  Created by mx on 2017/2/4.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

enum MXPlayBottomOperationType {
    case left
    case right
    case start
    case pause
    case seekTime
}

protocol MXPlayBottomViewDelegate {
    func operation(with : MXPlayBottomView,type : MXPlayBottomOperationType,seekTime : Double?,completion : (()->Void)?)
}

class MXPlayBottomView: UIView {
    //进度条背景
    var progressShadowView : UIImageView!
    //进度显示按钮
    var progressButton : UIButton!
    //播放进度
    var progressSawView : UIImageView!
    //当前时间
    var progressCurrentTimeLabel : UILabel!
    //总时间
    var progressTotalTimeLabel : UILabel!
    //上一个项目
    var backTenButton : UIButton!
    //下一个项目
    var goTenButton : UIButton!
    //播放/暂停
    var playOrPauseButton : UIButton!
    //暂停后屏幕显示播放按钮
    var playButtonAtStopTime : UIButton!
    //回调代理
    var delegate : MXPlayBottomViewDelegate!
    //当前播放状态
    var isPlaying : Bool = true
    //移动约束
    fileprivate var progressButtonConstraint : Constraint!
    //控制约束
    dynamic var totalSecond : Int = 0
    
    var secondForScale : Int = 0
    //当前播放位置
    var currentSecond : Int = 0
    
    fileprivate var scale : CGFloat = 0
    
    var multiple : CGFloat = 1
    
    fileprivate let totalWidth : CGFloat = UIScreen.main.bounds.size.height - 3 * 30 - 74
    
    var currentWidth : CGFloat = 0
    
    
    override init(frame : CGRect){
        super.init(frame: frame)
        
        //设置属性
        self.backgroundColor = UIColor.black
        
        self.alpha = 0.8
        //设置SubView
        self.initSubViews()
        //register kvo
        
        self.addObserver(self, forKeyPath: "totalSecond", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    fileprivate func initSubViews(){
        
        //设置back按钮
        self.backTenButton = UIButton()
        
        self.addSubview(self.backTenButton)
        
        self.settingButton(operation: self.backTenButton, action: #selector(MXPlayBottomView.backFormer), imageName: "back")
        
        self.backTenButton.snp.makeConstraints { (make : ConstraintMaker) in
            make.left.equalToSuperview().offset(4)
            
            make.width.equalTo(30)
            
            make.height.equalTo(30)
            
            make.top.equalToSuperview().offset(5)
        }
        
        //设置开始/停止按钮
        self.playOrPauseButton = UIButton()
        
        self.addSubview(self.playOrPauseButton)
        
        self.settingButton(operation: self.playOrPauseButton, action: #selector(MXPlayBottomView.startOrpause), imageName: "start")
        
        self.playOrPauseButton.snp.makeConstraints { (make : ConstraintMaker) in
            
            make.left.equalTo(self.backTenButton.snp.right).offset(5)
            
            make.width.equalTo(30)
            
            make.height.equalTo(30)
            
            make.top.equalTo(5)
        }
        
        //设置go按钮
        self.goTenButton = UIButton()
        
        self.addSubview(self.goTenButton)
        
        self.settingButton(operation: self.goTenButton, action: #selector(MXPlayBottomView.goNext), imageName: "go")
        
        self.goTenButton.snp.makeConstraints { (make : ConstraintMaker) in
            
            make.width.equalTo(30)
            
            make.left.equalTo(self.playOrPauseButton.snp.right).offset(4)
            
            make.height.equalTo(30)
            
            make.top.equalToSuperview().offset(5)
        }
        //设置当前观看时间label
        self.progressCurrentTimeLabel = UILabel()
        
        self.addSubview(self.progressCurrentTimeLabel)
        
        
        //设置总时间
        self.progressTotalTimeLabel = UILabel()
        
        self.progressTotalTimeLabel.textAlignment = .center
        
        self.progressTotalTimeLabel.textColor = .white
        
        self.progressTotalTimeLabel.font = UIFont.systemFont(ofSize: 10)
        
        self.addSubview(self.progressTotalTimeLabel)
        
        self.progressTotalTimeLabel.snp.makeConstraints { (make : ConstraintMaker) in
            
            make.width.equalTo(50)
            
            make.right.equalToSuperview().offset(-4)
            //follow change
            make.top.equalToSuperview().offset(25 / 2.0)
            
            make.height.equalTo(15)
        }
        
        //设置背景
        self.progressShadowView = UIImageView()
        
        self.addSubview(self.progressShadowView)
        
        //添加手势操作
        self.progressShadowView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(MXPlayBottomView.progressViewClick(gesture:))))
        
        self.progressShadowView.image = UIImage.init(named: "Line")
        
        //设置约束
        self.progressShadowView.snp.makeConstraints { (make : ConstraintMaker) in
            
            make.left.equalTo(self.goTenButton.snp.right).offset(4)
            
            make.right.equalTo(self.progressTotalTimeLabel.snp.left).offset(-4)
            
            make.top.equalToSuperview().offset(37 / 2.0)
            
            //改动需要改按钮，和，观看进度
            make.height.equalTo(3)
        }
        //初始化SawView
        self.progressSawView = UIImageView()
        
        self.addSubview(self.progressSawView)
        
        //设置Button
        self.progressButton = UIButton()
        
        self.addSubview(self.progressButton)
        
        self.progressButton.setBackgroundImage(UIImage.init(named: "progressButton"), for: UIControlState.normal)
        
        self.progressButton.snp.makeConstraints { (make : ConstraintMaker) in
            self.progressButtonConstraint =  make.left.equalTo(self.progressShadowView.snp.left).offset(0).constraint
            
            make.width.equalTo(10)
            
            //follow change
            make.top.equalToSuperview().offset(15)
            
            make.height.equalTo(10)
        }
        //设置已看
        self.progressSawView.image = UIImage.init(named: "playProgress")
        
        self.progressSawView.snp.makeConstraints { (make : ConstraintMaker) in
            make.left.equalTo(self.progressShadowView.snp.left).offset(0)
            make.right.equalTo(self.progressButton.snp.left).offset(2)
            //follow change
            make.top.equalToSuperview().offset(35 / 2.0)
            
            make.height.equalTo(5)
        }
        //添加手势
        self.progressSawView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(MXPlayBottomView.progressSawClick(gesture:))))

        //设置暂停按钮
        self.playButtonAtStopTime = UIButton()
        
        self.addSubview(self.playButtonAtStopTime)
        
        self.settingButton(operation: self.playButtonAtStopTime, action: #selector(MXPlayBottomView.startOrpause), imageName: "pause")
        
        //默认不显示
        self.playButtonAtStopTime.alpha = 0
        
        self.playButtonAtStopTime.snp.makeConstraints { (make : ConstraintMaker) in
            //居中显示
        }
        
        //设置时间长度
        if self.totalSecond == 0 {
            self.progressTotalTimeLabel.text = "--:--:--"
        }else{
            self.progressTotalTimeLabel.text = MXFilmViewModel.durationToTime(time: self.totalSecond)
        }
    }
    
    //按钮的设置操作
    private func settingButton(operation : UIButton,action : Selector,imageName : String) {
        operation.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        
        operation.setBackgroundImage(UIImage.init(named: imageName), for: UIControlState.normal)
    }
    
    //MARK: Gesture
    //未看进度条的点击
    func progressViewClick(gesture : UITapGestureRecognizer){
        //识别位置
        let x = gesture.location(in: self.progressShadowView).x
        //判断百分比,转化为秒数
        let destinationSecond = Double(self.totalSecond) * Double(x / self.totalWidth)
        //改变当前约束
        //ERROR: 约束值
        self.progressButtonConstraint.update(offset: x)
        self.progressButtonConstraint.activateIfNeeded(updatingExisting: true)
        //改变totalSecond
        self.totalSecond += Int(destinationSecond)
        //通知代理切换位置
        if self.delegate != nil {
            self.delegate.operation(with: self, type: .seekTime, seekTime: destinationSecond, completion: {
                //刷新UI
                
            })
        }
    }
    //已经观看的进度点击
    func progressSawClick(gesture : UITapGestureRecognizer){
        //获取点击位置
        let x = gesture.location(in: self.progressSawView).x
        //移动按钮到指定位置
        let destinationPositionX = x - 3 * 30 - 12
        //改变进度值
        self.currentWidth = destinationPositionX
        self.progressButtonConstraint.update(offset: self.currentWidth)
        self.progressButtonConstraint.activateIfNeeded(updatingExisting: true)
        //传递时间
        let time = Double(self.totalSecond) * Double((destinationPositionX / self.totalWidth))
        //改变总时间
        self.totalSecond -= Int(time)
        //通知代理
        if self.delegate != nil {
            self.delegate.operation(with: self, type: .seekTime, seekTime: time, completion: nil)
        }
    }
    
    //时间添加在按钮上
    //进度条的移动
    func progressViewMove(gesture : UIPanGestureRecognizer){
        //将x转换为合适的单位
        let x = gesture.translation(in: self).x
        //转换算法
        
        //通知代理切换位置
        if self.delegate != nil {
            self.delegate.operation(with: self, type: .seekTime, seekTime: Double(x), completion: {
                //刷新UI
                
            })
        }
    }
    //进度条点击
    func progressButtonClick(gesture : UITapGestureRecognizer){
        
    }

    //MARK: Action
    //前进
    func goNext(){
        //回退
        //通知代理切换位置
        if self.delegate != nil {
            self.delegate.operation(with: self, type: .right, seekTime: nil, completion: {
                //刷新UI
                
            })
        }
    }
    //后退
    func backFormer(){
        //回退
        //通知代理切换位置
        if self.delegate != nil {
            self.delegate.operation(with: self, type: .left, seekTime: nil, completion: {
                //刷新UI
                
            })
        }
    }
    //开始/暂停
    func startOrpause(){
        if self.isPlaying {
            //停止
            //设置按钮
            self.playOrPauseButton.setBackgroundImage(UIImage.init(named: "pause"), for: UIControlState.normal)
            //通知代理切换位置
            if self.delegate != nil {
                self.delegate.operation(with: self, type: .pause, seekTime: nil, completion: {
                    //刷新UI
                    
                })
            }
        }else{
            //开始
            //设置按钮
            self.playOrPauseButton.setBackgroundImage(UIImage.init(named: "start"), for: UIControlState.normal)
            //通知代理切换位置
            if self.delegate != nil {
                self.delegate.operation(with: self, type: .start, seekTime: nil, completion: {
                    //刷新UI
                    
                })
            }
        }
        
        self.isPlaying = !self.isPlaying
    }
    
    //刷新UI
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let _ = change?[.newKey] {
            //修改UI
            if self.totalSecond < 0 {
                self.progressTotalTimeLabel.text = "--:--:--"
            }else{
                DispatchQueue.main.async {
                    self.progressTotalTimeLabel.text = MXFilmViewModel.durationToTime(time: self.totalSecond)
                }
               
            }
        }
    }
}

//MARK: Refresh
extension MXPlayBottomView {
    
    func nextSecond(){
        //计算一下，如何匹配
        if self.scale == 0 {
            self.scale = self.totalWidth / CGFloat(self.secondForScale)
        }
        if self.totalSecond - 1 <= 0 {
            self.totalSecond = 0
        }else{
            self.totalSecond -= 1
        }
        self.currentWidth += (self.scale * self.multiple)
        //不能超过范围
        if self.currentWidth > self.totalWidth - 7 {
            self.currentWidth = self.totalWidth - 7
        }else if self.currentWidth < 0 {
            self.currentWidth = 0
        }
        self.progressButtonConstraint.update(offset:self.currentWidth)
        self.progressButtonConstraint.activateIfNeeded(updatingExisting: true)
        //改变倍数
        self.multiple = 1.0
    }
}
