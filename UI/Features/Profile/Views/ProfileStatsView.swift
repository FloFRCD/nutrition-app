import SwiftUI
import Charts

struct ProfileStatsView: View {
    @State private var selectedTab = 0
    
    let weightData: [WeightEntry]
    let foodEntries: [FoodEntry]
    let userProfile: UserProfile
    
    var body: some View {
        VStack {
            // Titre avec navigation par swipe
            HStack {
                // Indicateur de swipe
                Image(systemName: "hand.draw")
                    .foregroundColor(.gray)
                    .overlay(
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 8))
                            .offset(y: 10)
                            .foregroundColor(.gray)
                    )
            }
            .padding(.horizontal)
            
            // TabView avec effet de swipe
            TabView(selection: $selectedTab) {
                // Premier graphique: Poids
                WeightChartView(weightData: weightData)

                    .tag(0)
                
                // Second graphique: Calories
                CaloriesChartView(foodEntries: foodEntries)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 280)
            
            // Légende statique
            if selectedTab == 0 {
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                        Text("Poids")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding()
            } else {
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 10, height: 10)
                        Text("Calories consommées")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                        Text("Calories brûlées")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
        }
    }
}

struct WeightChartView: View {
    let weightData: [WeightEntry] // ✅ Données passées depuis ProfileStatsView

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var last7Days: [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: today)
        }.reversed()
    }

    private func filledWeightData(from entries: [WeightEntry]) -> [WeightEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let last7Days = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }.reversed()

        let sortedEntries = entries.sorted(by: { $0.date < $1.date })

        var result: [WeightEntry] = []
        var lastKnownWeight: Double? = nil

        for day in last7Days {
            if let entry = sortedEntries.first(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                lastKnownWeight = entry.weight
                result.append(entry)
            } else if let last = lastKnownWeight {
                result.append(WeightEntry(date: day, weight: last))
            } else {
                // ⚠️ On ne génère rien si on n’a aucune donnée
                continue
            }
        }

        return result
    }


    private var yRange: ClosedRange<Double> {
        let weights = filledWeightData(from: weightData).map { $0.weight }
        guard let min = weights.min(), let max = weights.max() else {
            return 60...100
        }

        // Ajoute une marge pour aérer le graphique
        let padding = 2.0
        let lowerBound = floor(min - padding)
        let upperBound = ceil(max + padding)

        return lowerBound...upperBound
    }


    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
        return formatter.string(from: date)
    }

    var body: some View {
        Chart {
            ForEach(filledWeightData(from: weightData), id: \.date) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Poids", entry.weight)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(.green)

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Poids", entry.weight)
                )
                .foregroundStyle(.green)
            }
        }
        .chartYScale(domain: yRange)
        .chartXAxis {
            AxisMarks(values: last7Days) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(dayLabel(for: date))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .padding()
    }
}






struct CaloriesChartView: View {
    let foodEntries: [FoodEntry]
    @StateObject var viewModel = JournalViewModel()

    private var lastSevenDays: [Date] {
        let calendar = Calendar.current
        return (0..<7).map { day in
            calendar.date(byAdding: .day, value: -day, to: Date()) ?? Date()
        }.reversed()
    }

    // Formateur pour n'afficher que le jour
    private func dayNumberFormatter(from date: Date) -> String {
        String(Calendar.current.component(.day, from: date))
    }

    // Données formatées
    private var calorieStats: [DailyCalorieStat] {
        lastSevenDays.flatMap { date in
            let consumed = viewModel.caloriesConsumed(on: date)
            let burned = viewModel.getBurnedCalories(for: date)
            return [
                DailyCalorieStat(date: date, value: consumed, type: "Consommées"),
                DailyCalorieStat(date: date, value: burned, type: "Brûlées")
            ]
        }
    }
    private var maxCalorieScale: Double {
        let maxValue = calorieStats.map { $0.value }.max() ?? 0
        return max(2000, ceil(maxValue / 500) * 500)
    }

    var body: some View {
        Chart {
            ForEach(calorieStats) { stat in
                BarMark(
                    x: .value("Jour", dayNumberFormatter(from: stat.date)),
                    y: .value("Calories", stat.value)
                )
                .foregroundStyle(by: .value("Type", stat.type))
                .position(by: .value("Type", stat.type))
            }
        }        .chartForegroundStyleScale([
            "Consommées": Color.orange.opacity(0.7),
            "Brûlées": Color.blue.opacity(0.6)
        ])

        .chartXAxis {
            AxisMarks(values: lastSevenDays) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(dayNumberFormatter(from: date))
                    }
                }
            }
        }
        .chartYScale(domain: 0...maxCalorieScale)
        .chartYAxis {
            AxisMarks(position: .trailing)
        }
        .padding()
    }
}

