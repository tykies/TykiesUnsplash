// ProfileViewController.swift
//
// Copyright (c) 2016 Camden Fullmer (http://camdenfullmer.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    @IBOutlet var linkButton: UIBarButtonItem!
    var client : UnsplashClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInstanceProperties()
        updateInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private - Setup
    
    private func setUpInstanceProperties() {
        self.client = Unsplash.client!
    }
    
    private func updateInterface() {
        if self.client.authorized {
            self.linkButton.title = "Unlink"
            self.label.isHidden = false
            self.imageView.isHidden = false
            self.client.currentUser.profile().response({ response, error in
                if let user = response {
                    self.label.text = "\(user.firstName) \(user.lastName!)"

                    self.imageView.af_setImage(withURL: (user.profileImage.small))
                } else {
                    print("ERROR: " + error!.description)
                }
            })
        } else {
            self.linkButton.title = "Link"
            self.label.isHidden = true
            self.imageView.isHidden = true
        }
    }
    
    // MARK: User Interaction
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func linkButtonTapped(sender: AnyObject) {
        if self.client.authorized {
            
            Keychain.clear()
//            Unsplash.unlinkClient()
        } else {
            Unsplash.authorizeFromController(controller: self) { success, error in
                if let e = error {
                    print("ERROR: " + e.description)
                } else {
                    self.updateInterface()
                }
            }
        }
    }
}
