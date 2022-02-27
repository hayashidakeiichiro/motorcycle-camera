//
//  secondViewController.swift
//  bike_camera
//
//  Created by 林田計一郎 on 2022/02/26.
//

import UIKit
import Vision
import SafariServices

class secondViewController: UIViewController {
   
    var result:UIImage! = UIImage(named: "sample.jpeg")
    var niklist:[String] = []
   
   
    
    @IBOutlet weak var btn1: UIButton!
    
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    var url:String = "https://moto.webike.net/list/?wd="
 
    @IBOutlet weak var img1: UIImageView!
   
    @IBOutlet weak var backimg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let W = self.view.frame.width
        let H = self.view.frame.height
        let rect = CGRect(x:result.size.width*0.1,y:result.size.height*0.28,width:result.size.width*0.8,height: result.size.width*0.32
        )
        //print(rect)
        result = result.rotatedBy(degree: 90)
        let inpimg = result.cgImage?.cropping(to: rect)
        let inp = UIImage(cgImage: inpimg!).reSizeImage(reSize: CGSize(width: W, height: W*0.7))//.flipHorizontal()
        let inpimg2 = inp.cgImage
        backimg.frame = CGRect(x: W*0.05, y: H*0.15, width: W*0.9, height:W*0.7*0.9)
        img1.frame = CGRect(x: W*0.1, y: H*0.15+W*0.7*0.05, width: W*0.8, height:W*0.7*0.8)
        img1.image = inp
        
        
        
        niklist = loadCSV(fileName: "nik")
        
        // Do any additional setup after loading the view.
        let model = try? VNCoreMLModel(for: nik().model)
        
       
        let request = VNCoreMLRequest(model: model!, completionHandler: {
            (finishReq, err) in
//            print(finishReq.results)
            
            let results = finishReq.results as? [VNCoreMLFeatureValueObservation]
            
          
            let firstObservation = results?.first
           
            let m: MLMultiArray = (firstObservation?.featureValue.multiArrayValue!)!
            let ans = self.convertToArray(from: m)
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
          
                self.btn1.setTitle(res1, for: .normal)
                self.btn2.setTitle(res2, for: .normal)
                self.btn3.setTitle(res3, for: .normal)
                
            }
            
        })
        try? VNImageRequestHandler(cgImage: inpimg2!, options: [:]).perform([request])
        
        //ボタンの調整
        let btnr:CGFloat = 10
        btn1.frame = CGRect(x: W*0.05, y: H*0.15+W*0.8, width: W*0.9, height:W*0.2)
        btn1.layer.cornerRadius = btnr
        btn1.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        btn1.layer.borderWidth = 5.0
        btn1.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        btn2.frame = CGRect(x: W*0.15, y: H*0.15+W*1.1, width: W*0.7, height:W*0.15)
        btn2.layer.cornerRadius = btnr
        btn2.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        btn2.layer.borderWidth = 5.0
        btn2.titleLabel?.adjustsFontSizeToFitWidth = true
       
        
        btn3.frame = CGRect(x: W*0.15, y: H*0.15+W*1.1+W*0.2, width: W*0.7, height:W*0.15)
        btn3.layer.cornerRadius = btnr
        btn3.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        btn3.layer.borderWidth = 5.0
        btn3.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
    @IBAction func toweb1(_ sender: Any) {
        let u = self.url + self.btn1.currentTitle!
        let change_u = u.replacingOccurrences(of: " ", with: "%20")
      
        let url = URL(string:change_u)

        if let url = url {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: false, completion: nil)
        }
        
    }
    
    @IBAction func toweb2(_ sender: Any) {
        let u = self.url + self.btn2.currentTitle!
        let change_u = u.replacingOccurrences(of: " ", with: "%20")
      
        let url = URL(string:change_u)
        if let url = url {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: false, completion: nil)
        }
    }
    
    @IBAction func toweb3(_ sender: Any) {
        let u = self.url + self.btn3.currentTitle!
        let change_u = u.replacingOccurrences(of: " ", with: "%20")
      
        let url = URL(string:change_u)
        if let url = url {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: false, completion: nil)
        }
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
extension UIImage {

    //左右反転
    func flipHorizontal() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let imageRef = self.cgImage
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: size.width, y:  size.height)
        context?.scaleBy(x: -1.0, y: -1.0)
        context?.draw(imageRef!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let flipHorizontalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flipHorizontalImage!
    }

}
extension StringProtocol where Self: RangeReplaceableCollection {
  var removeWhitespacesAndNewlines: Self {
    filter { !$0.isNewline && !$0.isWhitespace }
  }
}


