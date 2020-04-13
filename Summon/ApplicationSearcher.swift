//
//  ApplicationSearcher.swift
//  Summon
//
//  Created by Benjamin Rohald on 13/4/20.
//  Copyright © 2020 Benjamin Rohald. All rights reserved.
//

import Foundation

class ApplicationSearcher: NSObject {

        
    private var callback: ([NSMetadataItem]) -> ()

    init(callback: @escaping ([NSMetadataItem]) -> ()) {
        self.callback = callback
    }
    
    var query: NSMetadataQuery? {
        willSet {
            if let query = self.query {
                query.stop()
            }
        }
    }

    public func getAllApplications() {
        query = NSMetadataQuery()
        let predicate = NSPredicate(format: "kMDItemContentType == 'com.apple.application-bundle'")
        NotificationCenter.default.addObserver(self, selector: #selector(queryDidFinish(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        query?.predicate = predicate
        query?.start()
    }

    @objc public func queryDidFinish(_ notification: NSNotification) {
        guard let query = notification.object as? NSMetadataQuery else {
            return
        }
        
        var results = [NSMetadataItem]()

        for result in query.results {
            guard let item = result as? NSMetadataItem else {
                print("Result was not an NSMetadataItem, \(result)")
                continue
            }
            results.append(item)
        }

        callback(results)
    }
    
}
