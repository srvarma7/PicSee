//
//  PersonTrainingSet.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 27/11/23.
//

import CoreML

struct PersonTrainingSet {
    
    /// Collection of the training drawings
    private var trainingPerson = [PersonImage]()
    
    /// The emoji or sticker that the model should predict when passed similar images
    let name: String
    
    init(for emoji: String) {
        self.name = emoji
    }
    
    /// Creates a batch provider of training data given the contents of `trainingDrawings`.
    /// - Tag: DrawingBatchProvider
    var featureBatchProvider: MLBatchProvider {
        var featureProviders = [MLFeatureProvider]()
        
        let inputName = "image"
        let outputName = "label"
        
        for person in trainingPerson {
            let inputValue = person.featureValue
            let outputValue = MLFeatureValue(string: name)
            
            let dataPointFeatures: [String: MLFeatureValue] = [inputName: inputValue, outputName: outputValue]
            
            if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeatures) {
                featureProviders.append(provider)
            }
        }
        
        return MLArrayBatchProvider(array: featureProviders)
    }
    
    /// Adds a drawing to the private array, but only if the type requires more.
    mutating func addPerson(_ person: PersonImage) {
        trainingPerson.append(person)
    }
}


import CoreML
import CoreImage

/// Convenience structure that stores a drawing's `CGImage`
/// - Tag: Drawing
struct PersonImage {
    private static let ciContext = CIContext()
    
    /// The underlying image of the drawing.
    let image: CGImage
    
    /// Rectangle containing this drawing in the canvas view
    let rect: CGRect
    
    /// Wraps the underlying image in a feature value.
    /// - Tag: ImageFeatureValue
    var featureValue: MLFeatureValue {
        // Get the model's image constraints.
        let imageConstraint = ModelUpdater.imageConstraint
        
        // Get a white tinted version to use for the model
        let preparedImage = whiteTintedImage
        
        let imageFeatureValue = try? MLFeatureValue(cgImage: preparedImage, constraint: imageConstraint)
        return imageFeatureValue!
    }
    
    private var whiteTintedImage: CGImage {
        let ciContext = PersonImage.ciContext
        
        let parameters = [kCIInputBrightnessKey: 1.0]
        let ciImage = CIImage(cgImage: image).applyingFilter("CIColorControls", parameters: parameters)
        return ciContext.createCGImage(ciImage, from: ciImage.extent)!
    }
}
