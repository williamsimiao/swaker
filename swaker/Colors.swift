//
//  Colors.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 08/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import Foundation
import UIKit

let darkBlue = UIColor(red: 0, green: 71/255, blue: 129/255, alpha: 1.0)
let darkerBlue = UIColor(red: 0, green: 43/255, blue: 78/255, alpha: 1.0)
let darkestBlue = UIColor(red: 1/255, green: 29/255, blue: 54/255, alpha: 1.0)
let lightBlue = UIColor(red: 194/255, green: 236/255, blue: 238/255, alpha: 1.0)
let coldBlue = UIColor(red: 0, green: 91/255, blue: 133/255, alpha: 1.0)
let yellow = UIColor(red: 255/255, green: 175/255, blue: 0/255, alpha: 1.0)
let warmYellow = UIColor(red: 251/255, green: 219/255, blue: 119/255, alpha: 1.0)
let crimson = UIColor(red: 224/255, green: 89/255, blue: 124/255, alpha: 1.0)
let selectedTintColor = UIColor(red: 255/255, green: 159/255, blue: 0/255, alpha: 1.0)
//let separatorColor = UIColor(red: 199.9/255, green: 199/255, blue: 204/255, alpha: 1.0)
let navBarTintColor = UIColor(red: 2/255, green: 106/255, blue: 190/255, alpha: 1.0)
let separatorColor = navBarTintColor

private let mainColors1 = [darkBlue.CGColor, lightBlue.CGColor, yellow.CGColor]
private let mainColors2 = [yellow.CGColor, lightBlue.CGColor, darkBlue.CGColor]
private let mainColors3 = [darkBlue.CGColor, lightBlue.CGColor]
private let mainColors4 = [lightBlue.CGColor, warmYellow.CGColor]
private let mainColors5 = [warmYellow.CGColor, crimson.CGColor, darkerBlue.CGColor]
private let mainColors6 = [darkerBlue.CGColor, darkestBlue.CGColor, coldBlue.CGColor]
private let mainColors7 = [coldBlue.CGColor, darkestBlue.CGColor, darkBlue.CGColor]
private let mainColors8 = [darkBlue.CGColor, lightBlue.CGColor, yellow.CGColor]
private let mainColors = [mainColors8, mainColors1, mainColors2, mainColors3, mainColors4, mainColors5, mainColors6, mainColors7]

func mainColor() -> [CGColor!] {
    let comps = NSCalendar.currentCalendar().components(.CalendarUnitHour, fromDate: NSDate())
    let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
    return mainColors1
}

private let mainLocations1 = [0, 0.70, 1]
private let mainLocations2 = [0, 0.30, 1]
private let mainLocations3 = [0, 1]
private let mainLocations4 = [0, 1]
private let mainLocations5 = [0, 0.40, 1]
private let mainLocations6 = [0, 0.40, 1]
private let mainLocations7 = [0, 0.40, 1]
private let mainLocations8 = [0, 0.70, 1]
private let mainLocations = [mainLocations8, mainLocations1, mainLocations2, mainLocations3, mainLocations4, mainLocations5, mainLocations6, mainLocations7]

func mainLocation() -> [AnyObject] {
    let comps = NSCalendar.currentCalendar().components(.CalendarUnitHour, fromDate: NSDate())
    let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
    return mainLocations1
}