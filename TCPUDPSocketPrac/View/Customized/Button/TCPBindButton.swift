//
//  TCPBindButton.swift
//  TCPUDPSocketPrac
//
//  Created by Chun-Li Cheng on 2023/4/27.
//

import UIKit

class TCPBindButton: UIButton {
    
//    private enum ButtonState {
//        case selected
//        case `default`
//    }
    
//    private var selectedColor: UIColor?
//    private var defaultColor: UIColor? {
//        didSet {
//            backgroundColor = defaultColor
//            tintColor = defaultColor
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override var isSelected: Bool
    {
        didSet {
            if isSelected {
//                if let color = selectedColor {
//                    backgroundColor = color
//                    tintColor = color
//                }
                backgroundColor = .systemGray4
                tintColor = .systemGray4
            } else {
//                if let color = defaultColor {
//                    backgroundColor = color
//                    tintColor = color
//                }
                backgroundColor = .systemTeal
                tintColor = .systemTeal
            }
        }
    }

    private func configure() {
        setTitle("Bind", for: .normal)
        setTitleColor(.white, for: .normal)
//        setBackgroundColor(.systemTeal, for: .normal)
//        setTintColor(.systemTeal, for: .normal)
        setTitle("Unbind", for: .selected)
        setTitleColor(.black, for: .selected)
//        setBackgroundColor(.systemGray4, for: .selected)
//        setTintColor(.systemGray4, for: .selected)
    }
    
//    private func setBackgroundColor(_ color: UIColor?,
//                                    for state: UIControl.State) {
//        switch state {
//        case .selected:
//            selectedColor = color
//        case .normal:
//            defaultColor = color
//        default: break
//        }
//    }
    
//    private func setTintColor(_ color: UIColor?,
//                              for state: UIControl.State) {
//        switch state {
//        case .selected:
//            selectedColor = color
//        case .normal:
//            defaultColor = color
//        default: break
//        }
//    }
    
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }

}
