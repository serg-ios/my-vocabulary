//
//  MyVocabularyWidget.swift
//  MyVocabularyWidget
//
//  Created by Sergio Rodríguez Rama on 25/5/21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    var mockEntry: SimpleEntry {
        SimpleEntry(
            date: Date(),
            translation: Translation.example(viewContext: DataController.preview.container.viewContext)
        )
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        mockEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(mockEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []
        var components = Calendar.current.dateComponents(
            [.era, .year, .month, .day, .hour, .minute, .second],
            from: Date()
        )
        components.second = 0
        let roundedDate = Calendar.current.date(from: components)!
        let translations = loadTranslations()
        if translations.isEmpty {
            let timeline = Timeline(entries: [mockEntry], policy: .never)
            completion(timeline)
        } else {
            for second in stride(from: 0, to: 60 * 60, by: 5) {
                let randomTranslation = translations[Int.random(in: 0..<translations.count)]
                let entryDate = Calendar.current.date(byAdding: .second, value: second, to: roundedDate)!
                let model = SimpleEntry(date: entryDate, translation: randomTranslation)
                entries.append(model)
            }
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func loadTranslations() -> [Translation] {
        DataController().translationsForWidget()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let translation: Translation
}

struct MyVocabularyWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text(entry.translation.translationInput)
                .font(.title)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.2)
            Spacer()
            Text(entry.translation.translationOutput)
                .font(.title3)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
            Spacer()
            SegmentedProgressBar(level: entry.translation.level)
                .frame(height: 6)
        }
        .padding()
    }
}

@main
struct MyVocabularyWidget: Widget {
    let kind: String = "MyVocabularyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MyVocabularyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct MyVocabularyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyVocabularyWidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                translation: Translation.example(viewContext: DataController.preview.container.viewContext)
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
