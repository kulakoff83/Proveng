//
//  FeedCellExtension.swift
//  proveng
//
//  Created by Dmitry Kulakov on 01.11.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import PromiseKit

extension FeedTableViewCell {
    
    func requestTeacher(id: Int, handler: @escaping (UserPreview) -> Void) {
        ServiceForData<UserPreview>().getObject(id: id) { user in
            handler(user)
        }
    }
}
