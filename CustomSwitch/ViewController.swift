//
//  ViewController.swift
//  CustomSwitch
//
//  Created by Alex Chen on 2015/5/13.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var customSwitch: CustomSwitchControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customSwitch = CustomSwitchControl(frame: CGRectZero)
        customSwitch.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5 + 70)
        customSwitch.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func switchChanged(sender: CustomSwitchControl) {
        println("Changed value to: \(sender.on)")
    }

}

