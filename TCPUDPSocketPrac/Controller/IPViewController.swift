//
//  IPViewController.swift
//  TCPUDPSocketPrac
//
//  Created by Chun-Li Cheng on 2022/12/1.
//

import UIKit

import Network
import MobileCoreServices
import UniformTypeIdentifiers


// MARK: - IP VC
class IPViewController: UIViewController {
    
    //MARK: - Properties
    /// ISP IP
    var deviceIP: String? {
        var addresses = [String]()
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        
                        if (getnameinfo(&addr,
                                        socklen_t(addr.sa_len),
                                        &hostname,
                                        socklen_t(hostname.count),
                                        nil,
                                        socklen_t(0),
                                        NI_NUMERICHOST) == 0) {
                            
                            if let address = String(validatingUTF8: hostname) {
                                addresses.append(address)
                            }
                            
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }
    
    /// 由 Wi-Fi AP 獲得的 IP
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
                    
                    getnameinfo(&addr,
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostName,
                                socklen_t(hostName.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                    
                    address = String(cString: hostName)
                }
            }
        }
         
        freeifaddrs(ifaddr)
        return address
    }
    
    //MARK: - IBOutlet
    @IBOutlet weak var deviceIPLabel: UILabel!
    @IBOutlet weak var wifiIPLabel: UILabel!
    @IBOutlet weak var wanIPLabel: UILabel!
//    {
//        didSet {
//            IPViewController.anotherWayToGetPublicIP { [self] ipString in
//                DispatchQueue.main.async {
//                    self.wanIPLabel.text = ipString
//                }
//            }
//        }
//    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - ISP、WiFi IP
//        configureWithComputedProperties()
        configureWithGetMethods()

        //MARK: - 外網 IP
        // 使用 OperationQueue
//        IPViewController.getPublicIP { [self] ipString in
//            wanIPLabel.text = ipString
//        }
        
        // 使用 URLSession
        IPViewController.anotherWayToGetPublicIP { [self] ipString in
            DispatchQueue.main.async {
                self.wanIPLabel.text = ipString
            }
        }

        printNeededInfo()
    }
        
    
    //MARK: - Private Methods
    private func printNeededInfo() {
        print("自定義名稱: \(UIDevice.current.name)")
        /* iPhone/iPad/iMac/iWatch */
        print("設備型號: \(UIDevice.current.model)")
        print("系統版本: \(UIDevice.current.systemName + UIDevice.current.systemVersion)")
        print("ISP IP: \(deviceIP ?? "none")")
        print("Wi-Fi IP: \(wifiIP ?? "none")")
    }
    
    private func configureWithComputedProperties() {
        deviceIPLabel.text = deviceIP
        wifiIPLabel.text = wifiIP
    }
    
    private func configureWithGetMethods() {
        deviceIPLabel.text = IPViewController.getDeviceIP()
        wifiIPLabel.text = IPViewController.getWifiIP()
    }
    
    /// 獲得廣域網 IP，把 Data 變 Array 再處理
    static func getPublicIP(callback: @escaping ((String) -> ())) {
        let queue = OperationQueue()
        let blockOP = BlockOperation.init {
            
            if let url = URL(string: "https://api.ipify.org/?format=json"),
               let string = try? String(contentsOf: url, encoding: .utf8) {
//                print("data:\(string)")
                
                let array = string.components(separatedBy: ":")
//                print(array)
                
                // 保證 IP 有值
                if array.count > 1  {
                    // 從 array[1] 拿掉不必要的字符
                    let ipString = array[1].replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "}", with: "")
                    print("WAN IP: \(ipString), Thread = \(Thread.current)")
                    
                    DispatchQueue.main.async {
                        callback(ipString)
                    }
                    // 成功獲取必須 return
                    return
                                        
//                    let ipArray = ipString.components(separatedBy: ",")
//                    if ipArray.count > 0 {
//                        let ip = ipArray[0].trimmingCharacters(in: CharacterSet.whitespaces)
//                        print("廣域網 IP:\(ip), Thread = \(Thread.current)")
//                        DispatchQueue.main.async {
//                            callback(ip)
//                        }
//                        return
//                    }
                }
                
            } else {
                print("獲取廣域網 IP 的 URL 轉換失敗")
            }
            
            DispatchQueue.main.async {
                print("獲取廣域網 IP 失敗")
                callback("")
            }
                 
        }
        queue.addOperation(blockOP)
    }

    /// 廣域網 IP，把 Data 變為 json 再解析
    static func anotherWayToGetPublicIP(callback: @escaping ((String) -> ())) {
        guard let url = URL(string: "https://api.ipify.org/?format=json") else {
            print("Invalid URL")
            callback("")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                callback("")
                return
            }

            guard let data = data else {
                print("No data received")
                callback("")
                return
            }
            
            do {
                // 使用 JSONDecoder
                let address = try JSONDecoder().decode(Address.self, from: data)
                print("\(address)")
                callback(address.ip)

                // 使用 JSONSerialization
//                if let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
//                    print("\(dict)")
//                    callback(dict["ip"] as? String ?? "")
//                } else {
//                    callback("")
//                }
            } catch {
                print("Error: \(error.localizedDescription)")
                callback("")
            }
        }.resume()
    }
    
    
    /// 獲取 ISP IP
    static func getDeviceIP() -> String? {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        
                        if (getnameinfo(&addr,
                                        socklen_t(addr.sa_len),
                                        &hostname,
                                        socklen_t(hostname.count),
                                        nil, socklen_t(0),
                                        NI_NUMERICHOST) == 0) {
                            
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }
    
    /// 獲取由 Wi-Fi AP 獲得的 IP
    static func getWifiIP() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
            
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
                       
                    getnameinfo(&addr,
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostName,
                                socklen_t(hostName.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                       
                    address = String(cString: hostName)
                }
            }
        }
            
        freeifaddrs(ifaddr)
        return address
    }

}

struct Address: Decodable {
    var ip: String
}

/*
 由於得到的結果是 {"ip":"111.70.7.158"} 即 key: value 為 String: String,
 所以建立一個 Struct 後, 屬性令為 key,
 接著以 JSONDecoder().decode(Address.self, from: data) 解析 value
 */
