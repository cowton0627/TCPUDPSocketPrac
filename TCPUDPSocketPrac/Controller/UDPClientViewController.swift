//
//  UDPClientViewController.swift
//  TCPUDPSocketPrac
//
//  Created by Chun-Li Cheng on 2023/6/24.
//

import UIKit
import CocoaAsyncSocket

class UDPClientViewController: UIViewController {
    
    let ip = "255.255.255.255"
    var udpSocket: GCDAsyncUdpSocket!
    
    private let separateLine = "----------------------------"
    
    @IBOutlet weak var bindBtn: UDPBindButton!
    //    @IBOutlet weak var bindBtn: UIButton!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        udpSocket = GCDAsyncUdpSocket(delegate: self,
                                      delegateQueue: .main)
        
//        bindBtn.onButtonTapped = { [weak self] in
//            if self?.bindBtn.isSelected == true {
//                // Logic to bind the socket
//                self?.bindSocket()
//            } else {
//                // Logic to unbind the socket
//                self?.unbindSocket()
//            }
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unbindSocket()
    }
    
    func bindSocket() {
        guard let text = portTextField.text,
              let port = UInt16(text) else { return }
        
        do {
            try udpSocket.bind(toPort: port)
            showMessage(dateString())
            showMessage("已經綁定 Port: \(port)")
            showMessage(separateLine)
            
        } catch(let error) {
            showMessage("Port 綁定失敗")
            print(error)
        }
        
        do {
            try udpSocket.enableBroadcast(true)
            print("Broadcast")
            
        } catch {
            print("can't broadcast")
        }
        
        do {
            try udpSocket.beginReceiving()
            print("begin receiving...")
        } catch {
            print("receiving is not in process.")
        }
        
        view.endEditing(true)
    }
    
    func unbindSocket() {
        if udpSocket != nil && udpSocket.isClosed() == false {
            udpSocket.close()
        }
    }
    
    @IBAction func bindBtnTapped(_ sender: Any) {
        bindBtn.isSelected = !bindBtn.isSelected
        if bindBtn.isSelected {
            bindBtn.setTitle("Unbind", for: .normal)
            bindBtn.setTitleColor(.black, for: .selected)
            bindSocket()
        } else {
            bindBtn.setTitle("Bind", for: .normal)
            bindBtn.setTitleColor(.white, for: .selected)
            unbindSocket()
        }
        
//        guard let text = portTextField.text,
//              let port = UInt16(text) else { return }
//
//        do {
//            try udpSocket.bind(toPort: port)
//            showMessage(dateString())
//            showMessage("已經綁定 Port: \(port)")
//            showMessage(separateLine)
//        } catch(let error) {
//            showMessage("Port 綁定失敗")
//            print(error)
//        }
//        do {
//            try udpSocket.enableBroadcast(true)
//            print("Broadcast")
//        } catch {
//            print("can't broadcast")
//        }
//        do {
//            try udpSocket.beginReceiving()
//            print("begin receiving...")
//        } catch {
//            print("receiving is not in process.")
//        }
//        view.endEditing(true)
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        let data = messageTextField.text?.data(using: .utf8)
        udpSocket.send(data!,
                       toHost: ip,
                       port: UInt16(portTextField.text!)!,
                       withTimeout: -1,
                       tag: 0)
        view.endEditing(true)
    }
    
    @IBAction func clearBtnTapped(_ sender: Any) {
        messageTextView.text = ""
    }

    // Textview 顯示訊息, 新訊息不斷加進去
    private func showMessage(_ text: String) {
        messageTextView.text = messageTextView.text.appendingFormat("%@\n", text)
    }
    
    // 現在時間
    private func dateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm:ss"
//        dateFormatter.dateFormat = "HH:mm:ss"

        let now = Date()
        let date = dateFormatter.string(from: now)

        return date
        // 自從 1970 年以來經過了多少秒, 換成年
//        let string = "\(Date().timeIntervalSince1970/60/60/24/365)"
//        return string
    }

}

extension UDPClientViewController: GCDAsyncUdpSocketDelegate {
    func udpSocket(_ sock: GCDAsyncUdpSocket,
                   didReceive data: Data,
                   fromAddress address: Data,
                   withFilterContext filterContext: Any?) {
        
        print("didReceiveData")
        
        var host: NSString?
        var port: UInt16 = 0
//        var addr: String?
        
        GCDAsyncUdpSocket.getHost(&host, port: &port, fromAddress: address)
        
        // 检查地址长度是否至少为 16 字节（IPv6 地址长度）
//        if address.count >= 24 {
//            // 提取 IPv4 地址的部分（最后四个字节）
//            let ipv4Part = address.subdata(in: 20..<24)
//            // 将这四个字节转换为 IPv4 地址的字符串表示
//            addr = ipv4Part.map { String($0) }.joined(separator: ".")
//        } else {
//            print("Invalid address length.")
//        }
//        print(addr)
        
        let text = String(data: data,encoding: String.Encoding.utf8) ?? "Can't be identified"
        showMessage(dateString() + "\n\"\(host! as String)\" sent: \(text)\n")
//        showMessage("sent: \(text)")
        
//        let addr = String(data: address, encoding: String.Encoding.utf8) ?? "Can't be identified"
//        print(addr)
        
//        let text = String(data: data,encoding: String.Encoding.utf8) ?? "Can't be identified"
//        showMessage(dateString() + "\nget data: " + text + "\n")
        // 再次及後續讀取 Data
//        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("didConnectToAddress \(address)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("didNotConnect \(error!)")
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        if let error = error {
            print("斷開連接，因為： \(error)")
        }
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket,
                   didNotSendDataWithTag tag: Int,
                   dueToError error: Error?) {
        print("didNotSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("didSendDataWithTag")
    }
}
