import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.app.Application
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.provider.Settings
import android.util.Log
import com.karumi.dexter.Dexter
import com.karumi.dexter.PermissionToken
import com.karumi.dexter.listener.PermissionDeniedResponse
import com.karumi.dexter.listener.PermissionGrantedResponse
import com.karumi.dexter.listener.PermissionRequest
import com.karumi.dexter.listener.single.PermissionListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*

/**
 * CustomImagePickerPlugin
 */
class CustomImagePickerPlugin(internal var activity: Activity, internal var methodChannel: MethodChannel, registrar: Registrar) : MethodCallHandler {
    private var activityLifecycleCallbacks: Application.ActivityLifecycleCallbacks? = null
    private var result: Result? = null

    init {
        this.methodChannel.setMethodCallHandler(this)
        this.activityLifecycleCallbacks = object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle) {}

            override fun onActivityStarted(activity: Activity) {}

            override fun onActivityResumed(activity: Activity) {
                getPermissionResult(result!!, activity)
            }

            override fun onActivityPaused(activity: Activity) {}

            override fun onActivityStopped(activity: Activity) {}

            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}

            override fun onActivityDestroyed(activity: Activity) {}
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        this.result = result
        if (call.method == "getAllImages") {
            getPermissionResult(result, activity)
        } else {
            result.notImplemented()
        }
    }


    fun getPermissionResult(result: Result, activity: Activity) {
        Dexter.withActivity(activity)
                .withPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .withListener(object : PermissionListener {
                    override fun onPermissionGranted(response: PermissionGrantedResponse) {
                        result.success(getAllImageList(activity))
                    }

                    override fun onPermissionDenied(response: PermissionDeniedResponse) {
                        val builder = AlertDialog.Builder(activity)
                        builder.setMessage("This permission is needed for use this features of the app so please, allow it!")
                        builder.setTitle("We need this permission")
                        builder.setCancelable(false)
                        builder.setPositiveButton("OK") { dialog, id ->
                            dialog.cancel()
                            val intent = Intent()
                            intent.action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                            val uri = Uri.fromParts("package", activity.packageName, null)
                            intent.data = uri
                            activity.startActivity(intent)
                        }
                        builder.setNegativeButton("Cancel") { dialog, id -> dialog.cancel() }
                        val alert = builder.create()
                        alert.show()


                    }

                    override fun onPermissionRationaleShouldBeShown(permission: PermissionRequest, token: PermissionToken) {
                        val builder = AlertDialog.Builder(activity)
                        builder.setMessage("This permission is needed for use this features of the app so please, allow it!")
                        builder.setTitle("We need this permission")
                        builder.setCancelable(false)
                        builder.setPositiveButton("OK") { dialog, id ->
                            dialog.cancel()
                            token.continuePermissionRequest()
                        }
                        builder.setNegativeButton("Cancel") { dialog, id ->
                            dialog.cancel()
                            token.cancelPermissionRequest()
                        }
                        val alert = builder.create()
                        alert.show()
                    }
                }).check()
    }

    fun getAllImageList(activity: Activity): ArrayList<String> {
        val allImageList = ArrayList<String>()
        val uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(MediaStore.Images.ImageColumns.DATA, MediaStore.Images.ImageColumns.DISPLAY_NAME, MediaStore.Images.ImageColumns.DATE_ADDED, MediaStore.Images.ImageColumns.TITLE)
        val c = activity.contentResolver.query(uri, projection, null, null, null)
        if (c != null) {
            while (c.moveToNext()) {
                //  ImageModel imageModel = new ImageModel();
                Log.e("", "getAllImageList: " + c.getString(0))
                Log.e("", "getAllImageList: " + c.getString(1))
                Log.e("", "getAllImageList: " + c.getString(2))
                allImageList.add(c.getString(0))
            }
            c.close()
        }
        return allImageList
    }

    companion object {
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "custom_image_picker")
            channel.setMethodCallHandler(CustomImagePickerPlugin(registrar.activity(), channel, registrar))
        }
    }
}