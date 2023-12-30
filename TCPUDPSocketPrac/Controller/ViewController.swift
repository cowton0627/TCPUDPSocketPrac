//
//  ViewController.swift
//  TCPUDPSocketPrac
//
//  Created by Chun-Li Cheng on 2022/11/28.
//

import UIKit

class ViewController: UIViewController, GradientBackground {
    internal var gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
//        title = "TCP Connection"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }


}

