//
//  NavigationControls.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import Foundation
import SwiftUI

struct NavigationControls: View {
    @Binding var currentPage: Int
    let isLastPage: Bool
    let canProceed: Bool
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            if currentPage > 0 {
                Button("Précédent") {
                    withAnimation {
                        currentPage -= 1
                    }
                }
            }
            
            Spacer()
            
            if isLastPage {
                Button("Commencer") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            } else {
                Button("Suivant") {
                    hideKeyboard()
                    withAnimation {
                        currentPage += 1
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            }
        }
        .padding()
    }
}
#Preview {
    NavigationControls(currentPage: .constant(0), isLastPage: false, canProceed: true, onComplete: { })
}
