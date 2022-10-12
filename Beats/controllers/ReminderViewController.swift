//
//  ReminderViewController.swift
//  Beats
//
//  Created by André Arns on 15/12/21.
//

import UIKit

class ReminderViewController: UIViewController {

    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startButton.layer.cornerRadius = 25
    }
}
