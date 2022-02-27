import UIKit
import AVFoundation

var img:UIImage! = UIImage(named:("sample"))
class ViewController: UIViewController {

    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    @IBOutlet weak var transimg: UIImageView!
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
   
    @IBOutlet weak var backimg: UIImageView!
    var currentDevice: AVCaptureDevice?
   
    @IBOutlet weak var underbar: UIImageView!
    var photoOutput : AVCapturePhotoOutput?
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    // シャッターボタン
    @IBOutlet weak var cameraButton: UIButton!
 
    let focus = UIImage(named: "focus.png")

    @IBOutlet weak var focusview: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backbtn = UIBarButtonItem()
        backbtn.title = "撮り直す"
        //self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backbtn
        let W = self.view.frame.width
        let H = self.view.frame.height
       
        transimg.frame = CGRect(x: 0, y: H*0.2+W*0.7, width: W, height:H-H*0.2-W*0.7)
        focusview.frame = CGRect(x: 0, y: H*0.2, width: W, height:W*0.7 )
        backimg.frame = CGRect(x: 0, y: 0, width: W, height:H*0.2 )
        underbar.frame = CGRect(x: 0, y: H*0.85, width: W, height:H*0.15 )
        cameraButton.frame = CGRect(x: W*0.5-H*0.05, y: H*0.875, width: H*0.1 , height:H*0.1 )
        
        focusview.image = focus
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        styleCaptureButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // シャッターボタンが押された時のアクション
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
      
        // カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateメソッドで処理
        self.photoOutput?.capturePhoto(with: settings, delegate: self as! AVCapturePhotoCaptureDelegate)
        cameraButton.isEnabled = false
     
        DispatchQueue.main.asyncAfter(deadline: .now()+0.9){
            self.cameraButton.isEnabled = true
            self.performSegue(withIdentifier: "tosecond", sender: nil)
        }
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "tosecond" {
                let nextview = segue.destination as! secondViewController
                nextview.result = img
            }
        }

}

//MARK: AVCapturePhotoCaptureDelegateデリゲートメソッド
extension ViewController: AVCapturePhotoCaptureDelegate{
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        //var uimg:UIImage! = UIImage(named: "")
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            img = UIImage(data: imageData)!
            
        
            
        }
        
    }
}

//MARK: カメラ設定メソッド
extension ViewController{
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }

    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }

    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
        let pvSize = self.view.frame.width
       
        self.cameraPreviewLayer?.frame = view.frame
        self.cameraPreviewLayer?.frame = CGRect(x: 0, y: 60, width: pvSize, height: pvSize*0.7)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
       
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait

        self.cameraPreviewLayer?.frame = view.frame
       
    }

    // ボタンのスタイルを設定
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
        
        cameraButton.layer.borderColor = UIColor(red: 0, green: 0, blue: 224, alpha: 0.6).cgColor
        cameraButton.layer.borderWidth = 5.0
        
        
    }
}
