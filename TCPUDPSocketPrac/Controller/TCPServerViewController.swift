//
//  TCPServerViewController.swift
//  TCPUDPSocketPrac
//
//  Created by Chun-Li Cheng on 2022/11/30.
//

import UIKit
import CocoaAsyncSocket

// MARK: - TCP Server VC
class TCPServerViewController: UIViewController, GradientBackground {
    
    
    //MARK: - Properties
    internal var gradientLayer = CAGradientLayer()
    var serverSocket: GCDAsyncSocket?
    var clientSocket: GCDAsyncSocket?
    var wifiIP: String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }
         
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPV4 or IPV6 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    // Convert interface address to a human readable string
                    var addr = interface.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr,socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostName, socklen_t(hostName.count),
                                nil, socklen_t(0),
                                NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
    //MARK: - IBOutlet
    @IBOutlet weak var ipLabel: UILabel!                // 顯示 Server 端 IP
    @IBOutlet weak var listeningBtn: UIButton!
    @IBOutlet weak var portTextField: UITextField!      // 連接埠
    @IBOutlet weak var messageTextField: UITextField!   // 訊息輸入
    @IBOutlet weak var messageTextView: UITextView!     // 訊息欄


    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
//        ipLabel.text = serverSocket?.connectedAddress
        ipLabel.text = wifiIP
        keyboardShouldReturn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    //MARK: - IBAction
    @IBAction func listeningBtnTapped(sender: AnyObject) {
        
        listeningBtn.isSelected = !listeningBtn.isSelected
        if listeningBtn.isSelected {
            listeningBtn.setTitle("Unlisten", for: .normal)
            listeningBtn.setTitleColor(.black, for: .selected)
        } else {
            listeningBtn.setTitle("Listen", for: .normal)
            listeningBtn.setTitleColor(.white, for: .selected)
        }
                
        serverSocket = GCDAsyncSocket(delegate: self,
                                      delegateQueue: DispatchQueue.main)
        
        if let text = portTextField.text,
           text != "0",
           let port = UInt16(text) {
            
            do {
                try serverSocket?.accept(onPort: port)
                showMessage("監聽成功，可開始連接")
            } catch {
                showMessage("取消監聽")
            }
            
        } else {
            showMessage("There's no such port in this world.")
        }
        
        view.endEditing(true)
    }

    // 傳送
    @IBAction func sendBtnTapped(sender: AnyObject) {
        let data = messageTextField.text?.data(using: String.Encoding.utf8)
        showMessage(dateString() + "\nServer send: " + messageTextField.text! + "\n")
        
        // 向 client 寫入訊息，Timeout 為 -1 時表示不會超時，tag 做為兩邊一樣的標示
        clientSocket?.write(data, withTimeout: -1, tag: 0)
        messageTextField.text = ""
        view.endEditing(true)
    }
    
    // 清除 TextView
    @IBAction func clearBtnTapped(_ sender: Any) {
        messageTextView.text = ""
    }
    
    //MARK: - Private Methods
    private func dateString() -> String {
        // 現在連線時間
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm:ss"
        let now = Date()
        let date = dateFormatter.string(from: now)

        return date
    }
    
    // Textview 顯示訊息, 新訊息不斷加進去
    private func showMessage(_ text: String) {
        messageTextView.text = messageTextView.text.appendingFormat("%@\n", text)
    }
    
    // 按下 return 鍵盤收回
    private func keyboardShouldReturn() {
        portTextField.delegate = self
        messageTextField.delegate = self
        messageTextView.delegate = self
    }
    
    private func textfieldResign(_ textfield: UITextField) {
        textfield.resignFirstResponder()
    }
    
    //MARK: - override func
    // 按下旁邊鍵盤收回
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textfieldResign(portTextField)
        textfieldResign(messageTextField)
        messageTextView.resignFirstResponder()
    }

}

//MARK: - UITextFieldDelegate
extension TCPServerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
}

//MARK: - UITextViewDelegate
extension TCPServerViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            view.endEditing(false)
        }
        return false
    }
}

//MARK: - GCDAsyncSocketDelegate
extension TCPServerViewController: GCDAsyncSocketDelegate {

    // 新的 Socket（Client）連接時
    func socket(_ sock: GCDAsyncSocket,
                didAcceptNewSocket newSocket: GCDAsyncSocket) {
        showMessage(dateString())
        showMessage("連線狀態：連接成功")
        showMessage("Client IP: " + newSocket.connectedHost!)
        showMessage("連接埠" + String(newSocket.connectedPort))
        showMessage("------------------------------")
        clientSocket = newSocket
        // 初次讀取 Data
        clientSocket!.readData(withTimeout: -1, tag: 0)
    }

    // 接收 Client 回傳的訊息
    func socket(_ sock: GCDAsyncSocket,
                didRead data: Data,
                withTag tag: Int) {
        
        let text = String(data: data,encoding: String.Encoding.utf8) ?? "Can't be identified"
        showMessage(dateString() + "\nClient send: " + text + "\n")
        
        // 再次及後續讀取 Data
        sock.readData(withTimeout: -1, tag: 0)
    }
    

}
