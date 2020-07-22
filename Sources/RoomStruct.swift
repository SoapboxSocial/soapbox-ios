//
//  File.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import Foundation

struct Member {
    let name: String
    let username: String
}

struct RoomStruct {
    let title: String

    let members: [Member]
}
