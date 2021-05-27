//
//  TranslationsView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/2/21.
//

import SwiftUI
import CoreHaptics

struct TranslationsView: View {
    
    @State private var engine = try? CHHapticEngine()
    @StateObject private var viewModel: ViewModel
    @Binding var translations: [Translation]
    
    init(translations: Binding<[Translation]>, viewModel: ViewModel) {
        self._translations = translations
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
        return NavigationView {
            Group {
                if case .loaded(let filteredTranslations) = viewModel.status {
                    VStack {
                        SearchBarView(
                            placeholder: "Filter",
                            accessibilityLabel: "Filter translations by.",
                            searchString: $viewModel.searchString.onChange {
                                viewModel.updateStatus(for: translations)
                            },
                            error: {
                                filteredTranslations.isEmpty ? "Not found." : nil
                            }
                        )
                        ForEach(filteredTranslations, id: \.self) { translation in
                            TranslationView(translation: translation)
                        }
                        .scrollableLazyVStack(showIndicators: true)
                    }
                    .accentColor(Color("Light Blue"))
                    .toolbar {
                        ToolbarItem {
                            Button {
                                deleteAllTranslationsHapticEffect()
                                viewModel.deleteAll()
                                UIApplication.shared.sendAction(
                                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                                )
                            } label: {
                                if UIAccessibility.isVoiceOverRunning {
                                    Text("Delete all imported translations")
                                } else {
                                    Image(systemName: "xmark.bin")
                                }
                            }
                            .disabled(!viewModel.searchString.isEmpty)
                        }
                    }
                } else {
                    PlaceholderView(
                        image: Image(systemName: "externaldrive.badge.plus"),
                        text: Text("First, export your Google Translate favorite translations into a Google Drive spreadsheet.")
                    )
                }
            }
            .navigationTitle(Text("Translations"))
        }
        .accentColor(Color("Red"))
        .onAppear { viewModel.updateStatus(for: translations) }
        .onChange(of: translations, perform: viewModel.updateStatus)
    }
    
    // MARK: - Haptics
    
    private func deleteAllTranslationsHapticEffect() {
        do {
            try engine?.start()
            // Sharpness determines if the effect is pronounced or dull.
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
            // Intensity determines the strength of the vibration.
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            // Core Haptics will create a smooth curve between control points.
            let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
            let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
            // Create the curve to put together all the control points.
            let parameter = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [start, end],
                relativeTime: 0
            )
            // First event, a quick tap.
            let event1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: 0
            )
            // Second event, a 1 second buzz that starts 0.125 seconds after the previous event.
            let event2 = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [sharpness, intensity],
                relativeTime: 0.125,
                duration: 1
            )
            // A pattern puts together the curve and the events.
            let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])
            // Everything is ready, play the effect!
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            // playing haptics didn't work, but that's okay
        }
    }
}


// MARK: - Preview

struct TranslationsView_Previews: PreviewProvider {
    static var previews: some View {
        let dataController = DataController.preview
        TranslationsView(
            translations: .constant(
                [
                    .example(viewContext: dataController.container.viewContext),
                    .example(viewContext: dataController.container.viewContext),
                    .example(viewContext: dataController.container.viewContext)
                ]
            ),
            viewModel: .init(dataController: dataController)
        )
    }
}
