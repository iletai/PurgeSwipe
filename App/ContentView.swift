import SwiftUI

/// Home. Replace the placeholder copy with the app's real content before shipping.
struct ContentView: View {
    @State private var isShowingSettings = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(.largeTitle, design: .default, weight: .semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text("home.title")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("home.subtitle")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("home.navigationTitle")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingSettings = true
                } label: {
                    Label("settings.title", systemImage: "gearshape")
                }
                .accessibilityIdentifier("home.settings")
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
