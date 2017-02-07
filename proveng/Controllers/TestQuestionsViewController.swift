//
//  TestQuestionsViewController.swift
//  proveng
//
//  Created by Dmitry Kulakov on 14.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import Eureka

protocol TestQuestionsViewControllerDelegate: class {
    func viewControllerDidPresented(_ index:Int)
    func layoutIsLoaded(offset: CGFloat)
}

class TestQuestionsViewController: BaseFormViewController {

    @IBOutlet weak var topAnswerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomAnwerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerView: UIView!
    var index: Int!
    weak var delegate: TestQuestionsViewControllerDelegate?
    var testCard: TestCard!
    var isFirstLounch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.questionLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
        if let question = self.testCard.question {
            self.questionLabel.text = "\(self.index+1). \(question)"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.viewControllerDidPresented(self.index)
    }
    
    deinit {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstLounch {
            switch UIScreen.main.bounds.height {
            case 480...500:
                self.bottomAnwerViewConstraint.constant = 60
            case 660...800:
                self.bottomAnwerViewConstraint.constant = 180
            default:
                self.bottomAnwerViewConstraint.constant = UIScreen.main.bounds.height / 4.7
            }
            self.answerView.layoutIfNeeded()
            self.configureAnswersForm()
            let nextButtonHeight: CGFloat = 45
            let offset = self.tableView!.frame.origin.y + self.tableView!.frame.height + nextButtonHeight + 5
            self.delegate?.layoutIsLoaded(offset: offset)
            isFirstLounch = false
        }
    }
    
    // MARK: - Configure Table Form
    
    func configureAnswersForm() {
        configureTableView()
        _ = self.addSection(tag: "Answers")
        for answer in self.testCard.testAnswers {
            var answered = false
            if self.testCard.answer?.objectID == answer.objectID {
                answered = true
            }
            if let index = self.testCard.testAnswers.index(of: answer) {
                _ = self.addAnswerRow(answer, testIndex: index, answered: answered).onCellSelection({ [weak self] (cell, row) in
                    self?.unchekRows()
                    row.value = true
                    row.cell.nameLabel.textColor = ColorForElements.additional.color
                    row.updateCell()
                    BaseModel.realmWrite {
                        self?.testCard.answer = answer
                    }
                })
            }
        }
    }
    
    func unchekRows() {
        for row in self.form.rows as! [PhotoLabelRow] {
            row.value = false
            row.cell.nameLabel.textColor = ColorForElements.text.color
            row.updateCell()
        }
    }
    
    func configureTableView() {
        self.tableView?.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0)
        self.tableView?.frame = self.answerView.frame
        self.tableView?.backgroundColor = UIColor.white
        self.tableView?.bounces = false
    }
}
