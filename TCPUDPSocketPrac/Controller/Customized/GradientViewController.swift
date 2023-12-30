//
//  GradientViewController.swift
//  ZAP
//
//  Created by Chun-Li Cheng on 2023/6/24.
//

import UIKit
// MARK: - 建構 ZAP 主視覺，目前只用 protocol
/// 繼承 GradientViewController 建構背景色
class GradientViewController: UIViewController {
    
    private let gradientLayer = CAGradientLayer()
    private let gradientStart = #colorLiteral(red: 0.5450980392, green: 0.7294117647, blue: 0.8078431373, alpha: 1).withAlphaComponent(0.7).cgColor
    private let gradientEnd = #colorLiteral(red: 0.5450980392, green: 0.7294117647, blue: 0.8078431373, alpha: 1).withAlphaComponent(0).cgColor

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupBackground() {
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [gradientStart, gradientEnd]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

}

/// 或使用 protocol 去建構背景色
internal protocol GradientBackground {
    var gradientLayer: CAGradientLayer { get set }
    func setupGradientBackground()
}

extension GradientBackground where Self: UIViewController {
    func setupGradientBackground() {
        let gradientStart = #colorLiteral(red: 0.5450980392, green: 0.7294117647, blue: 0.8078431373, alpha: 1).withAlphaComponent(0.7).cgColor
        let gradientEnd = #colorLiteral(red: 0.5450980392, green: 0.7294117647, blue: 0.8078431373, alpha: 1).withAlphaComponent(0).cgColor
        
        gradientLayer.colors = [gradientStart, gradientEnd]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

