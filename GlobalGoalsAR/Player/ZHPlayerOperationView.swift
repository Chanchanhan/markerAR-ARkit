//
//  PlayerOperationView.swift
//  Player
//
//
//  Created by 钱权浩 on 2018/9/6.
//  Copyright © 2018年 qqh. All rights reserved.
//


import UIKit

typealias sliderProgressChangedCallBack = (_ sliderProgress: TimeInterval)->()

enum screenType{
    
    case fullScreen
    case smallScreen
}

class ZHPlayerOperationView: UIView {
   
    //滑块是否在拖动
    var isSlider: Bool = false
    
    //是否隐藏topBar bottomBar 默认暂时不隐藏
    var ishiddenOperationBar: Bool = true
    
    //是否在滑动
    var sliderChanged: sliderProgressChangedCallBack?
    
    //目前屏幕状态 是small 还是fullScreen
    var screenType: screenType = .smallScreen
    
    //定时器
    fileprivate var timer: Timer?
    //上面的bar
    @IBOutlet weak var topBar: UIView!
    //底部的bar
    @IBOutlet weak var bottomBar: UIView!
    //用来点击的View
    @IBOutlet weak var tapView: UIView!
    //播放
    @IBOutlet weak var play: UIButton!
    //缩放(旋转)
    @IBOutlet weak var rotation: UIButton!

    //当前时间
    @IBOutlet weak var currentTime: UILabel!
    
    //总时间
    @IBOutlet weak var totalTime: UILabel!
    
    //缓冲进度
    @IBOutlet weak var loadedProgress: UIProgressView!
    
    //播放进度
    @IBOutlet weak var playProgress: UISlider!
    
    //父控件
    fileprivate var superView: ZHPlayerView?{
        
        guard let view = self.superview else {
            
            return nil
        }
        
        return view as? ZHPlayerView
    }
    
    //MARK:- 创建操作视图
    class func operationView() -> ZHPlayerOperationView{
        
        return Bundle.main.loadNibNamed("ZHPlayerOperationView", owner: self, options: nil)?.first as! ZHPlayerOperationView
    }
    
    //1.正在拖动
    @IBAction func dragging(_ sender: UISlider) {
        
        isSlider = true
        
        if sliderChanged != nil {
            
            sliderChanged!(TimeInterval(sender.value))
        }
        
    }
    
    //2.手指按下
    @IBAction func touchDown(_ sender: UISlider) {
        
        superView?.Pause()
        
    }
    
    //3.手指抬起
    @IBAction func touchUp(_ sender: UISlider) {
     
        superView?.Play()
        isSlider = false
    }
    
    //暂停或开始
    @IBAction func playorPause(_ sender: UIButton) {
        
        play.isSelected = !play.isSelected
        
        if play.isSelected == true {
            
            superView?.Play()
        }else
        {
            superView?.Pause()
        }
    }
    
    //旋转屏幕
    @IBAction func rotateScreen(_ sender: UIButton) {
        
        guard let superView = superView else {
            
            return
        }
        
        if screenType == .smallScreen {
            
            let height = UIScreen.main.bounds.width
            let width = UIScreen.main.bounds.height
            let frame = CGRect(x: (height - width)/2, y: (width - height)/2, width: width, height: height)
            
            //全屏状态
            screenType = .fullScreen
            
            UIView.animate(withDuration: 0.3, animations: {
                
                superView.frame = frame
                superView.transform = CGAffineTransform(rotationAngle: (CGFloat)(M_PI_2))
            
            })
            
            rotation.isSelected = true
        
            UIApplication.shared.keyWindow?.addSubview(superView)
        }else
        {
        
           let orientation = UIDevice.current.orientation
            
            if orientation == .portrait
            {
                //全屏状态
                UIView.animate(withDuration: 0.3, animations: {
                    
                    superView.transform = CGAffineTransform.identity
                    superView.frame = superView.originalFrame
                })
                
                screenType = .smallScreen
                
                superView.originalSuperView?.addSubview(superView)
            }

            rotation.isSelected = false
        }
        
       
    }
    
    deinit {
        
        removeTimer()
        
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- operationBar的操作
extension ZHPlayerOperationView{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //1.重新设置下slider的thumb图片
        self.playProgress.setThumbImage(UIImage(named:"icmpv_thumb_light"), for: .normal)
        self.playProgress.setThumbImage(UIImage(named:"icmpv_thumb_light"), for: .highlighted)
        
        //2.给tapview添加一个手势
        //添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
        tapView.addGestureRecognizer(tap)
        
        //3.添加通知
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(noti:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    
    @objc fileprivate func tap(tap: UITapGestureRecognizer)
    {
        //保险起见，添加定时器的之前先移除定时器
        removeTimer()
        
        //添加定时器
        addTimer()
        
        handleBar()
    }
    
    //操作handleBar
    fileprivate func handleBar(){
        
        if ishiddenOperationBar == true {
            
            UIView.animate(withDuration: 0.25, animations: {
                
//                self.topBar.transform = CGAffineTransform(translationX: 0, y: -40)
                self.bottomBar.transform = CGAffineTransform(translationX: 0, y: 40)
            })
        }else
        {
            UIView.animate(withDuration: 0.25, animations: {
                
//                self.topBar.transform = CGAffineTransform.identity
                self.bottomBar.transform = CGAffineTransform.identity
            })
        }
        
        //操作以后改变标志位的状态
        ishiddenOperationBar = !ishiddenOperationBar
    }
}

//MARK:- 对定时器的操作方法
extension ZHPlayerOperationView{
    
    ///创建定时器的方法
    func addTimer(){
        
        timer = Timer(timeInterval: 6.0, target: self, selector: #selector(hiddenOperationBar), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    func removeTimer(){
        
        timer?.invalidate() //从运行循环中移除
        timer = nil
    }
    
    //隐藏操作的bar
    @objc private func hiddenOperationBar(){
        
        handleBar()
        
        //操作完以后移除定时器
        removeTimer()
    }
}

//MARK:- 屏幕旋转
extension ZHPlayerOperationView{
    
    @objc fileprivate func orientationChanged(noti: NSNotification){
        
        //1.获取屏幕现在的方向
        let orientation = UIDevice.current.orientation
        
        switch orientation {
     
        case .portrait:
            
            guard let superView = superView else {
                
                return
            }
        
            if screenType == .fullScreen {
                
                screenType = .smallScreen
                rotation.isSelected = false
                
                superView.transform = CGAffineTransform.identity
                superView.frame = superView.originalFrame
                
            }
            
        case .landscapeLeft:
            
            if screenType == .smallScreen
            {
                screenType = .fullScreen
                rotation.isSelected = true
            }
            
            fullScreenWithOrientation(orientation: orientation)
            
        case .landscapeRight:
            
            if screenType == .smallScreen
            {
                screenType = .fullScreen
                rotation.isSelected = true
            }
            
            fullScreenWithOrientation(orientation: orientation)
        
        default: break
            
            
        }
    }
    
    private func fullScreenWithOrientation(orientation: UIDeviceOrientation)
    {
        
        guard let superView = superView else {
            
            return
        }
        
        superView.removeFromSuperview()
        superView.transform = CGAffineTransform.identity
        
        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        
        superView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIApplication.shared.keyWindow?.addSubview(superView)
    }
}
