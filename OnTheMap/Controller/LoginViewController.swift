//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/20/21.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Sets text fields
    var emailFieldIsEmpty = true
    var passwordFieldIsEmpty = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLoginScreen()
        buttonEnabled(false, button: loginButton)
        passwordTextField.delegate = self
        emailTextField.delegate = self
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        resetLoginScreen()
    }
    
    //MARK: IBActions
    
    //Logs in the user using their credentials
    @IBAction func loginButtonAction(_ sender: Any) {
        setLoggingIn(true)
        OTMClient.login(email: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
    }
    
    //Takes the user to the Udacity sign up page to let them sign up for an account
    @IBAction func signupButtonAction(_ sender: Any) {
        setLoggingIn(true)
        UIApplication.shared.open(OTMClient.Endpoints.signup.url, options: [:], completionHandler: nil)
    }
    
    //MARK: Functions
    
    //Checks to see if the login was a success. If success, segues to next VC. If fail, shows an alert
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
    
    //Resets all fields and hides actiivityIndicator
    func resetLoginScreen() {
        emailTextField.text = ""
        passwordTextField.text = ""
        activityIndicator.isHidden = true
    }
    
    //Sets the status of the button
    func buttonEnabled(_ enabled: Bool, button: UIButton) {
        button.isEnabled = enabled
        button.alpha = enabled ? 1.0 : 0.5
    }
    
    //Sets the state of logging in
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
    
    //MARK: textField Functions
    
    //Sets text field bool value and enables/disables the button as needed
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            let currentText = emailTextField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                emailFieldIsEmpty = true
            } else {
                emailFieldIsEmpty = false
            }
        }
        
        if textField == passwordTextField {
            let currentText = passwordTextField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
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
    
    //Clears the text field
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
    
    //Login button is pressed when return is used
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
