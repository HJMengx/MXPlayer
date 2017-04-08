//
//  MXPlayViewController.swift
//  MXPlayer
//
//  Created by mx on 2017/2/3.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

enum MXFilmPresentedType : Int{
    case reading = 0
    case willReading
    case security
}

class MXPlayViewController: UIViewController {
    
    //播放View
    var playerView : IJKMediaPlayback!
    
    //film
    var selectedFilms : [Film]!
    
    var model : MXFilmViewModel = MXFilmViewModel.share
    
    //当前进度
    var currentTime : Int = 0
    
    //当前播放第几个
    var currentUrl : Int = 0
    
    //播放，暂停状态
    
    //计时器
    var timer : Timer!
    
    //约束
    //显示上下控件
    var isShowsControlTool : Bool = true
    
    var topViewConstraint : Constraint!
    
    var bottomViewConstraint : Constraint!
    
    //界面控制View
    var topView : MXPlayTopView!
    
    var bottomView : MXPlayBottomView!
    
    //操作进度显示
    var operationProgressLabel : UILabel!
    
    //播放结束
    fileprivate var isComplete : Bool = false
    
    //是否第一次进入
    fileprivate var isFirstEnter : Bool = true
    
    fileprivate var isNewSource : Bool = true
    
    fileprivate var isSeeking : Bool = false
    
    //是否是被锁屏唤醒的
    private var isBecomeActive : Bool = false
    
    //跳转过来的ViewController
    var filmsViewController : UIViewController!
    
    var presented : MXFilmPresentedType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置横屏
        mxDelegate.isLandScape = true
        
        //Setting
        self.initSubViews()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //取消计时器
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //默认横屏,不允许旋转屏幕
        //self.cancelProtrait()
        
        self.registerNotification()
        
        self.isFirstEnter = true
        //设置横屏
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
    }
    
    //MARK: Register Notification
    private func registerNotification(){
        //注册通知
        //playStatus
        NotificationCenter.default.addObserver(self, selector: #selector(MXPlayViewController.startPlay), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
        //loadStatus
        NotificationCenter.default.addObserver(self, selector: #selector(MXPlayViewController.loadStatus), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: nil)
        //锁屏通知
        NotificationCenter.default.addObserver(self, selector: #selector(MXPlayViewController.activeFromLock), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    //从锁屏激活的时候调用
    func activeFromLock(){
        //判断当前屏幕
        if UIDevice.current.orientation != .landscapeLeft {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        //判断播放状态
        if self.playerView != nil && !self.playerView.isPlaying() {
            if Int(self.playerView.currentPlaybackTime) != self.selectedFilms[self.currentUrl].seeingTime {
                self.playerView.currentPlaybackTime = Double(self.selectedFilms[self.currentUrl].seeingTime)
            }
            //继续播放
            self.playerView.play()
        }
        //设置唤醒
        self.isBecomeActive = true
    }
    //结束播放
    func backToDirectory(){
        //停止播放
        if self.playerView.isPlaying() {
            
            self.playerView.shutdown()
        }
        //保存记录信息
        self.updateAndSave()
        //刷新一次数据
        self.model.getFilmFromLocal()
        //刷新上一个页面
        switch self.presented.rawValue {
        case 0:
            //reading
            (self.filmsViewController as! MXReadingFilmsViewController).filmsView.reloadData()
            break
            
        case 1:
            //will reading
            (self.filmsViewController as! MXWillReadingFilmsController).filmsView.reloadData()
            break
            
        default:
            //secret
            (self.filmsViewController as! MXSecurityFilmsViewController).filmsView.reloadData()
            break
        }
        //退出当前页面
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //转回竖屏
        //改变屏幕
        mxDelegate.isLandScape = false
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //这个页面不支持旋转
    /*
    override func shouldAutorotate() -> Bool {
        return false
    }
    */
    private func cancelProtrait(){
        self.setValue(false, forKey: "shouldAutorotate")
    }
    
    //MARK: loadStatus
    func loadStatus(){
        switch self.playerView.loadState {
        case IJKMPMovieLoadState.playthroughOK:
            //设置
            
            break
            
        case IJKMPMovieLoadState.playable:
            
            break
        default:
            //IJKMPMovieLoadState.stalled

            break
        }
    }
    //MARK: playStatus
    func startPlay(){
        //    IJKMPMoviePlaybackStateStopped,        停止
        //    IJKMPMoviePlaybackStatePlaying,        正在播放
        //    IJKMPMoviePlaybackStatePaused,         暂停
        //    IJKMPMoviePlaybackStateInterrupted,    打断
        //    IJKMPMoviePlaybackStateSeekingForward, 快进
        //    IJKMPMoviePlaybackStateSeekingBackward 快退
        //在这里传递值
        switch self.playerView.playbackState {
        case .stopped:
            //播放完成
            //置空
            self.timer.invalidate()
            self.timer = nil
            //设置播放完成
            self.isComplete = true
            self.isSeeking = false
            //自动播放下一个资源
            self.slideNextSource()
            break
        case .paused:
            //暂停
            //停止计时器
            self.isComplete = false
            self.isSeeking = false
            break
        case .interrupted:
            //中断，资源问题
            break
        case .seekingBackward:
            //后退
            self.isComplete = false
            self.isSeeking = true
            self.playAndSettingBottomView()
            break
        case .seekingForward:
            //快进
            self.isComplete = false
            self.isSeeking = true
            self.playAndSettingBottomView()
            break
        default:
            //playing
            self.isComplete = false
            self.isSeeking = false
            self.playAndSettingBottomView()
            //设置进度
            if self.isFirstEnter && !self.isBecomeActive{
                //必须在加载完毕之后才能设置
                //设定播放位置
                //指定位置开始播放
                if self.currentTime != 0 {
                    //从头开始,如果看到最后一秒
                    if self.currentTime >= Int.init(self.playerView.duration) {
                        self.currentTime = 0
                        self.selectedFilms[self.currentUrl].seeingTime = 0
                    }
                }
                self.isFirstEnter = false
            }
            break
        }
        //计时器
        self.settingTimer()
    }
    
    func settingTimer(){
        //会多次调用，计时器重复添加
        //重新启动定时器
        //添加计时器
        if self.timer == nil && !self.isComplete {
            self.timer = Timer.init(timeInterval: 1, target: self, selector: #selector(MXPlayViewController.nextSecond), userInfo: nil, repeats: true)
            //添加到主循环
            RunLoop.main.add(self.timer, forMode: RunLoopMode.defaultRunLoopMode)
            //self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MXPlayViewController.nextSecond), userInfo: nil, repeats: true)
        }
    }
    
    //播放相关设置
    
    private func settingBottomView(){
        
    }
    
    private func playAndSettingBottomView(){
        
        //设置电影总长度
        if !self.isSeeking && self.isFirstEnter && self.isNewSource {
            
            self.selectedFilms[self.currentUrl].duration = Int(self.playerView.duration)
            //刷新状态总时间
            self.bottomView.totalSecond = self.selectedFilms[self.currentUrl].duration
            self.bottomView.secondForScale = self.selectedFilms[self.currentUrl].duration
            //相关操作
            self.playerView.currentPlaybackTime = Double(self.currentTime)
            
            //改变进度条
            self.bottomView.totalSecond -= self.currentTime
            self.bottomView.currentWidth = 0
            self.bottomView.multiple = CGFloat(self.playerView.currentPlaybackTime)
            
            self.isNewSource = false
        }
    }
    
    fileprivate func initSubViews(){
        
        //异步加载，并提示信息
        
        DispatchQueue.init(label: "loadFilm", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: nil).async {
            //刷新
            DispatchQueue.main.async {
                //加载播放
                self.playMovie()
                //添加View
                //self.view.addSubview(self.playerView.view)
                //设置属性
                self.view.backgroundColor = UIColor.black
                //设置顶部View
                self.topView = MXPlayTopView.init(frame: CGRect())
                
                self.topView.delegate = self
                
                self.topView.titleLable.text = self.selectedFilms[self.currentUrl].name
                
                self.view.addSubview(self.topView)
                
                //设置约束
                self.topView.snp.makeConstraints { (make : ConstraintMaker) in
                    
                    make.width.equalToSuperview()
                    
                    make.left.equalToSuperview().offset(0)
                    
                    make.height.equalTo(40)
                    
                    self.topViewConstraint =  make.top.equalToSuperview().offset(0).constraint
                }
                
                //设置底部View
                self.bottomView = MXPlayBottomView.init(frame: CGRect())
                
                self.bottomView.delegate = self
                
                self.bottomView.totalSecond = self.selectedFilms[self.currentUrl].duration
                
                self.view.addSubview(self.bottomView)
                //设置约束
                self.bottomView.snp.makeConstraints { (make : ConstraintMaker) in
                    make.width.equalToSuperview()
                    
                    make.left.equalToSuperview().offset(0)
                    
                    make.height.equalTo(40)
                    
                    self.bottomViewConstraint = make.bottom.equalToSuperview().offset(0).constraint
                }
                
                //设置快进提示
                self.operationProgressLabel = UILabel()
                
                self.view.addSubview(self.operationProgressLabel)
                
                self.operationProgressLabel.font = UIFont.systemFont(ofSize: 20)
                //默认不显示
                self.operationProgressLabel.alpha = 0
                
                self.operationProgressLabel.textAlignment = .center
                
                self.operationProgressLabel.textColor = UIColor.white
                
                self.operationProgressLabel.backgroundColor = UIColor.black
                
                self.operationProgressLabel.snp.makeConstraints({ (make : ConstraintMaker) in
                    make.width.equalTo(200)
                    make.top.equalToSuperview().offset(self.view.frame.size.width / 2 - 40)
                    make.height.equalTo(80)
                    make.left.equalToSuperview().offset(self.view.frame.size.height / 2 - 100)
                })
                //隐藏ControlTool
                /* 可以不用
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    //隐藏
                    if self.isShowsControlTool {
                        self.hideAnimation()
                        self.isShowsControlTool = !self.isShowsControlTool
                    }
                }
                */
            }
        }

    }
}

//控制控件是否显示,以及手势操作
extension MXPlayViewController {
    
    func translationToSeekTime(gesture : UIPanGestureRecognizer){
        //设置一下 如果还没有播放 不允许操作

        //ERROR:时间还不对
        switch gesture.state {
        case .began:
            //快进不需要停止
            //停止定时器
            //self.timer.invalidate()
            //self.timer = nil
            //显示进度提示1
            self.operationProgressLabel.alpha = 0.6
            //当前时间
            let currentTimeString = MXFilmViewModel.durationToTime(time: self.currentTime)
            
            self.operationProgressLabel.text = String.init(format: "%@/%@", currentTimeString,currentTimeString)
            break
        case .cancelled:
            
            break
            
        case .changed:
            //改变值
            //获取位移
            let translation = gesture.translation(in: self.playerView.view)
            //前进/后退的秒数，有正负之分
            let forwardSecond = translation.x
            //转换算法
            let scale = forwardSecond / self.playerView.view.frame.size.width
            
            let destinationSecond = Double(scale) * self.playerView.duration
            //时间
            var time = self.currentTime + Int(destinationSecond)
            
            //判断时间是否过线
            if time < 0 {
                time = 0
            }else if time > Int(self.playerView.duration){
                time = Int(self.playerView.duration)
            }
            
            let destinationTime = MXFilmViewModel.durationToTime(time: time)
            
            self.operationProgressLabel.text = String.init(format: "%@/%@", destinationTime,MXFilmViewModel.durationToTime(time: Int(self.playerView.duration)))
            
            break
            
        case .ended:
            //停止显示快进/快退提示
            self.operationProgressLabel.alpha = 0
            
            if self.playerView.isPlaying() {

                //判断是左移还是右移
                
                //获取位移
                let translation = gesture.translation(in: self.playerView.view)
                //前进/后退的秒数，有正负之分
                let forwardSecond = translation.x
                //转换算法
                let scale = forwardSecond / self.playerView.view.frame.size.width
                
                var destinationSecond = Double(scale) * self.playerView.duration
                //判断时间是否符合
                if destinationSecond + self.playerView.currentPlaybackTime > self.playerView.duration {
                    destinationSecond = self.playerView.duration - self.playerView.currentPlaybackTime - 1
                }else if destinationSecond + self.playerView.currentPlaybackTime < 0 {
                    destinationSecond = -self.playerView.currentPlaybackTime
                }
                //执行快进
                self.playerView.currentPlaybackTime += destinationSecond
                //同时设置相关属性
                self.selectedFilms[self.currentUrl].seeingTime += Int(destinationSecond)
                self.currentTime += Int(destinationSecond)
                //要通知BottomView进行进度条移动，快进了多少秒
                //改变ToalSecond和mutile约束改变倍率
                self.bottomView.totalSecond -= Int(destinationSecond)
                self.bottomView.multiple = CGFloat(destinationSecond)
                //
            }
            break
        case .failed:
            
            break
            
        default:
            
            break
        }

    }
    
    func tapInPlayView(){
        if self.isShowsControlTool {
            //隐藏
            self.hideAnimation()
        }else{
            //显示
            self.showsAnimation()
            //启动一个延时操作，如果没有是手动取消
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                //隐藏
                if self.isShowsControlTool {
                    //隐藏
                    self.hideAnimation()
                }
            })
        }
        self.isShowsControlTool = !self.isShowsControlTool
    }
    
    private func  showsAnimation(){
        
        self.topViewConstraint.update(inset: 0)
        self.topViewConstraint.activateIfNeeded(updatingExisting: true)
        self.bottomViewConstraint.update(inset: 0)
        self.bottomViewConstraint.activateIfNeeded(updatingExisting: true)
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideAnimation(){
        self.topViewConstraint.update(inset: -42)
        self.topViewConstraint.activateIfNeeded(updatingExisting: true)
        self.bottomViewConstraint.update(inset: -42)
        self.bottomViewConstraint.activateIfNeeded(updatingExisting: true)
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

//控制横屏大小的问题
extension MXPlayViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        switch UIDevice.current.orientation {
            
        case .landscapeRight,.landscapeLeft:
            
            self.playerView.view.frame = CGRect.init(x: CGFloat(0), y: CGFloat(0), width: self.view.frame.size.height, height: self.view.frame.size.width)
            break
        default:
            break
        }
        
        super.viewWillTransition(to: size, with: coordinator)
        
        
        //开始播放
        self.playerView.prepareToPlay()
    }
}

//Delegate
//MARK: delegate
extension MXPlayViewController : MXPlayTopViewDelegate,MXPlayBottomViewDelegate {
    func operation(with: MXPlayTopView, type: MXPlayViewOperationType) {
        if type == .back {
            self.backToDirectory()
        }
    }
    
    func operation(with: MXPlayBottomView, type: MXPlayBottomOperationType, seekTime: Double?, completion: (() -> Void)?) {
        //不管哪一种都应该先停止Timer
        self.timer.invalidate()
        self.timer = nil
        switch type {
        case .left:
            self.slideFormerSource()
            break
        case .right:
            self.slideNextSource()
            break
        case .start:
            self.pauseOrStart()
            break
        case .seekTime:
            self.seekTime(duration: Int(seekTime!))
            break
        case .pause:
            self.pauseOrStart()
            break
        default:
            //不存在这种情况
            assertionFailure("这种情况不存在")
            break
        }
        //执行回调
        completion?()
    }
}

//MARK: control
extension MXPlayViewController {
    //回到上一个页面
    func backToSceneView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //next ten second
    func moveNextTenSecond(){
        self.playerView.currentPlaybackTime += 10
    }
    
    //back ten second
    func backTenSecond(){
        self.playerView.currentPlaybackTime -= 10
    }
    
    //stop/start
    func pauseOrStart(){
        if !self.playerView.isPlaying() {
            self.playerView.play()
        }else{
            self.playerView.pause()
        }
    }
    
    //播放
    fileprivate func playMovie(){
        //从parentView去除
        if self.playerView != nil {
            
            self.playerView.view.removeFromSuperview()
        }
        //初始化
        self.playerView = IJKFFMoviePlayerController.init(contentURL: URL.init(string: self.selectedFilms[self.currentUrl].fileUrl)!, with: nil)
        
        //默认横屏？
        self.view.insertSubview(self.playerView.view, at: 0)
        //上次播放位置开始播放
        self.currentTime = self.selectedFilms[self.currentUrl].seeingTime
        //设置属性
        self.playerView.view.backgroundColor = UIColor.black
        //添加手势
        self.playerView.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(MXPlayViewController.tapInPlayView)))
        //滑动手势
        self.playerView.view.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(MXPlayViewController.translationToSeekTime(gesture:))))
    }
    //slide source
    func slideNextSource(){
        //只有一个电影的时候
        guard self.selectedFilms.count != 1 else {
            SVProgressHUD.showError(withStatus: "没有更多电影了")
            self.settingTimer()
            return
        }
        //先停止播放
        self.playerView.shutdown()
        //刷新并保存
        self.updateAndSave()
        //加载下一个资源
        self.currentUrl += 1
        if self.currentUrl >= self.selectedFilms.count {
            //提示信息
            SVProgressHUD.showError(withStatus: "没有更多电影了")
            
            self.currentUrl = 0
        }
        //改变属性
        self.isFirstEnter = true
        self.isNewSource = true
        //加载
        self.playMovie()
        //修改状态栏
        self.topView.titleLable.text = self.selectedFilms[self.currentUrl].name
        //当前进度什么都需要更改
        
        //播放
        if !self.playerView.isPlaying() {
            self.playerView.prepareToPlay()
        }
    }
    
    func updateAndSave(){
        //添加到数据库
        if self.isComplete {
            self.selectedFilms[self.currentUrl].seeingTime = 0
        }
        
        //判断是否已经添加过了
        //就刷新
        self.selectedFilms[self.currentUrl].isSeeing = true
        operationDataBase(film: self.selectedFilms[self.currentUrl], type: .updateSeeingTime)
    }
    
    func slideFormerSource(){
        //只有一个电影的时候
        guard self.selectedFilms.count != 1 else {
            SVProgressHUD.showError(withStatus: "没有更多电影了")
            self.settingTimer()
            return
        }
        //先停止播放
        self.playerView.shutdown()
        //刷新并保存
        self.updateAndSave()
        //加载下一个资源
        self.currentUrl -= 1
        if self.currentUrl < 0{
            //提示信息
            SVProgressHUD.showError(withStatus: "没有更多电影了，重新播放")
            
            self.currentUrl = self.selectedFilms.count - 1
        }
        self.isFirstEnter = true
        self.isNewSource = true
        //加载
        self.playMovie()
        //修改状态栏
        self.topView.titleLable.text = self.selectedFilms[self.currentUrl].name
        //播放
        if !self.playerView.isPlaying() {
            self.playerView.prepareToPlay()
        }
    }
    
    //没有调用
    //seek time
    func seekTime(duration : Int){
        self.playerView.currentPlaybackTime += Double(duration)
        self.currentTime += duration
        self.selectedFilms[self.currentUrl].seeingTime += duration
    }
}

extension MXPlayViewController {
    func nextSecond(){
        //当前播放进度+
        self.currentTime = Int(self.playerView.currentPlaybackTime)
        self.selectedFilms[self.currentUrl].seeingTime = self.currentTime
        //然后改变观看进度栏
        self.bottomView.nextSecond()
    }
}
