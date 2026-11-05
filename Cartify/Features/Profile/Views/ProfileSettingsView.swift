import SwiftUI

struct ProfileSettingsView: View {
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system.rawValue

    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: $appearance) {
                    ForEach(AppAppearance.allCases) { option in
                        Text(option.title).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text("Choose a look, or match your device settings.")
            }
            Section("About Cartify") {
                LabeledContent("Version", value: version)
                Text("Cartify is a learning project. Payments are simulated; no real money is charged.")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColors.primary)
    }

    private var version: String {
        let release = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(release) (\(build))"
    }
}
