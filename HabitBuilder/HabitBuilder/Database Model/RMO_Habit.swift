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

class RMO_Habit: Object {
    @Persisted var title: String = ""
    @Persisted var desc: String = ""
    @Persisted var date: String = ""
    @Persisted var time: String = ""
    @Persisted var dateTime = Date()
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}
