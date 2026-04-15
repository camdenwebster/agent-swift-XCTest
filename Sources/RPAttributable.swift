//  Copyright 2025 EPAM Systems
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

/// Adopt this protocol on an `XCTestCase` subclass to attach custom ReportPortal
/// attributes to the TEST and STEP items that correspond to each test class and method.
///
/// - **TEST item** (test class): return `component`, `scenario_owner`, etc.
/// - **STEP item** (test method): return `step_owner`, etc.
///   Check `self.name` inside the property to vary values per method if needed.
///
/// Return `nil` (the default) to attach no custom attributes.
///
/// ## Example
/// ```swift
/// final class CheckoutTests: XCTestCase, RPAttributable {
///     var rpAttributes: [String: String]? {
///         ["component": "checkout",
///          "scenario_owner": "alice",
///          "step_owner": "bob"]
///     }
/// }
/// ```
public protocol RPAttributable: AnyObject {
    var rpAttributes: [String: String]? { get }
}

extension RPAttributable {
    public var rpAttributes: [String: String]? { nil }
}
