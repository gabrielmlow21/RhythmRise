//
//  InitialViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/1/24.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onClickCreateAccount(_ sender: Any) {
        self.performSegue(withIdentifier: "showRegisterPageSegue", sender: self)
    }
    
    
    @IBAction func onClickLogin(_ sender: Any) {
        self.performSegue(withIdentifier: "showLoginPageSegue", sender: self)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
