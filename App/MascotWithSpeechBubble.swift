//
//  MascotWithSpeechBubble.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 06/05/2025.
//

import Foundation
import SwiftUICore

struct MascotSpeechBubble: View {
    var message: String
    
    var body: some View {
        HStack(spacing: 0) {
            // Texte dans la bulle
            Text(message)
                .font(message.count > 80 ? .footnote : .subheadline)
                .lineLimit(3)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(SpeechBubbleShape().fill(AppTheme.cardBackground))
                .frame(width: 260, alignment: .trailing)
        }
    }
}

struct SpeechBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 20.0
        let triangleSize: CGFloat = 10.0
        
        // Commencer en haut à gauche
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        
        // Top-left corner
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(270),
                    endAngle: .degrees(180),
                    clockwise: true)
        
        // Left side
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(90),
                    clockwise: true)
        
        // Bottom
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(0),
                    clockwise: true)
        
        // Right side up
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius + triangleSize))
        
        // Triangle intégré en haut à droite
        path.addLine(to: CGPoint(x: rect.maxX + triangleSize, y: rect.minY + cornerRadius + triangleSize / 2))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius))
        
        // Top-right arc
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(270),
                    clockwise: true)
        
        path.closeSubpath()
        return path
    }
}



struct MascotWithSpeechBubble: View {
    var message: String
    @State private var showBubble = true

    var body: some View {
        HStack(alignment: .bottom, spacing: -36) {
            Spacer()
            
            if showBubble {
                MascotSpeechBubble(message: message)
                    .offset(y: -64)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: showBubble)
                    .zIndex(1)
            }

            Image("nutria_mascot")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .onTapGesture {
                    withAnimation {
                        showBubble.toggle()
                    }
                }
                .zIndex(0)
        }
        .padding(.horizontal)
        .padding(.bottom, 70)
    }
}


struct MotivationService {
    static func randomMessage(for goal: FitnessGoal) -> String {
        var messages: [String] = []
        
        if goal == .loseWeight {
            messages = [
                "On avance à ton rythme, et c’est parfait 🚶",
                "Petit pas par petit pas… je suis là 🐾",
                "On garde le cap ensemble 💚",
                "Je suis fier d’être ton copilote 🤝",
                "T’as pas à tout faire d’un coup. Juste un pas aujourd’hui 👌",
                "Si t’as besoin d’un boost, je suis là ! ⚡",
                "Un jour à la fois, t’es régulier, et ça compte ✨",
                "Tu fais de ton mieux, et c’est largement suffisant 💪",
                "Je suis là, même dans les jours où c’est plus dur 👀",
                "C’est pas une course. On est sur le bon chemin 🛤️",
                "C’est normal d’avoir des hauts et des bas. Ce qui compte, c’est d’avancer 🧭",
                "T’as tenu bon aujourd’hui ? Respect ✨",
                "Tu fais preuve de patience, et ça se voit 💚",
                "Continue comme ça, sans pression. On avance ensemble 🤝",
                "Je suis dans ta poche pour t’accompagner, pas te juger 😉",
                "Si tu regardes en arrière, t’as déjà fait un beau chemin 👣",
                "Bois un verre d’eau et respire. Ça va le faire 💧",
                "Ta constance est ta meilleure alliée 🔁",
                "Même les petits efforts font une grande différence 🪴",
                "T’es en train de construire quelque chose de solide, jour après jour 💼",
                "Prends soin de toi comme tu prends soin des autres ❤️",
                "Une journée à la fois. Pas de pression 🎈",
                "On ne cherche pas la perfection, juste du progrès 📉➡️📈",
                "Ton corps mérite de la bienveillance, pas du jugement ✋",
                "Je suis là pour t’encourager, pas te mettre la pression 🦫",
                "Tu prends les bonnes décisions pour toi, à ton rythme ⏳",
                "T’as pas besoin d’aller vite. Juste de pas abandonner 🔁",
                "Mets-toi en mode douceur aujourd’hui 🌤️",
                "Ton énergie compte plus que ton poids ⚖️💡",
                "T’as bien fait d’ouvrir l’app aujourd’hui 👏",
                "Respire un coup, on continue demain aussi 🌿",
                "Tu fais preuve de courage, et ça, c’est précieux 🧡",
                "Laisse-toi le droit d’être humain, et de faire de ton mieux chaque jour 🙂",
                "Même les pas discrets nous font avancer 👣",
                "Ton engagement avec toi-même est déjà une victoire 🏁",
                "Si aujourd’hui c’est dur, demain sera peut-être plus doux ☁️",
                "Ta démarche est belle, peu importe le rythme 💫",
                "Fais confiance à ton chemin. Il est unique 🗺️",
                "Ce que tu fais maintenant, c’est te respecter. Et c’est fort 💥",
                "Un petit repas plus équilibré, une victoire silencieuse 🥗",
                "Même les pauses font partie du voyage 🧘",
                "Ton écoute de toi-même vaut plus que tous les chiffres 📊",
                "Je suis là tous les jours, même les plus discrets 🦫",
                "Tu peux être fier(e) de chaque intention que tu poses 🌱",
                "Ce n’est pas un sprint. C’est une histoire de régularité ⏱️",
                "On fait équipe. Je t’accompagne avec bienveillance 🧡",
                "Le fait d’être ici aujourd’hui, c’est déjà un pas énorme 👏",
                "Ton corps est ton allié. Écoute-le avec patience 👂",
                "Je te suis, jour après jour. On lâche rien 🐾"
            ]
        }
        
        if goal == .maintainWeight {
            messages = [
                "Tu es dans ta zone d'équilibre 🧘‍♂️",
                "Stabilité au top, bravo ✨",
                "Tu gères ça comme un(e) pro 🏆",
                "Rien à redire, tu es constant(e) 👌",
                "Équilibre parfait jour après jour 🧩",
                "Ton calme est une force tranquille 🌿",
                "Je vois que tu maîtrises, comme d’hab 💼",
                "Pas de vagues, juste du flow 🌀",
                "Même moi je suis impressionné par ta régularité 🦫",
                "L’équilibre, c’est un art, et tu le maîtrises 🎨",
                "Ta routine est solide comme un roc 🧱",
                "On reste focus, sans pression ✨",
                "Tu fais ça avec classe et constance 🎩",
                "Un bon rythme, stable et sans stress 😌",
                "T’as une constance qui inspire 👏",
                "Ta stabilité est plus forte qu’un ragondin en yoga 🧘🦫",
                "Je pourrais prendre exemple sur ta régularité 😅",
                "Tu fais les bons choix, sans te prendre la tête 🧠",
                "C’est fluide, simple, efficace 💡",
                "Pas besoin d’en faire trop. Tu fais ce qu’il faut, juste ce qu’il faut 👍",
                "Je te regarde aller et franchement, c’est beau à voir 👀",
                "T’as compris que l’équilibre, c’est pas une destination. C’est un mode de vie 🌱",
                "Ta ligne de conduite est droite comme une flèche ➡️",
                "J’ai jamais vu un aussi bon maintien (et j’ai vu des castors au garde-à-vous) 😄",
                "Même si tu ne le vois pas, ton corps te remercie chaque jour 🙌",
                "C’est calme, mais c’est puissant 🧘‍♀️",
                "Ton assiette est une œuvre d’art équilibrée 🎨🥗",
                "Chaque repas géré, c’est une victoire silencieuse ✨",
                "On garde le cap, comme d’hab’ ⛵",
                "La régularité, c’est ton super pouvoir 🦸",
                "Je reste dans ta poche au cas où… mais t’as pas l’air d’avoir besoin de moi 😉",
                "Le maintien, c’est aussi de la discipline, et tu la gères 👌",
                "Une journée de plus dans le vert ✅",
                "Ce calme dans tes habitudes, c’est inspirant 🌾",
                "Franchement, tu pourrais donner des cours 📚",
                "Tu balances pas, tu maîtrises ⚖️",
                "Chaque jour où tu continues, c’est un jour où tu gagnes ✨",
                "Même moi j’ai jamais été aussi constant (et je mange 7 fois par jour 😅)",
                "T’as la régularité d’une horloge suisse 🕰️",
                "Ton corps aime cette stabilité, et moi aussi 🫶",
                "C’est pas spectaculaire, mais c’est durable 🌳",
                "On est bien là, non ? 😌",
                "Rien ne bouge trop, mais tout avance 🐢",
                "J’aimerais que tous les NutriaUsers soient aussi zen que toi 🧘",
                "Chaque jour stable t’éloigne des extrêmes 👣",
                "Tu montres que l’équilibre, c’est aussi un engagement 💪",
                "Même les journées banales sont précieuses dans ton parcours 🌤️",
                "T’es un(e) pro du juste milieu ⚖️",
                "Stabilité + bienveillance = combo gagnant 🧡"
            ]
        }
        
        if goal == .gainMuscle {
            messages = [
                "Tu prends du muscle, continue ! 💪",
                "Bravo pour ta discipline ! 🏋️‍♂️",
                "Les résultats arrivent, ne lâche rien 🚀",
                "Un jour à la fois, tu construis ton corps 🔨",
                "Ta constance paie 💯",
                "On nourrit le corps, doucement mais sûrement 🍽️",
                "Tu poses les briques un jour après l’autre 🧱",
                "Pas besoin d’en faire trop, juste régulier 🔄",
                "Le muscle aime la patience… et moi aussi 😌",
                "On reste concentrés, un repas à la fois 🍗",
                "Chaque portion compte, même la plus discrète 🥣",
                "Tu construis du solide, et ça se voit déjà 💥",
                "Je te soutiens entre chaque série 💪🦫",
                "Ajoute une cuillère de motivation à ton shake du jour 🥤",
                "C’est pas magique, c’est mathématique : effort + régularité = résultats 📈",
                "Un repas bien pensé, c’est un pas vers ton objectif 🍽️",
                "Tu gères ça comme un chef de chantier 💼",
                "Même les jours off comptent pour construire 🛌",
                "Je vois tes efforts, et franchement, chapeau 👏",
                "Chaque répétition te rapproche du but 🔁",
                "Ton corps te suit parce que tu lui montres le bon chemin 👣",
                "T’as tout pour prendre en force, et moi pour t’encourager 🦫",
                "Petit à petit, tu sculptes ton énergie ⚒️",
                "On vise la masse, mais avec grâce 😄",
                "Fier de toi, vraiment. C’est pas donné à tout le monde cette rigueur 💪",
                "T’as pesé ton riz aujourd’hui ? Respect 😅",
                "Chaque fourchette, chaque série… ça s’empile en muscle 🏗️",
                "Tu avances avec sérieux, sans prise de tête. Le combo parfait 🧠",
                "Continue, et je te dessine un six-pack sur le badge Nutria 🧃",
                "Y’a pas que les haltères qui sont lourds, y’a ton engagement aussi 🏋️",
                "T’es dans la phase gain, et je suis ton fan #1 🎉",
                "Même les collations sont des missions 👀",
                "Un peu plus chaque semaine. C’est comme ça qu’on gagne 📊",
                "Ta discipline est plus sèche que du blanc de poulet 😄",
                "Je vois déjà les épaules qui prennent 💥",
                "T’as pas besoin de forcer, juste de continuer 🔄",
                "T’as passé le cap où t’oublies jamais ton shaker 🧴",
                "Les efforts d’aujourd’hui = la force de demain 💣",
                "Faut du carburant pour faire tourner la machine 🔋",
                "Je note ta détermination, elle est plus massive que ta protéine 😅",
                "Ton t-shirt est un peu plus serré ou c’est moi ? 😏",
                "Chaque repas est stratégique, et tu le sais 🍽️🎯",
                "Continue sur cette lancée, ça paie toujours 🔁",
                "Je suis ton ragondin coach, et je valide tout 🦫✅",
                "Construire prend du temps. Et toi, tu le fais bien ⏱️",
                "Objectif volume : enclenché 📦",
                "Tu fais ça propre. Pas dans l’urgence. Et c’est le top 🧼"
            ]
        }
        
        return messages.randomElement() ?? "Content de te retrouver !"
    }
}


