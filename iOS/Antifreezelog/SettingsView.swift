import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("antifreezelog_notifyEnabled") private var notifyEnabled: Bool = true
    @AppStorage("antifreezelog_darkAccent") private var darkAccent: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Enable Reminders", isOn: $notifyEnabled)
                        .accessibilityIdentifier("settingsNotifyToggle")
                    Toggle("Use Accent Theme", isOn: $darkAccent)
                        .accessibilityIdentifier("settingsAccentToggle")
                }

                Section("Subscription") {
                    if purchaseManager.isPurchased {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Button("Restore Purchases") {
                            Task { await purchaseManager.restore() }
                        }
                        .accessibilityIdentifier("settingsRestoreButton")
                    }
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/antifreezelog-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/antifreezelog-app/terms.html")!)
                    Text("Antifreeze Season Log v1.0")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
