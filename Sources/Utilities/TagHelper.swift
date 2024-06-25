//
//  TagHelper.swift
//  RPAgentSwiftXCTest
//
//  Created by Stas Kirichok on 23-08-2018.
//  Copyright © 2018 Windmill Smart Solutions. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

enum TagHelper {
  
  static var defaultTags: [String] {
    #if os(iOS)
    return [
      UIDevice.current.systemName,
      UIDevice.current.systemVersion,
      UIDevice.current.modelName,
      UIDevice.current.model
    ]
    #elseif os(macOS)
    return [
      "macOS",
      ProcessInfo.processInfo.operatingSystemVersionString,
      "Mac",
      Host.current().localizedName ?? "Unknown Host"
    ]
    #endif
  }
  
}

