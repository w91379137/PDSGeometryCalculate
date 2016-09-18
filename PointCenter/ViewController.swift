//
//  ViewController.swift
//  PointCenter
//
//  Created by w91379137 on 2016/9/7.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LocationIndicatorViewDelegate {
    
    let notificationQueue = NotificationQueue(notificationCenter: NotificationCenter.default)
    
    //來源點
    let kUpdateSourcePointNotificationName = Notification.Name("UpdateSourcePoint")
    func updateSourcePointNoti() {
        self.notificationQueue.enqueue(Notification(name: kUpdateSourcePointNotificationName),
                                       postingStyle: .asap,
                                       coalesceMask: [.onName, .onSender],
                                       forModes: nil)
    }
    
    @IBOutlet var redView : LocationIndicatorView!
    @IBOutlet var greenView : LocationIndicatorView!
    @IBOutlet var blueView : LocationIndicatorView!
    
    var redPoint = CGPoint.zero {
        didSet { self.updateSourcePointNoti() }
    }
    
    var bluePoint = CGPoint.zero {
        didSet { self.updateSourcePointNoti() }
    }
    
    var greenPoint = CGPoint.zero {
        didSet { self.updateSourcePointNoti() }
    }
    
    //計算點
    let kDrawPointUpdateNotificationName = Notification.Name("DrawPointUpdate")
    func updatedrawPointNoti() {
        self.notificationQueue.enqueue(Notification(name: kDrawPointUpdateNotificationName),
                                       postingStyle: .asap,
                                       coalesceMask: [.onName, .onSender],
                                       forModes: nil)
    }
    
    var circleCenterPoint = CGPoint.zero {
        didSet { self.updatedrawPointNoti() }
    }
    
    var circleRadius = CGFloat(0) {
        didSet { self.updatedrawPointNoti() }
    }
    
    var rbMidPoint = CGPoint.zero {
        didSet { self.updatedrawPointNoti() }
    }
    
    var rgMidPoint = CGPoint.zero {
        didSet { self.updatedrawPointNoti() }
    }
    
    var gbMidPoint = CGPoint.zero {
        didSet { self.updatedrawPointNoti() }
    }
    
    var rb4Points = [CGPoint](repeating: CGPoint.zero, count: 4) {
        didSet { self.updatedrawPointNoti() }
    }

    //MARK: - Life cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let pointViews : [LocationIndicatorView] =
            [self.blueView, self.redView, self.greenView]
        
        for view in pointViews {
            view.delegate = self
            view.canMove()
            
            let dot = self.dotView()
            dot.center = view.bounds.midPoint()
            dot.backgroundColor = view.backgroundColor
            view.addSubview(dot)
        }
        
        self.update()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateSourcePointAction),
                                               name: kUpdateSourcePointNotificationName,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateDrawPointAction),
                                               name: kDrawPointUpdateNotificationName,
                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    func dotView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        view.layer.cornerRadius = 3
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.isUserInteractionEnabled = false
        self.view.addSubview(view)
        return view
    }
    
    //MARK: - LocationIndicatorViewDelegate
    func update() {
        self.redPoint = self.redView.frame.midPoint()
        self.bluePoint = self.blueView.frame.midPoint()
        self.greenPoint = self.greenView.frame.midPoint()
    }
    
    //MARK: - Notification
    func updateSourcePointAction() {
        let (center, radius) =
            CGPoint.getCircle(redPoint, bluePoint, greenPoint)
        
        if let center = center,
            let radius = radius {
            
            self.circleCenterPoint = center
            self.circleRadius = radius
            
            self.rbMidPoint =
                CGPoint.midPointOnArc(pointA: redPoint,
                                      pointB: bluePoint,
                                      center: center)
            
            self.gbMidPoint =
                CGPoint.midPointOnArc(pointA: greenPoint,
                                      pointB: bluePoint,
                                      center: center)
            
            self.rgMidPoint =
                CGPoint.midPointOnArc(pointA: redPoint,
                                      pointB: greenPoint,
                                      center: center)
            
            let splitRate =
                [CGFloat](repeating: 1.0,
                          count: self.rb4Points.count + 1)
            
            self.rb4Points =
                CGPoint.splitPointOnArc(pointA: self.redPoint,
                                        pointB: self.bluePoint,
                                        center: center,
                                        weights: splitRate)
        }
    }
    
    //MARK: - Draw
    lazy var circle : UIView = {
        
        let circle = UIView(frame: CGRect.zero)
        circle.layer.borderColor = UIColor.purple.cgColor
        circle.layer.borderWidth = 1
        circle.isUserInteractionEnabled = false
        self.view.addSubview(circle)
        
        return circle
    }()
    
    lazy var circleCenter : UIView = {
        return self.dotView()
    }()
    
    lazy var rbMid : UIView = {
        let view = self.dotView()
        view.backgroundColor = UIColor(colorLiteralRed: 1, green: 0, blue: 1, alpha: 1)
        return view
    }()
    
    lazy var rgMid : UIView = {
        let view = self.dotView()
        view.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 0, alpha: 1)
        return view
    }()
    
    lazy var gbMid : UIView = {
        let view = self.dotView()
        view.backgroundColor = UIColor(colorLiteralRed: 0, green: 1, blue: 1, alpha: 1)
        return view
    }()
    
    lazy var spliteViews : [UIView] = {
        
        var spliteViews = [UIView]()
        for index in 0..<self.rb4Points.count {
            let view = self.dotView()
            view.backgroundColor = UIColor.darkGray
            spliteViews.append(view)
        }
        return spliteViews
    }()
    
    func updateDrawPointAction() {
        self.circleCenter.center = self.circleCenterPoint
        
        self.circle.frame =
            CGRect(x: 0,
                   y: 0,
                   width: self.circleRadius * 2,
                   height: self.circleRadius * 2)
        self.circle.center = self.circleCenterPoint
        self.circle.layer.cornerRadius = self.circleRadius
        
        self.rbMid.center = self.rbMidPoint
        self.rgMid.center = self.rgMidPoint
        self.gbMid.center = self.gbMidPoint
        
        for (index, view) in self.spliteViews.enumerated() {
            view.center = self.rb4Points[index]
        }
    }
}

//MARK: -
extension CGRect {
    func midPoint() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

protocol LocationIndicatorViewDelegate : NSObjectProtocol {
    func update()
}

class LocationIndicatorView: UIView {
    var delegate : LocationIndicatorViewDelegate?
    
    func canMove() {
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(self.move(sender:)))
        self.addGestureRecognizer(pan)
    }
    
    func move(sender : UIPanGestureRecognizer) {
        let offset = sender.translation(in: sender.view)
        sender.setTranslation(CGPoint.zero, in: sender.view)
        self.transform = self.transform.translatedBy(x: offset.x, y: offset.y)
        self.delegate?.update()
    }
}
