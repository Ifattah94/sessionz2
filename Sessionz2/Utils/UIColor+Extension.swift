//
//  UIColor+Extension.swift
//  Sessionz2
//
//  Created by Iram Fattah on 3/4/20.
//  Copyright © 2020 Iram Fattah. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red: 17, green: 154, blue: 237)
    static let outlineStrokeColor = UIColor.rgb(red: 234, green: 46, blue: 111)
    static let trackStrokeColor = UIColor.rgb(red: 56, green: 25, blue: 49)
    static let pulsatingFillColor = UIColor.rgb(red: 86, green: 30, blue: 63)
    
    //used for tint for Nav Bar appearance
    static let secondaryBlueTint = UIColor.rgb(red: 84, green: 110, blue: 122)
    
    
    //use for greyed out buttons possibly 
    static let greyPorcelain = UIColor.rgb(red: 132, green: 129, blue: 122)
   
}

