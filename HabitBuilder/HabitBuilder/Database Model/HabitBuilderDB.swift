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

class HabitBuilderDB: Object {
    @Persisted var title: String = ""
    @Persisted var desc: String = ""
    @Persisted var id: String?
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}
