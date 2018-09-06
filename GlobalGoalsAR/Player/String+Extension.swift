//
//  String+Extension.swift
//  CustomPlayer
//
//  Created by 钱权浩 on 2018/9/6.
//  Copyright © 2018年 qqh. All rights reserved.
//


import UIKit

extension String{
    
    static func convertTimeWithSecond(second: TimeInterval) -> String{
        
        let date = Date(timeIntervalSince1970: second)
        let fmt = DateFormatter()
        
        if second/3600>=1 {
            fmt.dateFormat = "HH:mm:ss"
        }else
        {
            fmt.dateFormat = "mm:ss"
        }
        
        return fmt.string(from: date)
    }
}
