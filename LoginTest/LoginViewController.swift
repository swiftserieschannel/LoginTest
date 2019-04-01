
import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AccessToken.current != nil{
          
            let mvc = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as? MainNavigationController
            self.present(mvc!, animated: true, completion: nil)
            
        }
    }

    @IBAction func logintBtnClicked(_ sender: Any) {
        
        if AccessToken.current != nil{
            let mvc = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as? MainNavigationController
            self.present(mvc!, animated: true, completion: nil)

        }else{
            let manager = LoginManager()
            manager.logIn(readPermissions: [ReadPermission.publicProfile,ReadPermission.email,ReadPermission.userGender,ReadPermission.userBirthday], viewController: self) { loginResult in
                
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success( _, _, _):
                    print("Logged in!")
                    let mvc = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as? MainNavigationController
                    self.present(mvc!, animated: true, completion: nil)
                }
            }
        }
        
    }
    
}

