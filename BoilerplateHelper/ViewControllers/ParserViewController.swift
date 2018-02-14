//
//  ParserViewController.swift
//  BoilerplateHelper
//
//  Created by Stepanov Pavel on 03/02/2018.
//  Copyright © 2018 Stepanov Pavel. All rights reserved.
//

import Cocoa

class ParserViewController: NSViewController {
    // MARK: - Injected
    var presenter = ParserPresenter()
    
    // MARK: - UI
    @IBOutlet var inputTextView: NSTextView!
    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet weak var countStubLabel: NSTextField!
    @IBOutlet weak var countStubTextField: NSTextField!
    @IBOutlet weak var removingCaseCheckButton: NSButton!
    @IBOutlet weak var cleanCaseValuesButton: NSButton!
    @IBOutlet weak var shouldCamelCaseButton: NSButton!
    @IBOutlet weak var removeCommentsButton: NSButton!
    
    // MARK: - Actions
    @IBAction func radioButtonTapped(_ sender: NSButton) {
        do {
            try presenter.attemptToChangeMode(withId: sender.tag)
            toggleUIElements()
        } catch {
            print(error.localizedDescription)
            sender.state = .off
        }
    }
    
    @IBAction func parametersButtonTapped(_ sender: NSButton) {
        presenter.changeParserCleanParameters(shouldRemoveCases: removingCaseCheckButton.state == .on,
                                              shouldCleanCaseValues: cleanCaseValuesButton.state == .on,
                                              shouldCleanComments: removeCommentsButton.state == .on)
    }
    
    @IBAction func generateButtonTapped(_ sender: NSButton) {
        outputTextView.string = presenter.getOutputString(inputTextView.string)
    }
    
    fileprivate func toggleUIElements() {
        switch presenter.mode {
        case .stubJSONData:
            countStubLabel.isHidden = false
            countStubTextField.isHidden = false
            removingCaseCheckButton.isHidden = true
            cleanCaseValuesButton.isHidden = true
        case .cases:
            removingCaseCheckButton.isHidden = false
            cleanCaseValuesButton.isHidden = false
        default: // remove
            countStubLabel.isHidden = true
            countStubTextField.isHidden = true
            removingCaseCheckButton.isHidden = true
            cleanCaseValuesButton.isHidden = true
        }
    }
}

// MARK: - NSTextFieldDelegate
extension ParserViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        if let newCount = Int(countStubTextField.stringValue) {
            presenter.changeJSONRepetitionCount(newCount)
        }
    }
}

extension String {
    func indexDistance(of character: Character) -> Int? {
        guard let index = index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
}


func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

func random(min: Int, max: Int) -> Int {
    let randomNum = random()
    return Int((randomNum * CGFloat(max - min)) + CGFloat(min))
}

