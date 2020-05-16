//
//  TimeTrackerViewController.swift
//  TimeTracker
//
//  Created by Андронов Сергей on 15/05/2020.
//  Copyright © 2020 Sergey Andronov. All rights reserved.
//

import Cocoa

class TimeTrackerViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension TimeTrackerViewController {
  static func freshController() -> TimeTrackerViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier("TimeTrackerViewController")
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? TimeTrackerViewController else {
      fatalError("Why cant i find TimeTrackerViewController? - Check Main.storyboard")
    }
    return viewcontroller
  }
}
