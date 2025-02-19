//
//  ShoppingListView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct ShoppingListView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Fruits & Légumes")) {
                    Text("Liste vide")
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Protéines")) {
                    Text("Liste vide")
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Épicerie")) {
                    Text("Liste vide")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Liste de courses")
        }
    }
}
#Preview {
    ShoppingListView()
}
