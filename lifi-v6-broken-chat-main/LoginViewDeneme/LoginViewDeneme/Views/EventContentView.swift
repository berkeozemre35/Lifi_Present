import SwiftUI

struct EventContentView: View {
    @StateObject private var viewModel = EventContentViewModel()
    @State private var selectedEvent: EventItem?
    let userId: String

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.events.isEmpty {
                    Text(viewModel.errorMessage.isEmpty ? "No events to display." : viewModel.errorMessage)
                        .foregroundColor(viewModel.errorMessage.isEmpty ? .gray : .red)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.events) { event in
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.headline)
                                    .onTapGesture {
                                        selectedEvent = event
                                    }
                                if let location = event.location {
                                    Text("Location: \(location)")
                                        .font(.subheadline)
                                }
                                if let startDate = event.startDate {
                                    Text("Start: \(startDate.formatted())")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                if let endDate = event.endDate {
                                    Text("End: \(endDate.formatted())")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: viewModel.deleteEvent)
                    }
                }
            }
            .sheet(item: $selectedEvent) { event in
                EventEditView(event: Binding(
                    get: { event },
                    set: { updatedEvent in
                        if let index = viewModel.events.firstIndex(where: { $0.id == updatedEvent.id }) {
                            viewModel.events[index] = updatedEvent
                        }
                        viewModel.updateEvent(updatedEvent)
                    }
                )) { updatedEvent in
                    viewModel.updateEvent(updatedEvent)
                }
            }
            .navigationTitle("My Events")
            .onAppear {
                viewModel.fetchEvents(for: userId)
            }
        }
    }
}



/*
 #Preview {
     EventContentView(userId: "rOp1b0dz54SPovld6PRfHJBmrRC2")
 }
 */
 
 


 



