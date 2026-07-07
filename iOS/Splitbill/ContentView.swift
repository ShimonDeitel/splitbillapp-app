import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: GroupBill?

    @State private var newRestaurant: String = ""
    @State private var newTotal: String = ""
    @State private var newPeopleNote: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if store.items.isEmpty {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "leaf",
                        description: Text("Tap + to add your first entry.")
                    )
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                                loadEdit(item)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.restaurant)
                                        .font(Theme.headlineFont)
                                        .foregroundStyle(.primary)
                                    Text(item.total + " · " + item.peopleNote)
                                        .font(Theme.captionFont)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .accessibilityIdentifier("itemRow_\(item.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Splitbill")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                addSheet
            }
            .sheet(item: $editingItem) { item in
                editSheet(for: item)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                TextField("Restaurant", text: $newRestaurant)
                    .accessibilityIdentifier("addRestaurantField")
                TextField("Total", text: $newTotal)
                    .accessibilityIdentifier("addTotalField")
                TextField("PeopleNote", text: $newPeopleNote)
                    .accessibilityIdentifier("addPeopleNoteField")
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Add Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAdd = false
                    }
                    .accessibilityIdentifier("addCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = GroupBill(restaurant: newRestaurant, total: newTotal, peopleNote: newPeopleNote)
                        store.add(item)
                        resetNew()
                        showAdd = false
                    }
                    .accessibilityIdentifier("addSaveButton")
                    .disabled(newRestaurant.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func editSheet(for item: GroupBill) -> some View {
        NavigationStack {
            Form {
                TextField("Restaurant", text: $editRestaurant)
                    .accessibilityIdentifier("editRestaurantField")
                TextField("Total", text: $editTotal)
                    .accessibilityIdentifier("editTotalField")
                TextField("PeopleNote", text: $editPeopleNote)
                    .accessibilityIdentifier("editPeopleNoteField")
                Button("Delete Entry", role: .destructive) {
                    store.delete(item)
                    editingItem = nil
                }
                .accessibilityIdentifier("editDeleteButton")
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        editingItem = nil
                    }
                    .accessibilityIdentifier("editCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = item
        updated.restaurant = editRestaurant
        updated.total = editTotal
        updated.peopleNote = editPeopleNote
                        store.update(updated)
                        editingItem = nil
                    }
                    .accessibilityIdentifier("editSaveButton")
                }
            }
        }
    }

    private func resetNew() {
        newRestaurant = ""
        newTotal = ""
        newPeopleNote = ""
    }

    private func loadEdit(_ item: GroupBill) {
        editRestaurant = item.restaurant
        editTotal = item.total
        editPeopleNote = item.peopleNote
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
