//
//  secondViewController.swift
//  bike_camera
//
//  Created by 林田計一郎 on 2022/02/26.
//

import UIKit
import Vision

class secondViewController: UIViewController {
   
    var result:UIImage! = UIImage(named: "sample.jpeg")
    var niklist:[String] = []
   
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
 
    @IBOutlet weak var img1: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let W = self.view.frame.width
        let H = self.view.frame.height
        let rect = CGRect(x:result.size.width*0.1,y:result.size.height*0.28,width:result.size.width*0.8,height: result.size.width*0.32
        )
        //print(rect)
        result = result.rotatedBy(degree: 90)
        let inpimg = result.cgImage?.cropping(to: rect)
        let inp = UIImage(cgImage: inpimg!).reSizeImage(reSize: CGSize(width: W, height: W*0.7))
        let inpimg2 = inp.cgImage
        img1.frame = CGRect(x: W*0.05, y: H*0.2, width: W*0.9, height:W*0.7*0.9)
        img1.image = inp
   

        niklist = loadCSV(fileName: "nik")
      
        // Do any additional setup after loading the view.
        let model = try? VNCoreMLModel(for: nik2().model)
        
        // VNCoreMLRequestを呼ぶとモデルが推測した結果が返ってくる
        let request = VNCoreMLRequest(model: model!, completionHandler: {
            (finishReq, err) in
//            print(finishReq.results)
            
            let results = finishReq.results as? [VNCoreMLFeatureValueObservation]
            
            //確率の高い最初の予測だけ取り出す。
            let firstObservation = results?.first
           
            let m: MLMultiArray = (firstObservation?.featureValue.multiArrayValue!)!
            var ans = self.convertToArray(from: m)
            let key = [Int](0...(ans.count-1))
            
            
            let dic = Dictionary(uniqueKeysWithValues: zip(key,ans))
            let sorted = dic.sorted(by: {$0.1>$1.1})
            //print(self.ave_ans)
            let res1:String = self.niklist[sorted[0].key]
            let res2:String = self.niklist[sorted[1].key]
            let res3:String = self.niklist[sorted[2].key]
           
            // 識別結果と確率を表示する
            DispatchQueue.main.async {
                //self.img1.image = UIImage(cgImage: inpimg2!)
                self.label.text = res1
                self.label2.text = res2
                self.label3.text = res3
            }
            
        })
        try? VNImageRequestHandler(cgImage: inpimg2!, options: [:]).perform([request])
        
    }
    func loadCSV(fileName: String) -> [String] {
        let csvBundle = Bundle.main.path(forResource: fileName, ofType: "csv")!
        var csvArray:[String] = []
        do {
            let csvData = try String(contentsOfFile: csvBundle,encoding: String.Encoding.utf8)
            
            csvArray = csvData.components(separatedBy: ",")
            csvArray.removeLast()
        } catch {
            print("エラー")
        }
        return csvArray
    }
    func convertToArray(from mlMultiArray: MLMultiArray) -> [Double] {
        
        // Init our output array
        var array: [Double] = []
        
        // Get length
        let length = mlMultiArray.count
        
        // Set content of multi array to our out put array
        for i in 0...length - 1 {
            array.append(Double(truncating: mlMultiArray[[0,NSNumber(value: i)]]))
        }
        
        return array
    }
    


}
extension UIImage {

    func rotatedBy(degree: CGFloat) -> UIImage {
        let radian = -degree * CGFloat.pi / 180
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.size.width / 2, y: self.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)

        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }

}
extension UIImage {
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }

    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
