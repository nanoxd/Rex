//
//  NSUserDefaults.swift
//  Rex
//
//  Created by Neil Pankey on 5/28/15.
//  Copyright (c) 2015 Neil Pankey. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension NSUserDefaults {
    /// Sends value of `key` whenever it changes. Attempts to filter out repeats
    /// by casting to NSObject and checking for equality. If the values aren't
    /// convertible this will generate events whenever _any_ value in NSUserDefaults
    /// changes.
    func rex_valueForKey(key: String) -> SignalProducer<AnyObject?, NoError> {
        let center = NSNotificationCenter.defaultCenter()
        let changes = center.rac_notifications(name: NSUserDefaultsDidChangeNotification)
            |> map { notification in
                // The notification doesn't provide what changed so we have to look
                // it up every time
                return self.objectForKey(key)
        }

        return SignalProducer<AnyObject?, NoError>(value: objectForKey(key))
            |> concat(changes)
            |> skipRepeats { previous, next in
                if let previous = previous as? NSObject,
                    let next = next as? NSObject {
                        return previous == next
                }
                return false
            }
    }
}
