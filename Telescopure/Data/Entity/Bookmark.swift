/*
 Bookmark.swift
 Telescopure

 Created by Takuto Nakamura on 2022/08/12.
*/

import Foundation

struct Bookmark: Equatable, Identifiable {
    var id = UUID()
    var title: String
    var url: String
}
