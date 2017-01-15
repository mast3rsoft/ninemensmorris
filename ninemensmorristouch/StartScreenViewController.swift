//
//  StartScreenViewController.swift
//  ninemensmorris
//
//  Created by Niko Neufeld on 15.01.17.
//  Copyright © 2017 pinbeutel. All rights reserved.
//

import UIKit

class NineMenMorrisParameter {
    var player: Color
    init(player: Color) {
        self.player = player
    }
}

class StartScreenViewController: UIViewController {
    var model = Engine()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    @IBOutlet weak var chooser: UISegmentedControl!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func pushPlay(_ sender: UIButton) {
        
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! TouchViewController
        dest.model.player = (chooser.selectedSegmentIndex == 0) ? .White : .Black
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
