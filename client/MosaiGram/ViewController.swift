import UIKit

class ViewController: UIViewController {

    let host = ProcessInfo.processInfo.environment["HOST"]
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func login() {
        let session = URLSession.shared
        let credentials = [
            "username": usernameField.text,
            "password": passwordField.text
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: credentials, options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        let path = "\(host!)/user/login"
        let url = URL(string: path)
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = data
        let task = session.dataTask(with: request) { [weak self]
            data, response, error -> Void in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    DispatchQueue.main.sync {
                        self?.performSegue(withIdentifier: "SignupSegue", sender: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        login()
    }
}

