//
//  AddNewExpense.swift
//  ExportingCoreData
//
//  Created by Juan Carlos Catagña Tipantuña on 5/8/23.
//

import SwiftUI

struct AddNewExpense: View {
    /// View properties
    @State private var title: String = ""
    @State private var dateOfPurchase: Date = .init()
    @State private var amountSpent: Double = 0
    /// Environment Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationStack {
            List {
                Section("Purchase item"){
                    TextField("", text: $title)
                    
                }
                Section("Date of Purchase"){
                    DatePicker("", selection: $dateOfPurchase, displayedComponents: [.date])
                        .labelsHidden()
                }
                
                Section("Amount Spent"){
                    TextField(value: $amountSpent, formatter: currencyFormatter){}
                        .labelsHidden()
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add", action: addExpense)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    /// Adding new Expense to CoreData
    func addExpense(){
        do {
            let purchase = Purchase(context: context)
            purchase.id = .init()
            purchase.dateOfPurchase = dateOfPurchase
            purchase.title = title
            purchase.amountSpent = amountSpent
            try context.save()
            /// Dismissing After successful addition
            dismiss()
        } catch {
            /// Do Action
            print(error.localizedDescription)
        }
    }
}

struct AddNewExpense_Previews: PreviewProvider {
    static var previews: some View {
        AddNewExpense()
    }
}

/// Currency Number formatter
let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.allowsFloats = false
    formatter.numberStyle = .currency
    return formatter
}()
