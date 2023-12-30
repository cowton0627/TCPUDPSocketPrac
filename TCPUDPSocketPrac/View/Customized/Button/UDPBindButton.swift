//
//  UDPBindButton.swift
//  TCPUDPSocketPrac
//
//  Created by Chun-Li Cheng on 2023/12/29.
//

import UIKit

class UDPBindButton: UIButton {
    
    var onButtonTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
//        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .systemGray4
                tintColor = .systemGray4
            } else {
                backgroundColor = .systemTeal
                tintColor = .systemTeal
            }
        }
    }

    private func configure() {
        setTitle("Bind", for: .normal)
        setTitleColor(.white, for: .normal)
        
        setTitle("Unbind", for: .selected)
        setTitleColor(.black, for: .selected)
    }

}
