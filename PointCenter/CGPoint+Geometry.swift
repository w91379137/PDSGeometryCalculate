//
//  CGPoint+Geometry.swift
//  PointCenter
//
//  Created by w91379137 on 2016/9/7.
//  Copyright © 2016年 w91379137. All rights reserved.
//

import UIKit

extension CGPoint {
    
    static func midPoint(_ pointA : CGPoint,
                         _ pointB : CGPoint) -> CGPoint {
        return CGPoint(x: (pointA.x + pointB.x) / 2,
                       y: (pointA.y + pointB.y) / 2)
    }
    
    static func vector(_ pointA : CGPoint,
                       _ pointB : CGPoint) -> CGPoint {
        return CGPoint(x: pointB.x - pointA.x,
                       y: pointB.y - pointA.y)
    }
    
    static func distance(_ pointA : CGPoint,
                         _ pointB : CGPoint) -> CGFloat {
        return CGPoint.vector(pointA, pointB).length()
    }
    
    func length() -> CGFloat {
        return sqrt(pow(self.x , 2) + pow(self.y , 2))
    }
    
    static func switchXY(_ vector : CGPoint) -> CGPoint {
        return CGPoint(x: vector.y, y: vector.x)
    }
    
    static func vertical(_ vector : CGPoint) -> CGPoint {
        return CGPoint(x: vector.y, y: -vector.x)
    }
    
    func offsetBy(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
    
    //MARK: - 解方程組
    static func findCircle(_ pointA : CGPoint,
                           _ pointB : CGPoint,
                           _ pointC : CGPoint) -> CGPoint? {
        
        let vBA = CGPoint.vertical(CGPoint.vector(pointB, pointA))
        let mBA = CGPoint.midPoint(pointA, pointB)
        
        let vCA = CGPoint.vertical(CGPoint.vector(pointC, pointA))
        let mCA = CGPoint.midPoint(pointC, pointA)
        
        return CGPoint.findSolution(lineV1: vBA, p1: mBA,
                                    lineV2: vCA, p2: mCA)
    }
    
    static func findSolution(lineV1: CGPoint,
                             p1: CGPoint,
                             lineV2: CGPoint,
                             p2: CGPoint) -> CGPoint? {
        
        var v1 = lineV1
        var v2 = lineV2
        
        var d = CGPoint.vector(p1, p2)
        
        /*
         解 k h
         k * v1 + p1 = h * v2 + p2
         
         解 k h
         k * v1 = h * v2 + d
         */
        
        //目標使 v2.x = 0
        if v2.x == 0 {
            //不用動作
        }
        else if v2.y == 0 {
            //交換
            v1 = CGPoint.switchXY(v1)
            v2 = CGPoint.switchXY(v2)
            d = CGPoint.switchXY(d)
        }
        else {
            //相減
            let s = v2.x / v2.y
            v1 = CGPoint(x: v1.x - v1.y * s, y: v1.y)
            v2 = CGPoint(x: v2.x - v2.y * s, y: v2.y)
            d = CGPoint(x: d.x - d.y * s, y: d.y)
        }
        
        if v1.x != 0 {
            let k = d.x / v1.x
            return CGPoint(x: p1.x + k * lineV1.x,
                           y: p1.y + k * lineV1.y)

        }
        
        print("共線")
        return nil
    }
    
    //MARK: - 極座標
    //clockwiseRotate clockwiseAngle 互為反函數
    static func clockwiseRotate(center : CGPoint,
                                radius : CGFloat,
                                angle : CGFloat) -> CGPoint {
        return CGPoint(x: center.x + cos(angle) * radius,
                       y: center.y + sin(angle) * radius)
    }
    
    //輸出0 ~ 360
    static func clockwiseAngle(center : CGPoint,
                               point : CGPoint) -> CGFloat {
        
        let distants = CGPoint.distance(center, point)
        if distants == 0 { return 0 }//兩點重和
        
        let cosValue = (point.x - center.x) / distants
        let sinValue = (point.y - center.y) / distants
        
        if cosValue == 0 || sinValue == 0 {
            if sinValue == 0 {
                if cosValue > 0 {return 0}
                if cosValue < 0 {return CGFloat(M_PI)}
            }
            else if cosValue == 0 {
                if sinValue > 0 {return CGFloat(M_PI) * 0.5}
                if sinValue < 0 {return CGFloat(M_PI) * 1.5}
            }
        }
        
        let thetaSin = asin(sinValue) //asin -90 ~ 90
        let thetaCos = acos(cosValue) //acos 0 ~ 180
        
        var angle = thetaCos
        
        //一 二 象限不用處理
        if sinValue < 0 {
            if cosValue < 0 { //三
                angle = CGFloat(2 * M_PI) - thetaCos
            }
            else { //四
                angle = CGFloat(2 * M_PI) + thetaSin
            }
        }
        
        return angle
    }
    
    
    //MARK: - 分點公式
    static func midPointOnArc(pointA : CGPoint,
                              pointB : CGPoint,
                              center : CGPoint,
                              isOnSmallSide : Bool = true) -> CGPoint {
        
        return splitPointOnArc(pointA: pointA,
                               pointB: pointB,
                               center: center,
                               weights: [1, 1],
                               isOnSmallSide: isOnSmallSide).first!
    }
    
    static func splitPointOnArc(pointA : CGPoint,
                                pointB : CGPoint,
                                center : CGPoint,
                                weights : [CGFloat],
                                sameSide pointC : CGPoint) -> [CGPoint] {
        
        let angleA = CGPoint.clockwiseAngle(center: center, point: pointA)
        let angleB = CGPoint.clockwiseAngle(center: center, point: pointB)
        let angleC = CGPoint.clockwiseAngle(center: center, point: pointC)
        
        let smallAngle = min(angleA, angleB)
        let bigAngle = max(angleA, angleB)
        
        let isBetweenSmallBigAngle = angleC > smallAngle && angleC < bigAngle
        let isBetweenAngleLessThanPI = (bigAngle - smallAngle) < CGFloat(M_PI)
        
        return splitPointOnArc(pointA : pointA,
                               pointB : pointB,
                               center : center,
                               weights : weights,
                               isOnSmallSide : (isBetweenSmallBigAngle == isBetweenAngleLessThanPI))
    }
    
    static func splitPointOnArc(pointA : CGPoint,
                                pointB : CGPoint,
                                center : CGPoint,
                                weights : [CGFloat],
                                isOnSmallSide : Bool = true) -> [CGPoint] {
        
        var angleA = CGPoint.clockwiseAngle(center: center, point: pointA)
        let angleB = CGPoint.clockwiseAngle(center: center, point: pointB)
        
        let isSmallAngle = fabs(angleA - angleB) <= CGFloat(M_PI)
        if isSmallAngle != isOnSmallSide {
            if angleA > angleB { angleA -= CGFloat(2 * M_PI) }
            else { angleA += CGFloat(2 * M_PI) }
        }
        
        var points = [CGPoint]()
        let values = CGFloat.splitValue(valueA: angleA,
                                        valueB: angleB,
                                        weights: weights)
        
        let radius = CGPoint.distance(pointA, center)
        for value in values {
            points.append(CGPoint.clockwiseRotate(center: center,
                                                  radius: radius,
                                                  angle: value))
        }
        
        return points
    }
    
    static func splitPointOnLine(pointA : CGPoint,
                                 pointB : CGPoint,
                                 weights : [CGFloat]) -> [CGPoint] {
        
        
        let values = CGFloat.splitValue(valueA: 1, valueB: 0, weights: weights)
        var points = [CGPoint]()
        
        for value in values {
            points.append(CGPoint(x: pointA.x * value + pointB.x * (1 - value),
                                  y: pointA.y * value + pointB.y * (1 - value)))
        }
        
        return points
    }
    
    static func splitPointOnArc(pointA : CGPoint,
                                pointB : CGPoint,
                                pointC : CGPoint,
                                center : CGPoint,
                                weightsAC : [CGFloat],
                                weightsCB : [CGFloat]) -> ([CGPoint], [CGPoint]) {
        
        //目標 C 在 A 在 B 中間
        var angleA = CGPoint.clockwiseAngle(center: center, point: pointA)
        var angleB = CGPoint.clockwiseAngle(center: center, point: pointB)
        let angleC = CGPoint.clockwiseAngle(center: center, point: pointC)
        
        if angleC < angleA && angleC < angleB {
            //CAB
            //CBA
            if angleA > angleB {
                angleA -= CGFloat(2 * M_PI)
            }
            else {
                angleB -= CGFloat(2 * M_PI)
            }
        }
        else if angleC > angleA && angleC > angleB {
            //ABC
            //BAC
            if angleA > angleB {
                angleB += CGFloat(2 * M_PI)
            }
            else {
                angleA += CGFloat(2 * M_PI)
            }
        }
        
        let radius = CGPoint.distance(pointA, center)
        
        var pointsAC = [CGPoint]()
        let valuesAC = CGFloat.splitValue(valueA: angleA,
                                          valueB: angleC,
                                          weights: weightsAC)
        
        for value in valuesAC {
            pointsAC.append(CGPoint.clockwiseRotate(center: center,
                                                    radius: radius,
                                                    angle: value))
        }
        
        var pointsCB = [CGPoint]()
        let valuesCB = CGFloat.splitValue(valueA: angleC,
                                          valueB: angleB,
                                          weights: weightsCB)
        
        for value in valuesCB {
            pointsCB.append(CGPoint.clockwiseRotate(center: center,
                                                    radius: radius,
                                                    angle: value))
        }
        
        return (pointsAC, pointsCB)
    }
}

extension CGFloat {
    
    static func splitValue(valueA : CGFloat,
                           valueB : CGFloat,
                           weights : [CGFloat]) -> [CGFloat] {
        
        var weightsSum = CGFloat(0)
        for weight in weights {
            weightsSum += weight
        }
        if weightsSum == 0 {
            return []
        }
        
        var values = [CGFloat]()
        
        var weightA = weightsSum
        var weightB = CGFloat(0)
        for (index, weight) in weights.enumerated() {
            if index != weights.count - 1 {
                
                weightA -= weight
                weightB += weight
                
                let scaleA = weightA / weightsSum
                let scaleB = weightB / weightsSum
                
                values.append(valueA * scaleA + valueB * scaleB)
            }
        }
        
        return values
    }
}
