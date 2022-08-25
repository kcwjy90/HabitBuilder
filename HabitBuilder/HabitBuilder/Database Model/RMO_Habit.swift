//
//  HabitBuilderDB.swift
//  HabitBuilder
//
//  Created by ppc90 on 3/31/22.
//  Copyright © 2022 CW. All rights reserved.
//

import Foundation
import RealmSwift

//Temporary Local Database created

enum RepeatType: Int {
    case none = 0
    case daily = 1
    case weekly = 2
    case monthly = 3
    case yearly = 4
}

class RMO_Habit: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var desc: String = ""
    @Persisted var date: Date = Date()
    @Persisted var onGoing: Bool = true
    
    
    @Persisted var privateRepeatType: Int = 0
    var repeatType: RepeatType? {
        get {
            if let r = RepeatType(rawValue: privateRepeatType) {
                return r
            } else {
                return nil
            }
        }
        set {
            if let v = newValue {
                privateRepeatType = v.rawValue
            }
        }
    }

    convenience init(title: String) {
        self.init()
        self.title = title
    }
}
