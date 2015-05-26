//
//  CustomCell.swift
//  CustomSwitch
//
//  Created by Alex Chen on 2015/5/26.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomCell: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    func instanceFromNib(btn:UIButton) -> UIView {
        var view = UINib(nibName: "CustomCell", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds

        return view
    }
}
