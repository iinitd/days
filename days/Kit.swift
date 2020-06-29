import SwiftUI
import UIKit


protocol ASTextFieldDelegate {
    func didBeginEditing(textField: UITextField)
    func didEndEditing(textField: UITextField)
    func didLeftItemtapped(_ button: UIButton)
}
extension ASTextFieldDelegate {
    func didBeginEditing(textField: UITextField) { }
    func didEndEditing(textField: UITextField) { }
    func didLeftItemtapped(_ button: UIButton) { }
}

struct ASTextField: UIViewRepresentable {

    var rightItem: UIImage?
    var leftItem: UIImage?
    var isSecuredEntry = false
    var handleLeftTap: (() -> ()) = { }
    private let textField = UITextField()
    var delegate: ASTextFieldDelegate?
    @Binding var text: String?
    var onCommit: () -> Void
    

    func makeUIView(context: UIViewRepresentableContext<ASTextField>) -> UITextField {

        textField.isSecureTextEntry = isSecuredEntry
        textField.text = text
        
        if let rightimg = rightItem {
            let button = UIButton()
            button.setImage(rightimg, for: .normal)
            button.addTarget(context.coordinator, action: #selector(context.coordinator.handleLeftTap(_:)), for: .touchUpInside)
            textField.rightView = button
            textField.rightViewMode = .always
        }

        if let leftImg = leftItem {
            let imgView = UIImageView()
            imgView.image = leftImg
            textField.leftView = imgView
            textField.leftViewMode = .always
        }

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<ASTextField>) {
        DispatchQueue.main.async {
              self.text = uiView.text
              print("update", self.text)
        }
        
    }

    func makeCoordinator() -> ASTextField.Coordinator {
        Coordinator(self, isPassword: self.isSecuredEntry,onCommit: {
            self.onCommit()
        })
    }

    final class Coordinator: NSObject, UITextFieldDelegate {

        var parent: ASTextField
        var onCommit: (() -> Void)?
        private var isPasswordField: Bool
        
        init(_ parent: ASTextF/Users/M/Playground.localized/iosapp/days/days/View.swiftield, isPassword: Bool, onCommit:(() -> Void)? ) {
            self.parent = parent
            self.isPasswordField = isPassword
            self.onCommit = onCommit
        }

        @objc func handleLeftTap(_ button: UIButton) {
            if isPasswordField {
                self.parent.textField.isSecureTextEntry = !self.parent.textField.isSecureTextEntry
            } else {
                self.parent.handleLeftTap()
            }
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            
            self.parent.text = textField.text
            self.parent.onCommit()
            print("self.parent.text",self.parent.text)
                }
        
        

        func textFieldDidEndEditing(_ textField: UITextField) {
            
            print("textFieldDidEndEditing")
            self.parent.onCommit()
        self.parent.delegate?.didEndEditing(textField: textField)
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
        self.parent.delegate?.didBeginEditing(textField: textField)
            
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.onCommit?()
            return true
        }
        
    }
}
