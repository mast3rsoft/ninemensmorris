//
//  FirstViewController.swift
//  ninemensmorris
//
//  Created by Niko Neufeld on 11.01.17.
//  Copyright © 2017 pinbeutel. All rights reserved.
//

import Cocoa

class FirstViewController: NSViewController {

    var model = Engine()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBOutlet weak var colorChooser: NSPopUpButton!
    @IBAction func colorSelected(_ sender: NSPopUpButton) {
        if sender.selectedTag() == 0 {
            model.player = Color.White
        } else {
            model.player = Color.Black
        }
    }
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let second = segue.destinationController as! ViewController
        second.representedObject = model
        
    }
}
