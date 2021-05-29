import Cocoa
import FlutterMacOS
import UniformTypeIdentifiers

class MainFlutterWindow: NSWindow  {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame

    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

// Native Channel
    let fileChannel = FlutterMethodChannel(name: "com.sicreative.vocabularycard.vocabulary_card/file",
                                           binaryMessenger: flutterViewController.engine.binaryMessenger)
    
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

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
    
   
    
    
    private func loadCSV(_ url:URL){
        
        let controller : FlutterViewController = contentViewController as! FlutterViewController
            
        let fileChannel = FlutterMethodChannel(name: "com.sicreative.vocabularycard.vocabulary_card/file",
                                               binaryMessenger: controller.engine.binaryMessenger)
      
        do{
        
        let csv = try String(contentsOf: url, encoding: .utf8)
            
        
            let args = ["csv":csv,"result":"true"]
         
            fileChannel.invokeMethod("loadresult", arguments: args)
            
            
        }catch{
            let args = ["result":"false"]
         
            fileChannel.invokeMethod("loadresult", arguments: args)
        }
        
    }
    
    private func saveCSV ( _ csv: String) {
        
        let controller : FlutterViewController = contentViewController as! FlutterViewController
        
        let savePanel = NSSavePanel()
        
        if #available(macOS 11.0, *) {
            let type = UTType(filenameExtension: "csv")
            savePanel.allowedContentTypes = [type!]
        } else {
            savePanel.allowedFileTypes = ["csv"]

        }
        
        savePanel.begin { response in
            let fileChannel = FlutterMethodChannel(name: "com.sicreative.vocabularycard.vocabulary_card/file",
                                                   binaryMessenger: controller.engine.binaryMessenger)
            var result:String?
            if response == .OK {
                do{
                    try csv.write(to: savePanel.url!, atomically: true, encoding: String.Encoding.utf8)
                }catch{
                    result = "false"
                    let args = ["result": result ]
                        fileChannel.invokeMethod("saveresult", arguments: args)
                }
                result = "true"
                
            }
            else{
                result = "false"
            }
                
            let args = ["result": result ]
                fileChannel.invokeMethod("saveresult", arguments: args)
        }

    }
    
    

    private func loadCSV () {
       
        
        let openPanel = NSOpenPanel()

        if #available(macOS 11.0, *) {
            let type = UTType(filenameExtension: "csv")
            openPanel.allowedContentTypes = [type!]
        } else {
            openPanel.allowedFileTypes = ["csv"]
        }

        openPanel.begin { response in
            if (response == .OK){
                self.loadCSV(openPanel.url!)
            }else{
                let controller : FlutterViewController = self.contentViewController as! FlutterViewController
                    
                let fileChannel = FlutterMethodChannel(name: "com.sicreative.vocabularycard.vocabulary_card/file",
                                                       binaryMessenger: controller.engine.binaryMessenger)
              
                
                let args = ["result":"false"]
             
                fileChannel.invokeMethod("loadresult", arguments: args)
            }
        }
    }
}
