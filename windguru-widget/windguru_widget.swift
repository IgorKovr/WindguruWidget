//
//  windguru_widget.swift
//  windguru-widget
//
//  Created by Igor Kovryzhkin on 27.04.24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct windguru_widgetEntryView : View {
    var entry: Provider.Entry
    var image: NSImage
    
    init(entry: Provider.Entry) {
        self.entry = entry
        self.image = NSImage()
        let fileManager = FileManager.default
        do {
            let downloadsURL = try fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            print("Downloads Directory: \(downloadsURL)")
            guard let image = NSImage(contentsOf: URL(fileURLWithPath: "/Downloads/windguru_screnshot_image.png")) else {
                print("Error: windguru snapshot image not found")
                
//                self.image = NSImage(contentsOf: URL(fileURLWithPath: "/Downloads/windguru_screnshot_image.png"))!
                return
            }
            self.image = image
        } catch {
            print("Error getting the Downloads directory: \(error)")
        }
    }
    
    var body: some View {
        VStack {
            Image(nsImage: image).frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.center)
        }
    }
}

struct windguru_widget: Widget {
    let kind: String = "windguru_widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            windguru_widgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
