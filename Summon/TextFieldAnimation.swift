//
//  AnimatedTextChange.swift
//  Summon
//
//  Created by Benjamin Rohald on 29/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import Cocoa

public extension NSTextField {
    func setStringValue(_ newValue: String, animated: Bool = true, interval: TimeInterval = 0.7) {
        guard stringValue != newValue else { return }
        if animated {
            animate(change: { self.stringValue = newValue }, interval: interval)
        } else {
            stringValue = newValue
        }
    }

    func setAttributedStringValue(_ newValue: NSAttributedString, animated: Bool = true, interval: TimeInterval = 0.7) {
        guard attributedStringValue != newValue else { return }
        if animated {
            animate(change: { self.attributedStringValue = newValue }, interval: interval)
        }
        else {
            attributedStringValue = newValue
        }
    }

    private func animate(change: @escaping () -> Void, interval: TimeInterval) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = interval / 2.0
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animator().alphaValue = 0.0
        }, completionHandler: {
            change()
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = interval / 2.0
                context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                self.animator().alphaValue = 1.0
            }, completionHandler: {})
        })
    }
}
