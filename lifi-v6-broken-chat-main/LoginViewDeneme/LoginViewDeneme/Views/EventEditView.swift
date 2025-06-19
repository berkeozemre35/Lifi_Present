//
//  EventEditView.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 6.04.2025.
//

import SwiftUI

struct EventEditView: View {
    @Binding var event: EventItem
    @Environment(\.presentationMode) var presentationMode
    let onSave: (EventItem) -> Void

    var body: some View {
        Form {
            TextField("Event Name", text: $event.name)
            TextField("Location", text: Binding(
                get: { event.location ?? "" },
                set: { event.location = $0 }
            ))
            DatePicker("Start Date", selection: Binding(
                get: { event.startDate ?? Date() },
                set: { event.startDate = $0 }
            ))
            DatePicker("End Date", selection: Binding(
                get: { event.endDate ?? Date() },
                set: { event.endDate = $0 }
            ))

            Button("Save") {
                onSave(event)
                presentationMode.wrappedValue.dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .navigationTitle("Edit Event")
    }
}


