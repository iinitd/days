//
//  ContentView.swift
//  days
//
//  Created by M on 2020/6/11.
//  Copyright © 2020 com. All rights reserved.
//

import SwiftUI
import CoreData

extension Binding {
    init(_ source: Binding<Value?>, _ defaultValue: Value) {
        // Ensure a non-nil value in `source`.
        if source.wrappedValue == nil {
            source.wrappedValue = defaultValue
        }
        // Unsafe unwrap because *we* know it's non-nil now.
        self.init(source)!
    }
}

func isSameDay(date1: Date, date2: Date) -> Bool {
    return Calendar.current.isDate(date1, inSameDayAs: date2)
}

func ParseDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)

}

func AddTodoItem(context: NSManagedObjectContext){
    let item = TodoItem(context: context)
    item.name = "测试"
    item.id = UUID()
    item.desc = ""
    item.createdAt = Date()
    try? context.save()
}



struct ContentView: View {

    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        entity: TodoItem.entity(),
        sortDescriptors: [{ NSSortDescriptor(key: #keyPath(TodoItem.createdAt), ascending: true) }()]
    ) var items: FetchedResults<TodoItem>

    var body: some View {
        VStack(alignment: .leading) {
            Button("add") {
                AddTodoItem(context: self.moc)
            }
            ScrollView {
                ForEach(0..<items.count,id:\.self) {
                    idx in
                    VStack(){
                        if (idx == 0 || !isSameDay(date1: self.items[idx].createdAt!, date2: self.items[idx - 1].createdAt!)) {
                            Divider()
                                               HStack{
                                                Text(ParseDate(self.items[idx].createdAt!))
                                                    .font(.headline)
                                                    .fontWeight(.thin)
                                                   
                                                   Spacer()
                                               }
                                           }
                                           TodoCard(item: self.items[idx])
                    }
                   
                }
            }
        }.padding()

    }
}

struct TodoCard: View {

    @ObservedObject var item: TodoItem
    @Environment(\.managedObjectContext) var moc
    @State var isEditable: Bool = false

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()


    var body: some View {

        VStack {
            VStack {
                HStack{
                    Text(item.name ?? "hi")
                        .fontWeight(.thin)
                    Spacer()
                }
            }

        }
            


            .onTapGesture {
//                 self.moc.delete(self.item)
                // self.item.name! += "!"
                // try? self.moc.save()
                self.isEditable = true
            }
            .popover(isPresented: $isEditable) { TodoEditor(item: self.item, isEditable: self.$isEditable)
                    .environment(\.managedObjectContext, self.moc) }

    }



}


struct TodoEditor: View {

    @ObservedObject var item: TodoItem
    @Environment(\.managedObjectContext) var moc
    @Binding var isEditable: Bool
    @State var currentDate : Date = Date()


    var body: some View {

        VStack {
            TextField("Name", text: Binding($item.name, "New Item"))
            TextField("Desc", text: Binding($item.desc, "New Desc"))
            DatePicker("Time", selection: $currentDate, displayedComponents: .date)
            Button("Reset", action: {
                self.moc.rollback()
            })
            Button("Done", action: {
                self.item.createdAt = self.currentDate
                try? self.moc.save()
                self.isEditable.toggle()
            })
        }.onAppear(){
            self.currentDate = self.item.createdAt!
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    }
}
