import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingAddSheet = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: CheckEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.entries) { entry in
                    Button(action: { editingEntry = entry }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.vehicle)").font(Theme.headingFont)
                            Text("\(entry.ratio)").font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                    .buttonStyle(.plain)
                }
                .onDelete(perform: store.delete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Antifreeze Season Log")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if store.canAddMore {
                            showingAddSheet = true
                        } else {
                            showingPaywall = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .overlay {
                if store.entries.isEmpty {
                    ContentUnavailableView("No Checks Yet", systemImage: "tray", description: Text("Tap + to add your first check."))
                }
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    let existing: CheckEntry?
    let onSave: (CheckEntry) -> Void

    @State private var vehicle: String
    @State private var ratio: String
    @State private var tempRating: String
    @State private var date: Date
    @State private var notes: String

    init(entry: CheckEntry?, onSave: @escaping (CheckEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _vehicle = State(initialValue: entry?.vehicle ?? "")
        _ratio = State(initialValue: entry?.ratio ?? "")
        _tempRating = State(initialValue: entry?.tempRating ?? "")
        _date = State(initialValue: entry?.date ?? Date())
        _notes = State(initialValue: entry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Vehicle", text: $vehicle)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_vehicleField")
                TextField("Ratio", text: $ratio)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_ratioField")
                TextField("TempRating", text: $tempRating)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_tempRatingField")
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Notes", text: $notes)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_notesField")
            }
            .navigationTitle(existing == nil ? "Add Check" : "Edit Check")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("formSaveButton")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
    }

    private func save() {
        let id = existing?.id ?? UUID()
        let entry = CheckEntry(id: id, vehicle: vehicle, ratio: ratio, tempRating: tempRating, date: date, notes: notes)
        onSave(entry)
    }
}
