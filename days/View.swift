//
//  utils.swift
//  days
//
//  Created by M on 2020/6/15.
//  Copyright © 2020 com. All rights reserved.
//

import SwiftUI
import Combine
//
//struct MyTextField: View {
//    @Binding var outer: String
//    @State var inner: String = ""
//    var body: some View {
//        let binding = Binding<String>(get: {
//            self.inner
//        }, set: {
//            self.inner = $0
//            self.outer = self.inner
//            // do whatever you want here
//        })
//       return ( TextField("name",text:binding).onAppear(){
//            self.inner = self.outer
//        })
//    }
//}
import Combine
import SwiftUI
  
struct TextFieldWithFocus: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool
        var didBecomeFirstResponder = false
  
        var onCommit: () -> Void
  
        init(text: Binding<String>, isFirstResponder: Binding<Bool>, onCommit: @escaping () -> Void) {
            _text = text
            _isFirstResponder = isFirstResponder
            self.onCommit = onCommit
        }
  
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
  
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            isFirstResponder = false
            didBecomeFirstResponder = false
            onCommit()
            return true
        }
          
        func textFieldDidEndEditing(_ textField: UITextField) {
            isFirstResponder = false
            didBecomeFirstResponder = false
        }
          
        func textFieldDidBeginEditing(_ textField: UITextField) {
            isFirstResponder = true
        }
    }
  
    @Binding var text: String
    var placeholder: String
    @Binding var isFirstResponder: Bool
    var textAlignment: NSTextAlignment = .left
//    var isSecure: Bool = false
//    var returnKeyType: UIReturnKeyType = .default
//    var textContentType: UITextContentType?
//    var textFieldBorderStyle: UITextField.BorderStyle = .none
//    var enablesReturnKeyAutomatically: Bool = false
  
    var onCommit: (() -> Void)?
  
    func makeUIView(context: UIViewRepresentableContext<TextFieldWithFocus>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = NSLocalizedString(placeholder, comment: "")
        textField.textAlignment = textAlignment
//        textField.isSecureTextEntry = isSecure
//        textField.returnKeyType = returnKeyType
//        textField.textContentType = textContentType
//        textField.borderStyle = textFieldBorderStyle
//        textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
  
        return textField
    }
  
    func makeCoordinator() -> TextFieldWithFocus.Coordinator {
        return Coordinator(text: $text, isFirstResponder: $isFirstResponder, onCommit: {
            self.onCommit?()
        })
    }
  
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextFieldWithFocus>) {
        DispatchQueue.main.async {
            uiView.text = self.text
            if self.isFirstResponder && !context.coordinator.didBecomeFirstResponder {
                uiView.becomeFirstResponder()
                context.coordinator.didBecomeFirstResponder = true
            }
        }
        
    }
}
  
struct TextFieldWithFocus_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldWithFocus(text: .constant(""), placeholder: "placeholder", isFirstResponder: .constant(false))
    }
}  
