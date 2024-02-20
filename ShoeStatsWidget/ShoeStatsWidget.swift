//
//  ShoeStatsWidget.swift
//  ShoeStatsWidget
//
//  Created by Robert Basamac on 12.02.2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    
    private var modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Shoe.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }
    
    func placeholder(in context: Context) -> WidgetEntry {
        return WidgetEntry.placeholderEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        completion(WidgetEntry.placeholderEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task { @MainActor in
            var fetchDescriptor = FetchDescriptor<Shoe>()
            
            fetchDescriptor.predicate = #Predicate<Shoe> { $0.isDefaultShoe }
            if let shoes = try? modelContainer.mainContext.fetch(fetchDescriptor) {
                if let defaultShoe = shoes.first {
                    let newEntry = WidgetEntry(date: .now,
                                               brand: defaultShoe.brand,
                                               model: defaultShoe.model,
                                               lifespanDistance: defaultShoe.lifespanDistance,
                                               currentDistance: defaultShoe.currentDistance,
                                               aquisitionDate: defaultShoe.aquisitionDate,
                                               wearPercentage: defaultShoe.wearPercentage,
                                               wearPercentageAsString: defaultShoe.wearPercentageAsString,
                                               wearColor: defaultShoe.wearColor)
                    
                    let timeline = Timeline(entries: [newEntry], policy: .never)
                    completion(timeline)
                    return
                }
            }
            
            let newEntry = WidgetEntry(date: .now,
                                       brand: "No brand",
                                       model: "No model", lifespanDistance: 0.0,
                                       currentDistance: 0.0,
                                       aquisitionDate: .now,
                                       wearPercentage: 0.0,
                                       wearPercentageAsString: "0.0",
                                       wearColor: .green)
            let timeline = Timeline(entries: [newEntry], policy: .never)
            
            completion(timeline)
        }
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    
    var brand: String
    var model: String
    var lifespanDistance: Double
    var currentDistance: Double
    var aquisitionDate: Date
    var wearPercentage: Double
    var wearPercentageAsString: String
    var wearColor: Color
    
    static var placeholderEntry: WidgetEntry {
        let shoe: Shoe = Shoe.previewShoe
        
        return WidgetEntry(date: .now,
                           brand: shoe.brand,
                           model: shoe.model,
                           lifespanDistance: shoe.lifespanDistance,
                           currentDistance: shoe.currentDistance,
                           aquisitionDate: shoe.aquisitionDate,
                           wearPercentage: shoe.wearPercentage,
                           wearPercentageAsString: shoe.wearPercentageAsString,
                           wearColor: shoe.wearColor)
    }
}

struct ShoeStatsWidgetEntryView : View {
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.brand)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                
                Text(entry.model)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 0)
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    ShoeStatView(label: "CURRENT", value: "\(distanceFormatter.string(fromValue: entry.currentDistance, unit: .kilometer).uppercased())", color: Color.yellow, labelFont: .system(size: 9), valueFont: .system(size: 13), alignement: .leading)
                    ShoeStatView(label: "REMAINING", value: "\(distanceFormatter.string(fromValue: entry.lifespanDistance - entry.currentDistance, unit: .kilometer).uppercased())", color: Color.blue, labelFont: .system(size: 9), valueFont: .system(size: 13), alignement: .leading)
                }
                .contentTransition(.numericText(value: entry.currentDistance))
                
                Spacer(minLength: 0)
                
                ZStack {
                    CircularProgressView(progress: entry.wearPercentage, lineWidth: 4, color: entry.wearColor)
                    ShoeStatView(label: "WEAR", value: "\(entry.wearPercentageAsString.uppercased())", color: entry.wearColor, labelFont: .system(size: 8), valueFont: .system(size: 12))
                }
                .padding(2)
            }
            
            Text("Last Activity: \(dateFormatter.string(from: entry.aquisitionDate))")
                .font(.system(size: 10))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ShoeStatsWidget: Widget {
    
    let kind: String = "ShoeStatsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ShoeStatsWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        ZStack {
                            Color.black
                            LinearGradient(colors: [entry.wearColor.opacity(0.5),
                                                    .black
                                                   ],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        }
                    }
                    .modelContainer(for: [Shoe.self])
            } else {
                ShoeStatsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
                    .modelContainer(for: [Shoe.self])
            }
        }
        .configurationDisplayName("Default Shoe Stats")
        .description("Default Shoe stats widget.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    ShoeStatsWidget()
} timeline: {
    WidgetEntry(date: .now,
                brand: Shoe.previewShoe.brand,
                model: Shoe.previewShoe.model,
                lifespanDistance: Shoe.previewShoe.lifespanDistance,
                currentDistance: Shoe.previewShoe.currentDistance,
                aquisitionDate: Shoe.previewShoe.aquisitionDate,
                wearPercentage: Shoe.previewShoe.wearPercentage,
                wearPercentageAsString: Shoe.previewShoe.wearPercentageAsString,
                wearColor: Shoe.previewShoe.wearColor)
}
