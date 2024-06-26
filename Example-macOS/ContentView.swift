//
//  ContentView.swift
//  Example-macOS
//
//  Created by Camden Webster on 6/26/24.
//  Copyright © 2024 Sergey Komarov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var first: String = ""
    @State private var second: String = ""
    private var sum: Int = 0
    
    var body: some View {
        VStack {
            TextField("First number", text: $first).accessibilityIdentifier("first")
            Text("+")
            TextField("Second number", text: $second).accessibilityIdentifier("second")
            Text("=")
            Text(String((Int(first) ?? 0) + (Int(second) ?? 0))).accessibilityIdentifier("sum")
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
