import UIKit
import Flutter
import UniformTypeIdentifiers

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, UIDocumentPickerDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let fileChannel = FlutterMethodChannel(name: "com.sicreative.vocabularycard.vocabulary_card/file",
                                              binaryMessenger: controller.binaryMessenger)
    fileChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
    if call.method == "save"{
            self.saveCSV((call.arguments as! Dictionary)["csv", default: ""] as String)
            return
        }
        
        if call.method == "load"{
            self.loadCSV();
        }
        
    })

    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        pickerPickedCallBack(url)
    }
    

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if (urls.count==1){
            pickerPickedCallBack(urls[0])
        }
    }
    
    private func pickerPickedCallBack(_ url:URL){
        
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
            
        let fileChannel = FlutterMethodChannel(name: "com.sicreative.vocabularycard.vocabulary_card/file",
                                                      binaryMessenger: controller.binaryMessenger)
      
        do{
            
           let isAccessing = url.startAccessingSecurityScopedResource()
        
           let csv = try String(contentsOf: url, encoding: .utf8)
            
            if (isAccessing){
                url.stopAccessingSecurityScopedResource()
            }
        
            let args = ["csv":csv,"result":"true"]
         
            fileChannel.invokeMethod("loadresult", arguments: args)
            
            
        }catch{
            
            print("Unexpected error: \(error).")
            
            let args = ["result":"false"]
         
            fileChannel.invokeMethod("loadresult", arguments: args)
            
        }
        
    }
    
    private func saveResultTrue(){
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let fileChannel = FlutterMethodChannel(name: "com.sicreative.vocabularycard.vocabulary_card/file",
                                                      binaryMessenger: controller.binaryMessenger)
        let args = ["result":"true"]
         
            fileChannel.invokeMethod("saveresult", arguments: args)
    }
    
    private func saveResultFalse(){
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let fileChannel = FlutterMethodChannel(name: "com.sicreative.vocabularycard.vocabulary_card/file",
                                                      binaryMessenger: controller.binaryMessenger)
        let args = ["result":"true"]
         
            fileChannel.invokeMethod("saveresult", arguments: args)
    }
    
    
    
    private func saveCSV ( _ csv: String) {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("output.csv")
        
        do{
         try csv.write(to: url!, atomically: true, encoding: String.Encoding.utf8)
        }catch{
            
        }
        
        if #available(iOS 14.0, *) {
            
            let documentPickerController = UIDocumentPickerViewController(forExporting: [url!])
            
            controller.present(documentPickerController, animated: true, completion: saveResultTrue)
            
        } else {

            let documentPickerController = UIDocumentPickerViewController(documentTypes: ["csv"], in: .exportToService)
          
            controller.present(documentPickerController, animated: true, completion: saveResultTrue)
          
        }
        
        
      
        
        saveResultFalse();
       

        
        
        
    }
    
    

    private func loadCSV () {
        
        
    

                
                let controller : FlutterViewController = self.window?.rootViewController as! FlutterViewController
                
                
                
                
                
                if #available(iOS 14.0, *) {
                    
                    let type = UTType(filenameExtension: "csv")
                    
                    let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [type!])
                        documentPickerController.delegate = self
                            controller.present(documentPickerController, animated: true, completion: nil)
                    
                    
                    
                } else {

                    let documentPickerController = UIDocumentPickerViewController(documentTypes: ["csv"], in: .open)
                    
                   documentPickerController.delegate = self
                    
                    controller.present(documentPickerController, animated: true, completion:nil)
                  
                }
              
                
                
                
            }
           
        
        
    
       
        

    
}






