import SwiftUI

enum ICQTheme {
    static let teal        = Color(hex: "00AFA0")
    static let tealDark    = Color(hex: "007A70")
    static let yellow      = Color(hex: "FFDD00")
    static let onlineGreen = Color(hex: "4CAF50")
    static let awayYellow  = Color(hex: "FFC107")
    static let busyRed     = Color(hex: "F44336")
    static let offlineGray = Color(hex: "9E9E9E")
    static let background  = Color(hex: "F0F2F5")
    static let bubbleSent  = Color(hex: "D4F0EE")
}

extension Color {
    init(hex: String) {
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
