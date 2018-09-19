//
//  ZHPlayerView.swift
//  ZHPlayer
//
//  Created by 钱权浩 on 2018/9/6.
//  Copyright © 2018年 qqh. All rights reserved.
//


import UIKit
import AVFoundation

class ZHPlayerView: UIView {
    
    var urlSrting: String?{
        
        didSet{
            
            guard let urlSrting = urlSrting, let url = URL(string: urlSrting) else {
                
                return
            }
            
            playerItem = AVPlayerItem(url: url)
            
            player.replaceCurrentItem(with: playerItem)
            addObserverProperty()
            
            playerTimeObserve = observePlayerTimeWithItem(item: playerItem!)
            player.volume = 0.0
        }
    }
    
    func Play(){
        player.play()
    }
    
    func Pause(){
        player.pause()
    }
   
    fileprivate lazy var operationview: ZHPlayerOperationView = ZHPlayerOperationView.operationView()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        originalFrame = frame
        
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    
    }
    
    //filePrivate  lazy
    fileprivate var playerItem: AVPlayerItem?
    
    fileprivate lazy var player: AVPlayer = AVPlayer()
    
    lazy var playerLayer: AVPlayerLayer = {
        
        let playerLayer = AVPlayerLayer.init(player: self.player)
        playerLayer.videoGravity = AVLayerVideoGravity.resize
        return playerLayer
    }()

    fileprivate var totalTime: TimeInterval{
        
        guard let totalTime = playerItem?.duration else {
            
            return 0
        }
        
        return CMTimeGetSeconds(totalTime)
    }
    
    fileprivate var loadedTime: TimeInterval{
        
        let loadedTimeRange = playerItem?.loadedTimeRanges
        
        guard let timeRange = loadedTimeRange?.first as? CMTimeRange else {
            
            return 0
        }
        
        let startTime: TimeInterval = CMTimeGetSeconds(timeRange.start)
        let durationTime: TimeInterval = CMTimeGetSeconds(timeRange.duration)
        
        return startTime + durationTime
    }
    
    fileprivate var playerTimeObserve: Any?
    
    var originalFrame: CGRect = CGRect()
    
    var originalSuperView: UIView?
    
    deinit {
        
        player.removeObserver(self, forKeyPath: "status")
        player.removeObserver(self, forKeyPath: "loadedTimeRanges")
        
        player.removeTimeObserver(playerTimeObserve!)
        playerTimeObserve = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        operationview.frame = self.bounds
        playerLayer.frame = self.layer.bounds
    }
    
    override func didMoveToSuperview() {
        
        guard let superview = self.superview else {
            
            return
        }
        
        if !superview.isKind(of: UIWindow.self){
            
            originalSuperView = superview
        }
    }
}

//MARK:- privateFunc
extension ZHPlayerView{
    
    fileprivate func setupUI(){
        self.layer.addSublayer(playerLayer)
        addSubview(operationview)
        operationview.sliderChanged = {[weak self] (value) in
            
            let time = CMTime(seconds: value, preferredTimescale: CMTimeScale(1*UInt64(NSEC_PER_SEC)))
            
            self?.playerItem?.seek(to: time)
        }
        Thread.detachNewThreadSelector(#selector(CheckPlay), toTarget: self, with: nil)

    }
    @objc func CheckPlay()
    {
        while(true){
            if(operationview.screenType == .fullScreen){
                DispatchQueue.main.async {
                    self.playerLayer.isHidden  = false
                }
                player.volume  = 1
            }else{
                DispatchQueue.main.async {
                    self.playerLayer.isHidden  = true
                }
            }
            
        }
    }
    func Full()-> Bool{
        return operationview.screenType == .fullScreen
    }
    fileprivate func addObserverProperty(){
        
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
    }
    
    fileprivate func observePlayerTimeWithItem(item: AVPlayerItem) -> Any{
        
        let observePlayerTime = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 30), queue: DispatchQueue.main, using: {[weak self] (time) in
            
            let currentTimeSecond = TimeInterval(item.currentTime().value)/TimeInterval(item.currentTime().timescale)
            
            self?.operationview.playProgress.value = Float(currentTimeSecond)
            self?.operationview.currentTime.text = String.convertTimeWithSecond(second: currentTimeSecond)
        })
        
        return observePlayerTime
    }
}

extension ZHPlayerView{
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            
            let status = change?[NSKeyValueChangeKey.newKey] as? Int
            /**
             
             unknown 0
             readyToPlay 1
             failed  2
             */
            if status == 1 {
                
                let time = playerItem?.duration
                
                var second: TimeInterval = 0
                
                if let time = time {
                    
                    second = CMTimeGetSeconds(time)
                }
                
                operationview.playProgress.maximumValue = Float(second)
                operationview.totalTime.text = String.convertTimeWithSecond(second: second)
                player.play()
                
                operationview.addTimer()
            }else
            {
                NSLog("Fail to play")
            }
        }else if keyPath == "loadedTimeRanges"
        {
            if operationview.isSlider == false
            {
                let loadedTime = self.loadedTime
                let totalTime = self.totalTime 
                
                operationview.loadedProgress.setProgress(Float(CGFloat(loadedTime/totalTime)), animated: true)
            }
        }
    }
    
}



