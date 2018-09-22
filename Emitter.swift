import UIKit
class Emitter {
    static func createEmitter(with emitterShape: String, with image: UIImage) -> CAEmitterLayer {
        let layer = CAEmitterLayer()
        layer.emitterShape = emitterShape
        layer.emitterCells = generateEmitterCell(with: image)
        return layer
    }
    static func generateEmitterCell(with image: UIImage) -> [CAEmitterCell] {
        var cells = [CAEmitterCell]()
        let cell = CAEmitterCell()
        cell.contents = image.cgImage
        cell.birthRate = 0.5
        cell.lifetime = 30
        cell.velocity = 25
        cell.velocityRange = 5
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 3
        cell.scale = 0.3
        cell.scaleRange = 0.1
        cells.append(cell)
        return cells
    }
}
