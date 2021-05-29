package com.sicreative.vocabularycard.vocabulary_card

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.*

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.sicreative.vocabularycard.vocabulary_card/file"
    private val LOAD = 1
    private val SAVE = 2
    private var csv : String? = null


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            if (call.method == "load") {
                openFile()
                // Note: this method is invoked on the main thread.
                result.success(true)


            }else if (call.method == "save") {
                saveFile(call.argument("csv"))
                result.success(true)
            }

        }


    }


    private fun openDocument(documentUri: Uri) {


        try {
            val fileDescriptor = context.contentResolver.openFileDescriptor(documentUri, "r")
            val input = BufferedInputStream(FileInputStream(fileDescriptor!!.fileDescriptor))
            val buf = ByteArray(input.available());
            input.read(buf)

            csv = String(buf)

            input.close()
            fileDescriptor.close()
        }catch (e:Exception){

            var args = mapOf("result" to "false")
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod("loadresult",args)
        }



        var args = mapOf("csv" to csv,"result" to "true")


        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod("loadresult",args)



    }

    private fun saveDocument(documentUri: Uri) {



        val fileDescriptor = context.contentResolver.openFileDescriptor(documentUri, "wt") ?: return
        val output = BufferedOutputStream(FileOutputStream(fileDescriptor.fileDescriptor))
        val buf = csv?.toByteArray()




        try {
            output.write(buf)

            output.close()
            fileDescriptor.close()
        }catch(e: Exception){
            val args = mapOf("result" to "false")
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod("saveresult",args)
        }



        val args = mapOf("result" to "true")

        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod("saveresult",args)





    }


    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun onActivityResult(requestCode: Int, resultCode: Int, resultData: Intent?) {
        super.onActivityResult(requestCode, resultCode, resultData)



        if (requestCode == LOAD && resultCode == Activity.RESULT_OK) {
            resultData?.data?.also { documentUri ->


                contentResolver.takePersistableUriPermission(
                        documentUri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                )
                openDocument(documentUri)
            }
        }else if (requestCode == SAVE && resultCode == Activity.RESULT_OK) {
            resultData?.data?.also { documentUri ->

                contentResolver.takePersistableUriPermission(
                        documentUri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                )
                saveDocument(documentUri)
            }

        }
    }


    fun openFile() {





        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"

            val mimeTypes = arrayOf("text/csv")
            intent.putExtra(Intent.EXTRA_MIME_TYPES,mimeTypes)


        }

        startActivityForResult(intent, LOAD)
    }


    fun saveFile(csv: String?) {

        this.csv = csv;

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {

            type = "*/*"

            val mimeTypes = arrayOf("text/csv")
            intent.putExtra(Intent.EXTRA_MIME_TYPES,mimeTypes)

        }

        startActivityForResult(intent, SAVE)
    }


}
