//
//  Data+.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/24.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

extension Data {
    
    func decoded<T: Decodable>(to decodedType: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(decodedType, from: self)
        } catch {
            print("fail to decode, \(error.localizedDescription)")
            return nil
        }
    }
}
