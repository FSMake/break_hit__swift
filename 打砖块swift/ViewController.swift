//
//  ViewController.swift
//  打砖块swift
//
//  Created by 樊樊帅 on 9/6/15.
//  Copyright (c) 2015 樊樊帅. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var paddleVelocityX:CGFloat = 0
    var ballVelocity:CGPoint = CGPointMake(0, 0)
    var gameTimer: CADisplayLink?
    
    @IBOutlet var blocks: [UIImageView]!
    @IBOutlet weak var ball: UIImageView!
    @IBOutlet weak var paddle: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet var panRecongizer: UIPanGestureRecognizer!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    屏幕点击 开始游戏
    */
    @IBAction func tap(sender: AnyObject) {
        println("开始游戏")
        if tapRecognizer.enabled == false {
            return
        }
        tapRecognizer.enabled = false
        for block in blocks {
            block.hidden = false
        }
        self.message.hidden = true
        //初始速度
        ballVelocity = CGPointMake(0.0, -5.0)
        ball.center = CGPointMake(160, 506)
        paddle.center = CGPointMake(160, 527)
        gameTimer = CADisplayLink(target: self, selector: "timeUpdate")
        gameTimer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    /**
    手指移动，拖动挡板
    */
    @IBAction func move(sender: AnyObject) {
        let panRecognizer = sender as! UIPanGestureRecognizer
        /**
        *  开始拖动
        */
        if panRecognizer.state == UIGestureRecognizerState.Changed {
            var location = panRecognizer.locationInView(self.view)
            self.paddle.center = CGPointMake(location.x, self.paddle.center.y)
            paddleVelocityX = panRecognizer.velocityInView(self.view).x / 120.0
        }
        /**
        *  结束拖动，速度变为0
        */
        if panRecognizer.state == UIGestureRecognizerState.Ended {
            paddleVelocityX = 0
        }
    }
    
    func timeUpdate() {
        println("屏幕刷新")
        successedTest()
        failedTest()
        edgeHitTest()
        paddleHitTest()
        blockHitTest()
        ball.center = CGPointMake(ball.center.x + ballVelocity.x, ball.center.y + ballVelocity.y)
    }
    //砖块碰撞测试
    func blockHitTest() {
        for block in blocks {
            if CGRectIntersectsRect(ball.frame, block.frame) && block.hidden == false {
                ballVelocity = CGPointMake(ballVelocity.x, abs(ballVelocity.y))
                block.hidden = true
            }
        }
    }
    //挡板碰撞测试
    func paddleHitTest() {
        if CGRectIntersectsRect(ball.frame, paddle.frame) {
            ballVelocity = CGPointMake(ballVelocity.x + paddleVelocityX, -abs(ballVelocity.y))
        }
    }
    
    //边缘碰撞测试
    func edgeHitTest() {
        if ball.frame.origin.x < 0 {
            ballVelocity = CGPointMake(abs(ballVelocity.x), ballVelocity.y)
        }
        if CGRectGetMaxX(ball.frame) > UIScreen.mainScreen().bounds.size.width {
            ballVelocity = CGPointMake(-abs(ballVelocity.x), ballVelocity.y)
        }
        if ball.frame.origin.y < 0 {
            ballVelocity = CGPointMake(ballVelocity.x, abs(ballVelocity.y))
        }
        
    }
    
    //失败测试
    func failedTest() {
        if CGRectGetMaxY(ball.frame) > UIScreen.mainScreen().bounds.size.height {
            //游戏失败
            message.text = "你输了！"
            message.hidden = false
            gameTimer!.invalidate()
            tapRecognizer.enabled = true
        }
    }
    
    //胜利测试
    func successedTest() {
        var success = true
        successJudgeLoop: for block in blocks {
            if block.hidden == false {
                //还没有成功
                success = false
                break successJudgeLoop
            }
        }
        if success == true {
            //游戏胜利
            gameTimer!.invalidate()
            message.text = "恭喜你胜利了！"
            message.hidden = false
            tapRecognizer.enabled = true
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

