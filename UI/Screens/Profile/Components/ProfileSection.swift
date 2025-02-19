//
//  ProfileSection.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content // Ajout de @ViewBuilder ici
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            content() // Appel de la closure content ici
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
