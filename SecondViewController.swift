//
//  SecondViewController.swift
//  ninemensmorris
//
//  Created by Niko Neufeld on 09.01.17.
//  Copyright © 2017 pinbeutel. All rights reserved.
//

import Cocoa

class SecondViewController: NSViewController {

    @IBAction func dismiss(_ sender: Any) {
        self.dismissViewController(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
