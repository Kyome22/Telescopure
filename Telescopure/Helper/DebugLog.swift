/*
 DebugLog.swift
 Telescopure

 Created by Takuto Nakamura on 2022/08/11.
*/

import Foundation

func DebugLog(_ anyClass: AnyClass, _ message: String) {
#if DEBUG
    let type = String(describing: type(of: anyClass))
    NSLog("🛠 \(type): \(message)")
#endif
}
