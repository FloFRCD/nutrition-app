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
                WeightChartView(userProfile: userProfile)

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
    let userProfile: UserProfile
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var last7Days: [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: today)
        }.reversed()
    }

    private var generatedWeightData: [WeightEntry] {
        let start = userProfile.startingWeight
        let end = userProfile.weight
        let totalDays = 7
        
        return (0..<totalDays).compactMap { i in
            let ratio = Double(i) / Double(totalDays - 1)
            let weight = start + ratio * (end - start)
            let date = Calendar.current.date(byAdding: .day, value: -(totalDays - 1 - i), to: today)!
            return WeightEntry(date: date, weight: weight)
        }
    }
    
    private var yRange: ClosedRange<Double> {
        let min = min(userProfile.weight, userProfile.targetWeight ?? userProfile.weight)
        let max = max(userProfile.weight, userProfile.startingWeight)
        return (min - 2)...(max + 2)
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
        return formatter.string(from: date)
    }

    var body: some View {
        Chart {
            ForEach(generatedWeightData) { entry in
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
            AxisMarks(values: generatedWeightData.map(\.date)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
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
            let consumed = caloriesConsumed(on: date)
            return [
                DailyCalorieStat(date: date, value: consumed, type: "Consommées"),
                DailyCalorieStat(date: date, value: 350, type: "Brûlées")
            ]
        }
    }

    private func caloriesConsumed(on date: Date) -> Double {
        let entriesForDate = foodEntries.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        return entriesForDate.reduce(0) { $0 + $1.nutritionValues.calories }
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

