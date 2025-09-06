//
//  ContentView.swift
//  poketcg
//
//  Created by Kavi Sekhon on 2025-09-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "shuffle")
                    Text("Feed")
                }

            ListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("List")
                }

            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
        }
    }
}

#Preview {
    ContentView()
}
