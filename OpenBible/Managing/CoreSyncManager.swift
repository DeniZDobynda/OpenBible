//
//  CoreSyncManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 25.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class CoreSyncManager: NSObject {
    
    var context: NSManagedObjectContext = AppDelegate.context
    
    func parseStrongs(_ type: String, from data: Data) -> Bool {
        if let obj = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SyncStrong, let parsed = obj {
            let strong = Strong(context: context)
            strong.meaning = parsed.meaning
            strong.number = Int32(parsed.number)
            strong.original = parsed.original
            strong.type = type
            return true
        } else {
            return false
        }
    }
    
    func save() {
        try? context.save()
    }
    
}
