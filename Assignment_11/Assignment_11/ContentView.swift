//
//  ContentView.swift
//  Assignment_10
//
//  Created by Sameer Shashikant Deshpande on 11/15/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CustomersView()
                .tabItem {
                    Label("Customers", systemImage: "person.fill")
                }
            
            PoliciesView()
                .tabItem {
                    Label("Policies", systemImage: "scroll.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
