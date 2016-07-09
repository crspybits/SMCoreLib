//
//  ViewController.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 07/04/2016.
//  Copyright (c) 2016 Christopher Prince. All rights reserved.
//

import UIKit
import SMCoreLib

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Log.msg("Hello World!")
        let x = self.view.frameX
        Log.msg("Hello World: \(x)")
        let image = SMIcons.GoogleIcon
        Log.msg("image: \(image)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

