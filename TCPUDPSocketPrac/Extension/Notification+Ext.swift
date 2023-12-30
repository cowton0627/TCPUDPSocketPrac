//
//  Notification+Ext.swift
//  TCPUDPSocketPrac
//
//  Created by Chun-Li Cheng on 2023/4/27.
//

import Foundation

extension Notification.Name {
    static let didConnectedToServer = Notification.Name("didConnectedToServer")
    static let didDisconnectedToServer = Notification.Name("didDisconnectedToServer")
}
