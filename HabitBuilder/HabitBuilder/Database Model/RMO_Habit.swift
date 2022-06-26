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
    @Persisted var id = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var desc: String = ""
    @Persisted var date: Date = Date()
    @Persisted var isRepeat: Bool = false
    @Persisted var repeatType: Int

    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}
