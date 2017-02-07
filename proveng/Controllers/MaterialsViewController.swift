//
//  MaterialsViewController.swift
//  proveng
//
//  Created by Виктория Мацкевич on 26.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import PromiseKit
import RealmSwift

class MaterialsViewController: BaseViewController {
    
    var materialID: Int = 0
    var material: Material!
    
    @IBOutlet weak var titleDescriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLinkLabel: UILabel!
    @IBOutlet weak var linkTextView: BaseTextView!
    @IBOutlet weak var textViewConstraint: NSLayoutConstraint!
    var editButton: UIBarButtonItem?
    
    fileprivate var notificationToken: NotificationToken? = nil
    var materialActiveMethod: ApiMethod?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        linkTextView.delegate = self
        configureRealmNotification()
        request()
        titleLinkLabel.font = Constants.regularFont
        titleDescriptionLabel.font = Constants.regularFont
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
    }    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTranslucentNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setDefaultNavigationBar()
    }
    
    deinit {
        ApiLayer.SharedApiLayer.cancel(self.materialActiveMethod)
    }
    
    func request() {
        let materialMethod = ApiMethod.getMaterial(materialID: self.materialID)
        self.materialActiveMethod = materialMethod
        firstly {
            ServiceForRequest<Material>().getObjectPromise(materialMethod)
        }.then { [weak self] materialObject -> Void in
            self?.material = materialObject
            if self?.notificationToken == nil {
                self?.configureRealmNotification()
            }
            self?.editButton?.isEnabled = true
        }.catch { [weak self] error in
            self?.handleError(error: error)
        }
    }
    
    func configureRealmNotification() {
        firstly { [weak self] in
            ServiceForData<Material>().getDataResultsByIDFromStoragePromise(self!.materialID)
        }.then { material -> Void in
                self.notificationToken = material.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                    switch changes {
                    case .initial:
                        self?.material = material.first
                        self?.configureMaterialPage()
                        break
                    case .update(_, let deletions, _, _):
                        if deletions.count > 0 {
                            ServiceForData<Material>().getObjectByID(id: self!.materialID, handler: { material in
                                self?.material = material
                                self?.configureMaterialPage()
                            })
                        } else {
                            self?.configureMaterialPage()
                        }
                    case .error(let error):
                        fatalError("\(error)")
                        break
                    }
                }
            }.catch { error in
        }
    }
    
    func configureMaterialPage(){        
        if self.material != nil {
            titleDescriptionLabel.text = "Description:"
            titleLinkLabel.text = "Link:"
            self.title = self.material.name
            descriptionLabel.text = material.materialDescript
            linkTextView.text = material.link
            linkTextView.font = UIFont.systemFont(ofSize: 14)
            let textViewFrame = linkTextView.sizeThatFits(self.linkTextView.bounds.size)
            textViewConstraint.constant = textViewFrame.height
        }
    }
}

extension MaterialsViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if let link = material.link, let url = NSURL(string: link) {
            UIApplication.shared.openURL(url as URL)
        }
        return false
    }
    
    func configureNavigationBar(){
        if SessionData.teacher {
            editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
            self.navigationItem.rightBarButtonItem = editButton
            editButton?.isEnabled = false
        }
    }
    
    func editButtonPressed(){
        let operation = RouterOperationXib.openEditMaterial(material: self.material)
        self.router.performOperation(operation)
    }    
}
