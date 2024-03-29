//
//  GameViewController.swift
//  Xdungeon
//
//  Created by michiharu on 2018/04/04.
//  Copyright © 2018年 michiharu. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    enum FinishState {
        case finish
        case clearStage
        case gameOver
    }
    
    var pauseStart: Date?
    
    func retry() { fatalError("このメソッドはオーバーライドされなければなりません。") }
    
    func pause() { fatalError("このメソッドはオーバーライドされなければなりません。") }
    
    func finish(state: FinishState, score: Int = 0) { fatalError("このメソッドはオーバーライドされなければなりません。") }
}

class ChallengeGameViewController: GameViewController {
    
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var finishView: UIView!
    
    //    // Pause, Finish 共通処理ここから
    @IBAction func backToHome(_ sender: UIButton) {
        let home = storyboard!.instantiateViewController(withIdentifier: "Home")
        home.modalTransitionStyle = .crossDissolve
        self.present(home, animated: true, completion: nil)
    }
    
    @IBAction func retry(_ sender: UIButton) {
        if let s = skView.scene { s.removeFromParent() }
        let newScene = ChallengeGameScene(storyboard: storyboard!, gvc: self, size: skView.frame.size)
        newScene.scaleMode = .aspectFill
        skView.presentScene(newScene)
        self.view.bringSubview(toFront: skView)
    }
    // Pause, Finish 共通処理ここまで
    
    // Pause View ここから
    @IBAction func continueGame(_ sender: UIButton) {
        guard let s = skView.scene as? ChallengeGameScene else { return }
        s.isPaused = false
        let pauseDuration = Date().timeIntervalSince(pauseStart!)
        top.startGame         = top.startGame + pauseDuration
        top.startThisQuestion = top.startThisQuestion + pauseDuration
        pauseStart = nil
        self.view.sendSubview(toBack: pauseView)
    }
    // Pause View ここまで
    
    @IBOutlet weak var pauseHighScoreLabel: UILabel!
    @IBOutlet weak var pauseScoreLabel: UILabel!
    @IBOutlet weak var finishHighScoreLabel: UILabel!
    @IBOutlet weak var finishScoreLabel: UILabel!
    
    @IBOutlet weak var pauseHomeButton: UIButton!
    @IBOutlet weak var pauseRetryButton: UIButton!
    @IBOutlet weak var pauseContinueButton: UIButton!
    @IBOutlet weak var finishHomeButton: UIButton!
    @IBOutlet weak var finishRetryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        finishView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        pauseHomeButton.setTitle(NSLocalizedString("Home", comment: ""), for: .normal)
        pauseRetryButton.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
        pauseContinueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        finishHomeButton.setTitle(NSLocalizedString("Home", comment: ""), for: .normal)
        finishRetryButton.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(type(of: self).willDisappear),
                       name: .UIApplicationDidEnterBackground,
                       object: nil)
        
        nc.addObserver(self,
                       selector: #selector(type(of: self).willAppear),
                       name: .UIApplicationDidBecomeActive,
                       object: nil)
        
        if let s = skView.scene { s.removeFromParent() }
        let newScene = ChallengeGameScene(storyboard: storyboard!, gvc: self, size: skView.frame.size)
        newScene.scaleMode = .aspectFill
        skView.presentScene(newScene)
    }
    
    @objc func willDisappear() {
        guard let s = skView.scene else { return }
        s.isPaused = true
        pauseStart = Date()
        print("viewWillDisappear")
    }
    
    @objc func willAppear() {
        guard let s = skView.scene else { return }
        s.isPaused = false
        if let ps = pauseStart {
            let pauseDuration = Date().timeIntervalSince(ps)
            top.startGame         = top.startGame + pauseDuration
            top.startThisQuestion = top.startThisQuestion + pauseDuration
            print("viewWillAppear")
        }
    }
    
    override func pause() {
        guard let s = skView.scene else { return }
        s.isPaused = true
        pauseStart = Date()
        
        let ud = UserDefaults.standard
        pauseHighScoreLabel.text = NSLocalizedString("High Score: ", comment: "")
            + ud.integer(forKey: u.getKeyForHighScore()).description
        
        pauseScoreLabel.text = score.description
        
        self.view.bringSubview(toFront: pauseView)
        
    }
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func finish(state: FinishState, score: Int = 0) {
        guard let s = skView.scene else { return }
        s.isPaused = true
        self.view.bringSubview(toFront: finishView)
        
        
        switch state {
            
        case .finish:
            let ud = UserDefaults.standard
            finishHighScoreLabel.text = NSLocalizedString("High Score: ", comment: "")
                + ud.integer(forKey: u.getKeyForHighScore()).description
            
            resultLabel.text = score.description
            
            let high = ud.integer(forKey: u.getKeyForHighScore())
            if high < score { ud.set(score, forKey: u.getKeyForHighScore()) }
        case .gameOver:
            resultLabel.text = "Game Over!!"
        default:
            fatalError("チャレンジでは finish or gameover のみ")
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

class StageGameViewController: GameViewController {
    
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var finishView: UIView!
    
    
    // Pause, Finish 共通処理ここから
    @IBAction func selectMode(_ sender: UIButton) {
        let mode = storyboard!.instantiateViewController(withIdentifier: "SelectMode") as! SelectModeViewController
        mode.modalTransitionStyle = .crossDissolve
        self.present(mode, animated: true, completion: nil)
    }
    @IBAction func retry(_ sender: UIButton) {
        if let s = skView.scene { s.removeFromParent() }
        let newScene = StageGameScene(storyboard: storyboard!, gvc: self, size: skView.frame.size)
        newScene.scaleMode = .aspectFill
        skView.presentScene(newScene)
        self.view.bringSubview(toFront: skView)
    }
    // Pause, Finish 共通処理ここまで
    
    // Pause View ここから
    @IBOutlet weak var pauseStageLabel: UILabel!
    @IBOutlet weak var pauseModeLabel: UILabel!
    
    @IBOutlet weak var pauseModeSelectButton: UIButton!
    @IBOutlet weak var pauseRetryButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBAction func continueGame(_ sender: UIButton) {
        guard let s = skView.scene as? StageGameScene else { return }
        s.isPaused = false
        let pauseDuration = Date().timeIntervalSince(pauseStart!)
        top.startGame         = top.startGame + pauseDuration
        top.startThisQuestion = top.startThisQuestion + pauseDuration
        pauseStart = nil
        self.view.sendSubview(toBack: pauseView)
    }
    // Pause View ここまで
    
    // Finish View ここから
    @IBOutlet weak var finishStageLabel: UILabel!
    @IBOutlet weak var finishModeLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var finishStageSelectButton: UIButton!
    @IBOutlet weak var finishModeSelectButton: UIButton!
    @IBOutlet weak var finishRetryButton: UIButton!
    
    @IBAction func stageSelect(_ sender: UIButton) {
        let stages = storyboard!.instantiateViewController(withIdentifier: "Stages")
        stages.modalTransitionStyle = .crossDissolve
        self.present(stages,animated: true, completion: nil)
    }
    // Finish View ここまで
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        finishView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        pauseModeSelectButton.setTitle(NSLocalizedString("Mode Select", comment: ""), for: .normal)
        pauseRetryButton.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
        continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        
        finishStageSelectButton.setTitle(NSLocalizedString("Stage Select", comment: ""), for: .normal)
        finishModeSelectButton.setTitle(NSLocalizedString("Mode Select", comment: ""), for: .normal)
        finishRetryButton.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(type(of: self).willDisappear),
                       name: .UIApplicationDidEnterBackground,
                       object: nil)
        
        nc.addObserver(self,
                       selector: #selector(type(of: self).willAppear),
                       name: .UIApplicationDidBecomeActive,
                       object: nil)
        
        if let s = skView.scene { s.removeFromParent() }
        let newScene = StageGameScene(storyboard: storyboard!, gvc: self, size: skView.frame.size)
        newScene.scaleMode = .aspectFill
        skView.presentScene(newScene)
    }
    
    @objc func willDisappear() {
        guard let s = skView.scene else { return }
        s.isPaused = true
        pauseStart = Date()
        print("viewWillDisappear")
    }
    
    @objc func willAppear() {
        guard let s = skView.scene else { return }
        s.isPaused = false
        if let ps = pauseStart {
            let pauseDuration = Date().timeIntervalSince(ps)
            top.startGame         = top.startGame + pauseDuration
            top.startThisQuestion = top.startThisQuestion + pauseDuration
            print("viewWillAppear")
        }
    }
    
    override func pause() {
        guard let s = skView.scene else { return }
        s.isPaused = true
        pauseStart = Date()
        self.view.bringSubview(toFront: pauseView)
        
        let stageString: String = NSLocalizedString("Stage", comment: "") + section!.description + " - " + stage!.description
        pauseStageLabel .text = stageString
        guard let m = mode else { fatalError() }
        switch m {
        case .easy:
            pauseModeLabel.text = NSLocalizedString("Easy", comment: "")
        case .normal:
            pauseModeLabel.text = NSLocalizedString("Normal", comment: "")
        case .hard:
            pauseModeLabel.text = NSLocalizedString("Hard", comment: "")
        }
        pauseModeLabel.text = mode!.rawValue
        
    }
    
    override func finish(state: FinishState, score: Int = 0) {
        guard let s = skView.scene else { return }
        s.isPaused = true
        self.view.bringSubview(toFront: finishView)
        
        func clearStage() {
            let stageString: String = NSLocalizedString("Stage", comment: "") + section!.description + " - " + stage!.description
            finishStageLabel.text = stageString
            finishModeLabel.text = mode!.rawValue
            resultLabel.text = NSLocalizedString("Clear", comment: "")
            let ud = UserDefaults.standard
            if !ud.bool(forKey: u.getKeyStageStar(section!, stage!, mode!)) {
                let complete = ud.integer(forKey: u.getKeyStageComplete())
                ud.set(complete + 1, forKey: u.getKeyStageComplete())
            }
            ud.set(true, forKey: u.getKeyStageStar(section!, stage!, mode!))
            if section != 4 && stage == 1 {
                ud.set(true, forKey: u.getKeyStageCanPlay(section!, 2))
                ud.set(true, forKey: u.getKeyStageCanPlay(section! + 1, 1))
            } else if stage != 10 {
                ud.set(true, forKey: u.getKeyStageCanPlay(section!, stage! + 1))
            }
        }
        
        switch state {
        case .clearStage:
            clearStage()
        case .gameOver:
            let stageString: String = NSLocalizedString("Stage", comment: "") + section!.description + " - " + stage!.description
            finishStageLabel.text = stageString
            guard let m = mode else { fatalError() }
            switch m {
            case .easy:
                finishModeLabel.text = NSLocalizedString("Easy", comment: "")
            case .normal:
                finishModeLabel.text = NSLocalizedString("Normal", comment: "")
            case .hard:
                finishModeLabel.text = NSLocalizedString("Hard", comment: "")
            }
            resultLabel.text = NSLocalizedString("Game Over", comment: "")
        case .finish:
            let _ = 1
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
