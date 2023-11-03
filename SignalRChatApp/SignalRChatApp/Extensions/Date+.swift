//
//  Date+.swift
//  SignalRChatApp
//
//  Created by DongKyu Kim on 2023/11/03.
//

import Foundation

extension Date {
    func currentTimeInMilliseconds() -> String {
        return String(Int64(self.timeIntervalSince1970 * 1000))
    }
}
