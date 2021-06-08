//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/20/21.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var emailFieldIsEmpty = true
    var passwordFieldIsEmpty = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLoginScreen()
        buttonEnabled(false, button: loginButton)
        passwordTextField.delegate = self
        emailTextField.delegate = self
        activityIndicator.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        resetLoginScreen()
    }
    
    
    @IBAction func loginButtonAction(_ sender: Any) {
        setLoggingIn(true)
        OTMClient.login(email: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
    }
    
    @IBAction func signupButtonAction(_ sender: Any) {
        setLoggingIn(true)
        UIApplication.shared.open(OTMClient.Endpoints.signup.url, options: [:], completionHandler: nil)
    }
    
    func handleLoginResponse (success: Bool, error: Error?) {
        setLoggingIn(false)
        if success {
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
            resetLoginScreen()
        } else {
            DispatchQueue.main.async {
                self.showAlert(message: error?.localizedDescription ?? "Please enter a valid email or password", title: "Login Error")
            }
            passwordTextField.text = ""
        }
    }
    
    func resetLoginScreen() {
        emailTextField.text = ""
        passwordTextField.text = ""
        activityIndicator.isHidden = true
    }
    
    func buttonEnabled(_ enabled: Bool, button: UIButton) {
        button.isEnabled = enabled
        button.alpha = enabled ? 1.0 : 0.5
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                self.buttonEnabled(false, button: self.loginButton)
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.buttonEnabled(true, button: self.loginButton)
            }
        }
        DispatchQueue.main.async {
            self.emailTextField.isEnabled = !loggingIn
            self.passwordTextField.isEnabled = !loggingIn
            self.loginButton.isEnabled = !loggingIn
            self.signupButton.isEnabled = !loggingIn
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            let currenText = emailTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                emailFieldIsEmpty = true
            } else {
                emailFieldIsEmpty = false
            }
        }
        
        if textField == passwordTextField {
            let currenText = passwordTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                passwordFieldIsEmpty = true
            } else {
                passwordFieldIsEmpty = false
            }
        }
        
        if emailFieldIsEmpty == false && passwordFieldIsEmpty == false {
            buttonEnabled(true, button: loginButton)
        } else {
            buttonEnabled(false, button: loginButton)
        }
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        buttonEnabled(false, button: loginButton)
        if textField == emailTextField {
            emailFieldIsEmpty = true
        }
        if textField == passwordTextField {
            passwordFieldIsEmpty = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginButtonAction(loginButton!)
        }
        return true
    }
}
