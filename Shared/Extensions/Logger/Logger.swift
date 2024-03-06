//
//  Logger.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 07.02.2024.
//

import Foundation
import OSLog

extension Logger {
    static var subsystem = Bundle.main.bundleIdentifier!
    
    static let usernotifications = Logger(subsystem: subsystem, category: "usernotifications")
    
    static let healthkit = Logger(subsystem: subsystem, category: "healthkit")
}
