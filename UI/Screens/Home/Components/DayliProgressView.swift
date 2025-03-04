//
//  DayliProgressView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 19/02/2025.
//

import SwiftUI

@available(iOS 18.0, *)
struct DailyProgressView: View {
    let userProfile: UserProfile?
    @Binding var isExpanded: Bool
    @Binding var scrollPosition: SwiftUI.ScrollPosition
    var initialAnimation: Bool
    @Binding var isUserInteracting: Bool
    @Binding var userSelectedStatIndex: Int? // Ajout d'une liaison pour l'index sélectionné
    @Binding var currentScrollOffset: CGFloat // Ajout pour suivre la position de défilement
    @State private var scrollPhase: ScrollPhase = .idle // Ajout pour suivre la phase de défilement
    
    var body: some View {
        if let profile = userProfile {
            let needs = NutritionCalculator.shared.calculateNeeds(for: profile)
            
            VStack(spacing: 15) {
                Text("Aujourd'hui")
                    .font(.headline)
                    .blurOpacityEffect(initialAnimation)
                
                // Utilisation de votre InfiniteScrollView existante
                InfiniteScrollView {
                    // StatBox pour les calories
                    CarouselStatBox(
                        title: "Calories",
                        currentValue: "0",
                        currentUnit: "cal",
                        targetValue: "\(Int(needs.targetCalories.rounded()))",
                        targetUnit: "kcal",
                        type: .calories,
                        index: 0,
                        isExpanded: $isExpanded,
                        selectedIndex: $userSelectedStatIndex
                    )
                    
                    // StatBox pour les protéines
                    CarouselStatBox(
                        title: "Protéines",
                        currentValue: "0",
                        currentUnit: "g",
                        targetValue: "\(Int(needs.proteins.rounded()))",
                        targetUnit: "g",
                        type: .proteins,
                        index: 1,
                        isExpanded: $isExpanded,
                        selectedIndex: $userSelectedStatIndex
                    )
                    
                    // StatBox pour l'eau
                    CarouselStatBox(
                        title: "Eau",
                        currentValue: "0",
                        currentUnit: "L",
                        targetValue: "2.5",
                        targetUnit: "L",
                        type: .water,
                        index: 2,
                        isExpanded: $isExpanded,
                        selectedIndex: $userSelectedStatIndex
                    )
                }
                .scrollIndicators(.hidden)
                .scrollPosition($scrollPosition)
                .scrollClipDisabled()
                .frame(height: 180)
                .onScrollPhaseChange { oldPhase, newPhase in
                    scrollPhase = newPhase
                    
                    // Mise à jour du drapeau d'interaction utilisateur en fonction de la phase
                    if newPhase == .dragging || newPhase == .decelerating {
                        isUserInteracting = true
                    } else if newPhase == .idle {
                        // Attendre un délai plus long avant de reprendre le défilement automatique
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            if scrollPhase == .idle { // Vérifier que l'utilisateur n'a pas recommencé à défiler
                                isUserInteracting = false
                            }
                        }
                    }
                }
                .onScrollGeometryChange(for: CGFloat.self) {
                    $0.contentOffset.x + $0.contentInsets.leading
                } action: { oldValue, newValue in
                    currentScrollOffset = newValue
                    
                    // Ne mettez à jour l'index sélectionné que lorsque l'utilisateur
                    // n'est pas en train de faire défiler ou que le défilement n'est pas en train de s'arrêter
                    if scrollPhase != .decelerating && scrollPhase != .animating {
                        // Calculez l'index actif en fonction de la largeur de votre carte (170 + l'espacement)
                        let cardWidth: CGFloat = 180 // 170 de largeur + 10 d'espacement
                        let activeIndex = Int((currentScrollOffset / cardWidth).rounded()) % 3 // 3 est le nombre de cartes
                        userSelectedStatIndex = activeIndex
                    }
                }
                .visualEffect { content, proxy in
                    content
                        .offset(y: !initialAnimation ? -(proxy.size.height + 100) : 0)
                }
                // Nous remplaçons le gesture par la logique dans onScrollPhaseChange
            }
            .padding(.vertical, 10)
        }
        else {
            Text("Profil utilisateur non disponible")
                .foregroundColor(.gray)
        }
    }
}

// Version adaptée pour le carrousel
struct CarouselStatBox: View {
    let title: String
    let currentValue: String
    let currentUnit: String
    let targetValue: String
    let targetUnit: String
    let type: StatType
    let index: Int
    @Binding var isExpanded: Bool
    @Binding var selectedIndex: Int?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Actuel")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(currentValue)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                        Text(currentUnit)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Objectif")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(targetValue)
                            .font(.callout)
                            .bold()
                            .foregroundColor(.white)
                        Text(targetUnit)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(type.gradient)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 2)
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded = true
                    selectedIndex = index
                }
            }
        }
        .frame(width: 140, height: 180)
        .scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
                   content
                       .scaleEffect(phase == .identity ? 1.05 : 0.95)
                       .opacity(phase == .identity ? 1 : 0.5)
                       .offset(y: phase == .identity ? -5 : 0)
               }
           }
       }

// Types de statistiques
enum StatType {
    case calories
    case proteins
    case water
    
    var gradient: LinearGradient {
        switch self {
        case .calories:
            return LinearGradient(
                colors: [Color.orange.opacity(0.8), Color.red.opacity(0.3)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        case .proteins:
            return LinearGradient(
                colors: [Color.purple.opacity(0.6), Color.purple.opacity(0.3)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        case .water:
            return LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
    }
}

// Extension pour l'effet de flou/opacité
extension View {
    func blurOpacityEffect(_ show: Bool) -> some View {
        self
            .blur(radius: show ? 0 : 2)
            .opacity(show ? 1 : 0)
            .scaleEffect(show ? 1 : 0.9)
    }
}

// NOTE: Ces structures et extensions devront être intégrées à votre code existant
// ou adaptées selon votre implémentation spécifique

// Structure pour la phase de défilement
enum ScrollPhase {
    case idle          // Au repos
    case dragging      // L'utilisateur fait glisser
    case decelerating  // Décélération après glissement
    case animating     // Animation de défilement programmée
}

// Structure pour la position de défilement
struct ScrollPosition {
    var x: CGFloat = 0
    private var scrollViewObserver = ScrollViewObserver.shared
    
    mutating func scrollTo(x newX: CGFloat) {
        self.x = newX
        scrollViewObserver.updateScrollPosition(x: newX)
    }
}

// Singleton pour observer et contrôler le UIScrollView
class ScrollViewObserver {
    static let shared = ScrollViewObserver()
    
    private init() {}
    
    weak var scrollView: UIScrollView?
    
    func registerScrollView(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    func updateScrollPosition(x: CGFloat) {
        DispatchQueue.main.async {
            self.scrollView?.contentOffset.x = x
        }
    }
}

// Extensions pour les modifications de défilement
extension View {
    func onScrollPhaseChange(_ action: @escaping (ScrollPhase, ScrollPhase) -> Void) -> some View {
        self.background(
            ScrollPhaseObserver(action: action)
        )
    }
}

// Structure pour observer les changements de phase de défilement
struct ScrollPhaseObserver: UIViewRepresentable {
    let action: (ScrollPhase, ScrollPhase) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let scrollView = uiView.scrollView {
            if context.coordinator.scrollView == nil {
                context.coordinator.scrollView = scrollView
                context.coordinator.action = action
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var action: (ScrollPhase, ScrollPhase) -> Void
        var scrollView: UIScrollView? {
            didSet {
                if let scrollView = scrollView {
                    scrollView.delegate = self
                }
            }
        }
        var currentPhase: ScrollPhase = .idle
        
        init(action: @escaping (ScrollPhase, ScrollPhase) -> Void) {
            self.action = action
            super.init()
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            let oldPhase = currentPhase
            currentPhase = .dragging
            action(oldPhase, currentPhase)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            let oldPhase = currentPhase
            if decelerate {
                currentPhase = .decelerating
            } else {
                currentPhase = .idle
            }
            action(oldPhase, currentPhase)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let oldPhase = currentPhase
            currentPhase = .idle
            action(oldPhase, currentPhase)
        }
        
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            let oldPhase = currentPhase
            currentPhase = .idle
            action(oldPhase, currentPhase)
        }
        
        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            let oldPhase = currentPhase
            currentPhase = .decelerating
            action(oldPhase, currentPhase)
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let oldPhase = currentPhase
            currentPhase = .animating
            action(oldPhase, currentPhase)
        }
    }
}


struct ExpandedView: View {
    let needs: NutritionCalculator.NutritionNeeds
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Nutrition")
                    .font(.title2)
                    .bold()
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        isExpanded = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            // Contenu détaillé
            VStack(spacing: 15) {
                DetailedStatBox(
                    title: "Calories",
                    current: "0",
                    currentUnit: "cal",
                    // Utiliser l'arrondi pour éviter les décimales
                    target: "\(Int(needs.targetCalories.rounded()))",
                    targetUnit: "kcal",
                    maintenance: "\(Int(needs.maintenanceCalories.rounded()))kcal"
                )
                
                DetailedStatBox(
                    title: "Protéines",
                    current: "0",
                    currentUnit: "g",
                    target: "\(Int(needs.proteins.rounded()))",
                    targetUnit: "g",
                    maintenance: "\(Int(needs.proteins.rounded()))g"
                )
                
                DetailedStatBox(
                    title: "Glucides",
                    current: "0",
                    currentUnit: "g",
                    target: "\(Int(needs.carbs.rounded()))",
                    targetUnit: "g",
                    maintenance: "\(Int(needs.carbs.rounded()))g"
                )
                
                DetailedStatBox(
                    title: "Lipides",
                    current: "0",
                    currentUnit: "g",
                    target: "\(Int(needs.fats.rounded()))",
                    targetUnit: "g",
                    maintenance: "\(Int(needs.fats.rounded()))g"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
    }
}

struct DetailedStatBox: View {
    let title: String
    let current: String
    let currentUnit: String
    let target: String
    let targetUnit: String
    let maintenance: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Actuel")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(current)
                            .font(.title2)
                            .bold()
                        Text(currentUnit)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Objectif")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(target)
                            .font(.title2)
                            .bold()
                        Text(targetUnit)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Text("Maintenance: \(maintenance)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}
