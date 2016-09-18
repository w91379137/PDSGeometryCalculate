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
    
    static func distants(_ pointA : CGPoint,
                         _ pointB : CGPoint) -> CGFloat {
        return sqrt(pow(pointA.x - pointB.x, 2) + pow(pointA.y - pointB.y, 2))
    }
    
    static func switchXY(_ vector : CGPoint) -> CGPoint {
        return CGPoint(x: vector.y, y: vector.x)
    }
    
    static func vertical(_ vector : CGPoint) -> CGPoint {
        return CGPoint(x: vector.y, y: -vector.x)
    }
    
    static func getCircle(_ pointA : CGPoint,
                          _ pointB : CGPoint,
                          _ pointC : CGPoint) -> (CGPoint?, CGFloat?){
        
        var vBA = CGPoint.vertical(CGPoint.vector(pointB, pointA))
        let mBA = CGPoint.midPoint(pointA, pointB)
        
        var vCA = CGPoint.vertical(CGPoint.vector(pointC, pointA))
        let mCA = CGPoint.midPoint(pointC, pointA)
        
        var d = CGPoint.vector(mBA, mCA)
        
        /*
         解 k h
         k * vBA + mBA = h * vCA + mCA
         
         解 k h
         k * vBA = h * vCA + d
         */
        
        //目標使 v31.x = 0
        if vCA.x == 0 {
            //不用動作
        }
        else if vCA.y == 0 {
            //交換
            vBA = CGPoint.switchXY(vBA)
            vCA = CGPoint.switchXY(vCA)
            d = CGPoint.switchXY(d)
        }
        else {
            //相減
            let s = vCA.x / vCA.y
            vBA = CGPoint(x: vBA.x - vBA.y * s, y: vBA.y)
            vCA = CGPoint(x: vCA.x - vCA.y * s, y: vCA.y)
            d = CGPoint(x: d.x - d.y * s, y: d.y)
        }
        
        if vBA.x != 0 {
            let k = d.x / vBA.x
            let v = CGPoint.vertical(CGPoint.vector(pointB, pointA))
            
            let center = CGPoint(x: mBA.x + k * v.x,
                                 y: mBA.y + k * v.y)
            
            let radius = sqrt(pow(center.x - pointA.x, 2) + pow(center.y - pointA.y, 2))
            return (center, radius)
        }
        
        print("共線")
        return (nil, nil)
    }
    
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
        
        let distants = CGPoint.distants(center, point)
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
                                isOnSmallSide : Bool = true) -> [CGPoint] {
        
        //檢查數目
        if weights.count <= 1 {
            return []
        }
        
        //檢查權重總和
        var weightsSum = CGFloat(0)
        for weight in weights {
            weightsSum += weight
        }
        if weightsSum == 0 {
            return []
        }
        
        var points = [CGPoint]()
        
        let distants = sqrt(pow(center.x - pointA.x, 2) + pow(center.y - pointA.y, 2))
        var angleA = CGPoint.clockwiseAngle(center: center, point: pointA)
        let angleB = CGPoint.clockwiseAngle(center: center, point: pointB)
        
        let isSmallAngle = fabs(angleA - angleB) <= CGFloat(M_PI)
        if isSmallAngle != isOnSmallSide {
            if angleA > angleB { angleA -= CGFloat(2 * M_PI) }
            else { angleA += CGFloat(2 * M_PI) }
        }
        
        var weightA = CGFloat(0)
        var weightB = weightsSum
        for (index, weight) in weights.enumerated() {
            if index != weights.count - 1 {
                
                weightA += weight
                weightB -= weight
                
                let angle =
                    angleA * weightA / weightsSum +
                        angleB * weightB / weightsSum
                
                points.append(CGPoint.clockwiseRotate(center: center,
                                                      radius: distants,
                                                      angle: angle))
            }
        }
        
        return points
    }
}
