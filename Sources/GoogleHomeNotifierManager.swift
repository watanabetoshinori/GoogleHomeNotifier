//
//  GoogleHomeNotifierManager.swift
//  GoogleHomeNotifier
//
//  Created by Watanabe Toshinori on 2/14/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import UIKit

class GoogleHomeNotifierManager: NSObject {

    private var notifiers = [GoogleHomeNotifier]()

    // MARK: - Initializing a Singleton

    static let shared = GoogleHomeNotifierManager()

    override private init() {

    }

    // MARK: - Managing Notifier

    class func add(notifier: GoogleHomeNotifier) {
        if shared.notifiers.index(of: notifier) == nil {
            shared.notifiers.append(notifier)
        }
    }

    class func remove(notifier: GoogleHomeNotifier) {
        if let index = shared.notifiers.index(of: notifier) {
            shared.notifiers.remove(at: index)
        }
    }

}
