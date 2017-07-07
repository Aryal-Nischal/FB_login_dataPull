//
//  ViewController.swift
//  LoginModel
//
//  Created by Mac on 7/6/17.
//  Copyright © 2017 Aryal. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FacebookLogin
import SDWebImage
class ViewController: UIViewController,LoginButtonDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var Gender: UILabel!
    @IBOutlet weak var Birthday: UILabel!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var birthdayField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FBSDKAccessToken.current() != nil {
            self.fetchUserData(tokenString: FBSDKAccessToken.current().tokenString)
        }
        self.customizeViews()
    }
    
    
    
    func customizeViews(){
        self.imageView.layer.cornerRadius = self.imageView.frame.size.height / 2.0
        self.imageView.clipsToBounds = true
        self.usernameField.layer.borderColor = UIColor.clear.cgColor
        self.emailField.layer.borderColor = UIColor.clear.cgColor
        self.genderField.layer.borderColor = UIColor.clear.cgColor
        self.birthdayField.layer.borderColor = UIColor.clear.cgColor
        self.displayFBLoginButton()
    }
    

    func fetchUserData(tokenString:String){
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender, location, birthday"], tokenString: tokenString, version: nil, httpMethod: "GET")
        
        _ = request?.start(completionHandler: { (connection, result, error) in
            if error == nil {
                if let resultJson = result as? [String:Any]{
                    self.handleGraphRequest(forData: resultJson)
                }
            }
            else{print(error ?? "default error string")}
        })
    }
    
    func handleGraphRequest(forData data:[String:Any]){
        self.usernameField.text = data["name"] as? String ?? "Username"
        self.emailField.text = data["email"] as? String ?? "Email"
        self.genderField.text = data["gender"] as? String ?? "Gender"
        self.birthdayField.text = data["birthday"] as? String ?? "Birthday"
        if let pictureData = data["picture"] as? [String:Any], let insideData = pictureData["data"] as? [String:Any], let pictureUrl = insideData["url"] as? String {
            self.imageView.sd_setImage(with: URL(string: pictureUrl))
        }
    }
    
    func displayFBLoginButton(){
        let loginButton = LoginButton(readPermissions: [.publicProfile,.email,.userFriends,.custom("user_location")])
        loginButton.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height - 50.0)
        self.view.addSubview(loginButton)
        loginButton.delegate = self
    }

    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result{
        case .success(grantedPermissions: let granted, declinedPermissions: let declined, token: let token):
            print(granted)
            print(declined)
            print(token.authenticationToken)
            self.fetchUserData(tokenString: token.authenticationToken)
        case .cancelled:
            print("cancelled by user")
            
        case .failed(let error):
            print(error)
        }
    }
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        self.usernameField.text = ""
        self.emailField.text = ""
        self.genderField.text = ""
        self.birthdayField.text = ""
        self.imageView.image = #imageLiteral(resourceName: "imageHolder")
    }
    

}

