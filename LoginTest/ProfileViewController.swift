
import UIKit
import FacebookLogin
import FacebookCore
import FacebookShare
import  SDWebImage
import DropDown
import MobileCoreServices
import Photos


class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK:- OUTLETS
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var DOBLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK :- INSTACE VARIABLES
    var picker = UIImagePickerController();
    
    //MARK:- LIFE CYCLE CALLS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self,
                                                                 action: #selector(openOverFlowMenu))
        //         Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserData()
    }
    
    
    
    // MARK:- ACTIONS
    @IBAction func logoutBtnClicked(_ sender: Any) {
        if let token = AccessToken.current {
            AccessToken.current = nil
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            self.present(loginVC!, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - helper methods
    @objc public func openOverFlowMenu(){
        let dropDown = DropDown()
        dropDown.anchorView = self.navigationItem.rightBarButtonItem
        dropDown.dataSource = ["Link", "Photo", "Video"]
        dropDown.width = 200
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            switch index {
            case 0:
                self.shareLink(link: URL(string: "https://github.com/AssistoLab/DropDown")!)
            case 1:
                self.sharePhotos()
            case 2:
                self.shareVideos()
            default:
                break;
            }
        }
        
        dropDown.show()
    }
    
    func shareLink(link:URL){
        let myContent = LinkShareContent(url: URL(string: "https://developers.facebook.com/docs/sharing/ios")!)
        let shareDialog = ShareDialog(content: myContent)
        shareDialog.mode = .automatic
        shareDialog.failsOnInvalidData = true
        shareDialog.completion = { result in
            
        }
        do{
            try shareDialog.show()
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    func sharePhotos(){
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [String(kUTTypeImage)]
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func shareVideos(){
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [String(kUTTypeMovie)]
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Use editedImage Here
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Use originalImage Here
            dismiss(animated: true){
                // if app is available
                if UIApplication.shared.canOpenURL(URL(string: "fb://")!){
                    let photo = Photo(image: originalImage, userGenerated: true)
                    let content = PhotoShareContent(photos: [photo])
                    do{
                        try ShareDialog.show(from: self, content: content){ result in
                            print(result)
                        }
                    }catch let error {
                        print(error.localizedDescription)
                    }
                }else {
                    print("app not installed")
                    //                    UIApplication.shared.open(URL(string: "itms://itunes.apple.com/in/app/facebook/id284882215")!, options: [ : ], completionHandler: nil)
                }
            }
        }
            
        else if let videoURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
            picker.dismiss(animated: true){
                // if app is available
                if UIApplication.shared.canOpenURL(URL(string: "fb://")!){
                    let video = Video(url: videoURL)
                    let myContent = VideoShareContent(video: video)
                    do{
                        try ShareDialog.show(from: self, content: myContent){ result in
                            print(result)
                        }
                    }catch let error {
                        print(error.localizedDescription)
                    }
                }else {
                    print("app not installed")
                    //                  UIApplication.shared.open(URL(string: "itms://itunes.apple.com/in/app/facebook/id284882215")!, options: [ : ], completionHandler: nil)
                }
            }
        }
        
    }
    
    func getUserData(){
        if AccessToken.current != nil {
            let connection = GraphRequestConnection()
            connection.add(MyProfileRequest()){ response, result in
                switch result {
                case .success(let response):
                    self.nameLabel.text = response.dict["name"]! as? String
                    self.genderLabel.text = response.dict["gender"]! as? String
                    self.emailLabel.text = response.dict["email"]! as? String
                    self.DOBLabel.text = response.dict["birthday"]! as? String
                    self.imageView.sd_setImage(with: URL(string: response.imageUrl ?? ""), completed: nil)
                case .failed(let error):
                    print("Custom Graph Request Failed: \(error)")
                }
            }
            connection.start()
        }
    }
    
}

struct MyProfileRequest:GraphRequestProtocol {
    var graphPath = "/me"
    var parameters: [String : Any]? = ["fields": "id, name, first_name, last_name, picture.type(large), email, gender, birthday"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
    
    struct  Response:GraphResponseProtocol {
        
        var dict:[String:Any]
        var imageUrl:String?
        
        init(rawResponse: Any?) {
            dict = rawResponse as! [String : Any]
            if let imageDict = dict["picture"] as? [String:Any]{
                if let dataDic = imageDict["data"] as? [String:Any]{
                    if let imageURL = dataDic["url"]{
                        self.imageUrl = imageURL as! String
                    }
                }
            }
        }
        
    }
}
