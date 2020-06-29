//
//  ContentView.swift
//  days
//
//  Created by M on 2020/6/11.
//  Copyright © 2020 com. All rights reserved.
//

import SwiftUI
import CoreData
import Introspect

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

func AddTodoItem(context: NSManagedObjectContext) {
    let item = TodoItem(context: context)
    item.target = "测试"
    item.id = UUID()
    item.desc = ""
    item.createdAt = Date()
    item.targetAt = Date()
    try? context.save()
}

struct ContentView: View {

    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        entity: TodoItem.entity(),
        sortDescriptors: [{ NSSortDescriptor(key: #keyPath(TodoItem.targetAt), ascending: false) }()]
    ) var items: FetchedResults<TodoItem>

    func update(_ result: FetchedResults<TodoItem>) -> [[TodoItem]] {
        let dict = Dictionary(grouping: result) { (element: TodoItem) in
            ParseDate(element.targetAt!)
        }
        let sdict = dict.sorted(by: { $0.0 > $1.0 })
        return sdict.map { $0.1 }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Button("add") {
                AddTodoItem(context: self.moc)
            }

            List {
                ForEach(update(items), id: \.self) { (section: [TodoItem]) in
                    Section(header: Text(ParseDate(section[0].targetAt!))) {
                        ForEach(section, id: \.self) { todo in
                            HStack {
                                TodoCard(item: todo)
                            }
                        }
                    }
                }.id(items.count)
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
                HStack {
                    Text(item.target ?? "hi")
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
    @State var _targetAt: Date = Date()
    @State var _target: String? = ""
    @State var titleFocused: Bool = false


    var body: some View {

        NavigationView {
            VStack {
//                ASTextField(text:$_target,onCommit: {
//                   self.item.targetAt = self._targetAt
//                   self.item.target = self._target
//                   print("self.item.target",self.item.target)
//                   try? self.moc.save()
//                    print(self._target)
//                }).frame(height:100)
                TextFieldWithFocus(text: Binding($_target,"target"),
                   placeholder: NSLocalizedString("summary", comment: ""), isFirstResponder: $titleFocused, onCommit: {
                   UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                   self.titleFocused = false
                })
                
                Text(_target!)
                Spacer()
                DatePicker("Time", selection: $_targetAt, displayedComponents: .date).labelsHidden()
                Spacer()
                HStack {
                    Button("Delete", action: {
                        self.isEditable.toggle()
                        self.moc.delete(self.item)
                    })
                }
                Spacer()
                }.padding().navigationBarTitle("Navigation", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Reset", action: {
                        self.moc.rollback()
                        self.isEditable.toggle()
                    }),
                    trailing:
                    Button("Done",action: {
                            print("done!!")
                        self.item.targetAt = self._targetAt
                        self.item.target = self._target
                        print("self.item.target",self.item.target)
                        try? self.moc.save()
                            self.isEditable.toggle()

                            
                    })
                )
            }

            .onAppear() {
                self._targetAt = self.item.targetAt!
                self._target = self.item.target!
                
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    }
}
