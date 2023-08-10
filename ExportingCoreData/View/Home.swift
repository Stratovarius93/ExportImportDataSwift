//
//  Home.swift
//  ExportingCoreData
//
//  Created by Juan Carlos Catagña Tipantuña on 5/8/23.
//

import CoreData
import SwiftUI

struct Home: View {
    /// View properties
    @State private var addExpense: Bool = false
    /// Fetching CoreData Entity
    @FetchRequest(entity: Purchase.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Purchase.dateOfPurchase, ascending: false)], animation: .easeInOut(duration: 0.3)) private var purchaseItems: FetchedResults<Purchase>
    @Environment(\.managedObjectContext) private var context
    /// ShareSheet Properties
    @State private var presentShareSheet: Bool = false
    @State private var shareURL: URL = .init(string: "https://www.apple.com/")!
    @State private var presentFilePicker: Bool = false
    var body: some View {
        NavigationStack {
            List {
                /// Displaying Purchased items
                ForEach(purchaseItems) { value in
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(value.title ?? "")
                                .fontWeight(.semibold)
                            Text((value.dateOfPurchase ?? .init()).formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer(minLength: 0)
                        /// Displaying in currency format
                        Text(currencyFormatter.string(from: NSNumber(value: value.amountSpent)) ?? "")
                            .fontWeight(.bold)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("My Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addExpense.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Import") {
                            presentFilePicker.toggle()
                        }
                        Button("Export", action: exportCoreData)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $addExpense) {
                AddNewExpense()
                    /// Customizing sheet
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $presentShareSheet) {
                deleteTempFile()
            } content: {
                CustomShareSheet(url: $shareURL)
            }
            /// File Importer (For selectingJSON From Files App)
            .fileImporter(isPresented: $presentFilePicker, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let success):
                    importJSON(success)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }

    func importJSON(_ url: URL) {
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.userInfo[.context] = context
            let items = try decoder.decode([Purchase].self, from: jsonData)
            /// Since It's Already loaded in Context, Simply Save the Context
            try context.save()
            print("File Imported Successfully")
        } catch {
            print(error.localizedDescription)
        }
    }

    func deleteTempFile() {
        do {
            try FileManager.default.removeItem(at: shareURL)
            print("Removed Temp JSON File")
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Exporting CoreData to JSON File
    func exportCoreData() {
        do {
            /// STEP: 1
            /// Fetch all CoreData Items for the Entity using Swift Way
            if let entityName = Purchase.entity().name {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let items = try context.fetch(request).compactMap { value in
                    value as? Purchase
                }

                /// Step 2
                /// Converting items to JSON String File
                let jsonData = try JSONEncoder().encode(items)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    /// Saving into emporary document and sharing it Via ShareSheet
                    if let tempURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let pathURL = tempURL.appending(component: "Export\(Date().formatted(date: .complete, time: .omitted)).json")
                        try jsonString.write(to: pathURL, atomically: true, encoding: .utf8)
                        /// Saved Successfully
                        shareURL = pathURL
                        presentShareSheet.toggle()
                    }
                }
            }
        } catch {}
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomShareSheet: UIViewControllerRepresentable {
    @Binding var url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
