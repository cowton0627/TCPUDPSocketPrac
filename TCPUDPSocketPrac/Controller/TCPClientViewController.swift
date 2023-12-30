//
//  TCPViewController.swift
//  TCPUDPSocketPrac
//
//  Created by Chun-Li Cheng on 2022/11/28.
//

import UIKit
import CocoaAsyncSocket

// MARK: - TCP Client VC
class TCPClientViewController: UIViewController, GradientBackground {
    
    
    //MARK: - Properties
    internal var gradientLayer = CAGradientLayer()
    private var socket: GCDAsyncSocket!
    
    //MARK: - IBOutlet
    @IBOutlet weak var bindBtn: TCPBindButton!          // 綁定按鈕
    @IBOutlet weak var addressTextField: UITextField!   // Server 端 IP 地址
    @IBOutlet weak var portTextField:    UITextField!   // 連接埠
    @IBOutlet weak var messageTextField: UITextField!   // 訊息輸入
    @IBOutlet weak var messageTextView: UITextView!     // 訊息欄
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        // 建立 TCP Socket
        socket = GCDAsyncSocket (delegate: self,
                                 delegateQueue: DispatchQueue.main)
        keyboardShouldReturn()
        setupListener()
//        setupBindBtn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    //MARK: - IBAction
    @IBAction func bindBtnTapped(_ sender: Any) {
        changeBindBtnState()
//        configureBindBtn()
        // isSelected 時呼叫 connect, 反之呼叫 stopConnect
        bindBtn.isSelected ? connect() : stopConnect()
        // 鍵盤收回
        view.endEditing(true)
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        // 將輸入的文字轉為 data
        let data = messageTextField.text?.data(using: .utf8)
        showMessage(dateString() + "\nClient send: " + messageTextField.text! + "\n")
        socket.write(data!, withTimeout: -1, tag: 0)
        
        messageTextField.text = ""
        view.endEditing(true)
    }
    
    // 清除 TextView
    @IBAction func clearBtnTapped(_ sender: Any) {
        messageTextView.text = ""
    }
    
    //MARK: - Private Methods
    private func changeBindBtnState() {
        /** change bindBtn select state, isSelected { get set }
         ** isSelected default 是 false, 所以 bind 按下去這個 state 為 true
         */
        bindBtn.isSelected = !bindBtn.isSelected
    }
    
    private func configureBindBtn() {
//        if bindBtn.isSelected {
//            bindBtn.setTitle("Unbind", for: .normal)
//            bindBtn.setTitleColor(.black, for: .selected)
//            bindBtn.backgroundColor = .systemGray4
//            bindBtn.tintColor = .systemGray4
//        } else {
//            bindBtn.setTitle("Bind", for: .normal)
//            bindBtn.setTitleColor(.white, for: .selected)
//            bindBtn.backgroundColor = .systemTeal
//            bindBtn.tintColor = .systemTeal
//        }
    }
    
    // 改在 Custom Button 裡寫 setup
//    private func setupBindBtn() {
//        bindBtn.setTitle("Bind", for: .normal)
//        bindBtn.setTitleColor(.white, for: .normal)
//        bindBtn.setTitle("Unbind", for: .selected)
//        bindBtn.setTitleColor(.black, for: .selected)
//    }
    // 進行連接
    private func connect() {
        
        if let text = portTextField.text,
           text != "0",
           let port = UInt16(text) {

            // 這個行為叫做綁定
            do {
                /** addressTextField 與 portTextField, host 可以是 IP 也可以是 address
                 ** Interface en0 或 lo0, 即 ethernet 或 localhost/loopback (127.0.0.1)
                 ** timeout 為 -1 代表會嘗試到連接為止
                 */
                try socket.connect(toHost: addressTextField.text!,
                                   onPort: port,
                                   viaInterface: nil,
                                   withTimeout: -1)
            } catch {
                //MARK: - 未捕捉過的情況
                showMessage(error.localizedDescription)
//                changeBindBtnState()
//                showMessage("連線狀態：連線失敗")
            }

        } else {
            // 非正確 port 或無 port
            showMessage("綁定失敗")
            showMessage("------------------------------")
            changeBindBtnState()
        }
    }

    // 停止連接
    private func stopConnect() {
        socket.disconnect()
    }
    
    // Textview 顯示訊息, 新訊息不斷加進去
    private func showMessage(_ text: String) {
        messageTextView.text = messageTextView.text.appendingFormat("%@\n", text)
    }
    
    // 現在時間
    private func dateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm:ss"
        let now = Date()
        let date = dateFormatter.string(from: now)

        return date
        // 自從 1970 年以來經過了多少秒, 換成年
//        let string = "\(Date().timeIntervalSince1970/60/60/24/365)"
//        return string
    }
    
    // 按下 return 鍵盤收回
    private func keyboardShouldReturn() {
        addressTextField.delegate = self
        portTextField.delegate = self
        messageTextField.delegate = self
        messageTextView.delegate = self
    }
    
    @objc private func didConnectedToServer() {
        
    }
    
    @objc private func didDisconnectedToServer() {
        // true is bind, but bind is not right, so change state
        if bindBtn.isSelected {
            changeBindBtnState()
        }
    }
    
    private func setupListener() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didConnectedToServer),
                                               name: .didConnectedToServer, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didDisconnectedToServer),
                                               name: .didDisconnectedToServer, object: nil)
    }
    
    private func broadcastDidConnectedToServer() {
        NotificationCenter.default.post(name: .didConnectedToServer, object: nil)
    }
    
    private func broadcastDidDisconnectedToServer() {
        NotificationCenter.default.post(name: .didDisconnectedToServer, object: nil)
    }
    
    private func textfieldResign(_ textfield: UITextField) {
        textfield.resignFirstResponder()
    }
    
    //MARK: - override func
    // 按旁邊鍵盤收回
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textfieldResign(addressTextField)
        textfieldResign(portTextField)
        textfieldResign(messageTextField)
        messageTextView.resignFirstResponder()
    }

}

//MARK: - UITextFieldDelegate
extension TCPClientViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
}

//MARK: - UITextViewDelegate
extension TCPClientViewController: UITextViewDelegate {
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
extension TCPClientViewController: GCDAsyncSocketDelegate {
    // 連接成功後, 在 TextView 上顯示連接成功的訊息及 Server IP
    func socket(_ sock: GCDAsyncSocket,
                didConnectToHost host: String,
                port: UInt16) {
        broadcastDidConnectedToServer()
        showMessage(dateString())
        showMessage("Connected to \n\(host): \(port)")
        showMessage("------------------------------")
        socket.readData(withTimeout:-1, tag: 0)
    }
    
    // 接收 Server 回傳的訊息
    func socket(_ sock: GCDAsyncSocket,
                didRead data: Data,
                withTag tag: Int) {
        let text = String(data: data, encoding: .utf8) ?? "Data can't be identified"
        showMessage(dateString() + "\nServer send: " + text + "\n")
        //TODO: - 超過 12 個字元就分段
//        if text.count < 12 {
//            showMessage(dateString() + "\nServer send: " + text + "\n")
//        } else {
//            showMessage("Character is longer than 12.")
//        }
        socket.readData(withTimeout: -1, tag: 0)
    }
    
    /** 斷開連接, Server 斷線, 如停止監聽（主動）、失去聯網能力（被動，不包括 Server 斷電）
     ** 停止監聽的話會很快地進到 didDisconnect；失去聯網能力待確認
     ** 或 Client 失去聯網能力
     */
    func socketDidDisconnect(_ sock: GCDAsyncSocket,
                             withError err: Error?) {
        broadcastDidDisconnectedToServer()
        if let err = err {
            showMessage("Disconnected with error: \(err.localizedDescription)")
        } else {
            showMessage("斷開連接")
        }
        showMessage("------------------------------")
    }
}
