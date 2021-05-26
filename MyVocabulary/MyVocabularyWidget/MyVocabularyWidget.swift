//
//  MyVocabularyWidget.swift
//  MyVocabularyWidget
//
//  Created by Sergio Rodríguez Rama on 25/5/21.
//

import WidgetKit
import SwiftUI

// MARK: - Random provider

struct RandomEntry: TimelineEntry {
    let date: Date
    let translation: Translation
}

struct RandomProvider: TimelineProvider {
    
    static var mockRandomEntry: RandomEntry {
        RandomEntry(
            date: Date(),
            translation: Translation.example(viewContext: DataController.preview.container.viewContext)
        )
    }
    
    func placeholder(in context: Context) -> RandomEntry {
        Self.mockRandomEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (RandomEntry) -> Void) {
        completion(Self.mockRandomEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [RandomEntry] = []
        var components = Calendar.current.dateComponents(
            [.era, .year, .month, .day, .hour, .minute, .second],
            from: Date()
        )
        components.second = 0
        let roundedDate = Calendar.current.date(from: components)!
        let translations = loadTranslations()
        if translations.isEmpty {
            let timeline = Timeline(entries: [Self.mockRandomEntry], policy: .never)
            completion(timeline)
        } else {
            for second in stride(from: 0, to: 60 * 60, by: 5) {
                let randomTranslation = translations[Int.random(in: 0..<translations.count)]
                let entryDate = Calendar.current.date(byAdding: .second, value: second, to: roundedDate)!
                let model = RandomEntry(date: entryDate, translation: randomTranslation)
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

// MARK: - Multiple provider

struct MultipleEntry: TimelineEntry {
    let date: Date
    let translations: [Translation]
}

struct MultipleProvider: TimelineProvider {
    
    static var mockMultipleEntry: MultipleEntry {
        MultipleEntry(
            date: Date(),
            translations: [
                Translation.example(viewContext: DataController.preview.container.viewContext),
                Translation.example(viewContext: DataController.preview.container.viewContext),
                Translation.example(viewContext: DataController.preview.container.viewContext),
                Translation.example(viewContext: DataController.preview.container.viewContext),
                Translation.example(viewContext: DataController.preview.container.viewContext),
                Translation.example(viewContext: DataController.preview.container.viewContext),
            ]
        )
    }
    
    func placeholder(in context: Context) -> MultipleEntry {
        Self.mockMultipleEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (MultipleEntry) -> Void) {
        completion(Self.mockMultipleEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let translations = loadTranslations().sorted { $0.level < $1.level }
        if translations.count < 6 {
            let timeline = Timeline(entries: [Self.mockMultipleEntry], policy: .never)
            completion(timeline)
        } else {
            let entry = MultipleEntry(date: Date(), translations: [
                translations[0],
                translations[1],
                translations[2],
                translations[3],
                translations[4],
                translations[5]
            ])
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
    
    private func loadTranslations() -> [Translation] {
        DataController().translationsForWidget()
    }
}

// MARK: - Widgets' view

struct TranslationInWidgetView: View {
    
    var translation: Translation
    
    var body: some View {
        VStack {
            Text(translation.translationInput)
                .font(.title)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.2)
            Spacer()
            Text(translation.translationOutput)
                .font(.title3)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
            Spacer()
            SegmentedProgressBar(level: translation.level)
                .frame(height: 6)
        }
        .padding()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(translation.translationInput) in \(translation.translationFrom), \(translation.translationOutput) in \(translation.translationTo) . Level \(translation.level).")
    }
}

struct RandomTranslationWidgetEntryView: View {
    var entry: RandomProvider.Entry
    
    var body: some View {
        TranslationInWidgetView(translation: entry.translation)
    }
}

struct MultipleTranslationsWidgetEntryView: View {
    var entry: MultipleProvider.Entry

    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), content: {
            ForEach(entry.translations, id: \.self) {
                TranslationInWidgetView(translation: $0)
            }
        })
    }
}

// MARK: - Widgets

struct MultipleTranslationsWidget: Widget {
    let kind: String = "MultipleTranslationsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MultipleProvider()) { entry in
            MultipleTranslationsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("6 most difficult translations")
        .description("These are the 6 translations with the lowest level.")
        .supportedFamilies([.systemLarge])
    }
}

struct RandomTranslationWidget: Widget {
    let kind: String = "RandomTranslationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RandomProvider()) { entry in
            RandomTranslationWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Random translation")
        .description("The translations changes every 5 seconds.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct MyVocabularyWidgets: WidgetBundle {
    var body: some Widget {
        RandomTranslationWidget()
        MultipleTranslationsWidget()
    }
}

// MARK: - Preview

struct MyVocabularyWidget_Previews: PreviewProvider {
    static var previews: some View {
        RandomTranslationWidgetEntryView(entry: RandomProvider.mockRandomEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        MultipleTranslationsWidgetEntryView(entry: MultipleProvider.mockMultipleEntry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
