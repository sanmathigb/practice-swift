import UIKit
import HealthKit

/*
 Convert grams to Kilograms
*/
let gramUnit = HKUnit(fromMassFormatterUnit: NSMassFormatterUnit.Gram)
let kilogramUnit = HKUnit(fromMassFormatterUnit: NSMassFormatterUnit.Kilogram)

let weightInGrams:Double = 74_250

// Create a quantity object
let weightQuantity = HKQuantity(unit: gramUnit, doubleValue: weightInGrams)

// Convert the quantity to Kilograms
let weightInKilograms = weightQuantity.doubleValueForUnit(kilogramUnit)



