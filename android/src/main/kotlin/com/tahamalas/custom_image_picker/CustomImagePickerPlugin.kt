package com.tahamalas.custom_image_picker

import android.app.Activity
import android.content.Context
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class CustomImagePickerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var activity: Activity
    private lateinit var context: Context
    private var methodChannel: MethodChannel? = null
    private var result: Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "custom_image_picker")
        methodChannel!!.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivity() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel!!.setMethodCallHandler(null)
        methodChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        this.result = result
        when {
            call.method.equals("startListening") -> {
                val argsMap = call.arguments as Map<*, *>
                when (argsMap["id"] as Int) {
                    CallbacksEnum.GET_IMAGES.ordinal -> startListening(
                        argsMap,
                        result,
                        "getAllImages"
                    )
                    CallbacksEnum.GET_GALLERY.ordinal -> startListening(
                        argsMap,
                        result,
                        "getAlbumList"
                    )
                    CallbacksEnum.GET_IMAGES_OF_GALLERY.ordinal -> startListening(
                        argsMap,
                        result,
                        "getPhotosOfAlbum"
                    )
                }
            }
            call.method.equals("cancelListening") -> {
                cancelListening(call.arguments, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private val callbackById: MutableMap<Int, Runnable> = mutableMapOf()

    private fun startListening(args: Any, result: Result, methodName: String) {
        // Get callback id
        println("the args are $args")
        val argsFromFlutter = args as Map<*, *>
        val currentListenerId = argsFromFlutter["id"] as Int
        val runnable = Runnable {
            if (callbackById.containsKey(currentListenerId)) {
                val argsMap: MutableMap<String, Any> = mutableMapOf()
                argsMap["id"] = currentListenerId

                when (methodName) {
                    "getAllImages" -> {
                        argsMap["args"] = getAllImagesList()
                    }
                    "getAlbumList" -> {
                        argsMap["args"] = getAlbumsList()
                    }
                    "getPhotosOfAlbum" -> {
                        val callArgs = argsFromFlutter["args"] as Map<*, *>
                        argsMap["args"] = getPhotosOfAlbum(
                            context,
                            callArgs["albumID"] as String,
                            callArgs["page"] as Int
                        )
                    }
                }
                // Send some value to callback

                activity.runOnUiThread {
                    methodChannel?.invokeMethod("callListener", argsMap)
                }
            }
        }
        val thread = Thread(runnable)
        callbackById[currentListenerId] = runnable
        thread.start()
        // Return immediately
        result.success(null)
    }

    private fun cancelListening(args: Any, result: Result) {
        // Get callback id
        val currentListenerId = args as Int
        // Remove callback
        callbackById.remove(currentListenerId)
        // Do additional stuff if required to cancel the listener
        result.success(null)
    }

    private fun getAllImagesList(): ArrayList<String> {
        val allImages = ArrayList<String>()
        val collection =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }
        val projection = arrayOf(MediaStore.Images.ImageColumns.DATA)
        val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"
        val query = context.contentResolver.query(
            collection,
            projection,
            null,
            null,
            sortOrder,
        )
        query?.use { cursor ->
            while (cursor.moveToNext()) {
                allImages.add(cursor.getString(0))
            }
        }
        query?.close()
        return allImages
    }

    private fun getAlbumsList(): String {
        val phoneAlbums = ArrayList<PhoneAlbum>()
        val collection =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }
        val projection = arrayOf(
            MediaStore.Images.Media.BUCKET_ID,
            MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
            MediaStore.MediaColumns.DATA,
        )
        val bucketOrderBy = MediaStore.Images.Media.DATE_MODIFIED + " DESC"
        val query =
            context.contentResolver.query(
                collection,
                projection,
                null,
                null,
                bucketOrderBy,
            )
        query?.use { cursor ->
            while (cursor.moveToNext()) {
                val bucketId =
                    query.getString(query.getColumnIndexOrThrow(MediaStore.Images.ImageColumns.BUCKET_ID))
                if (phoneAlbums.any{ album -> album.id == bucketId}) {
                    continue
                }
                val name =
                    query.getString(query.getColumnIndexOrThrow(MediaStore.Images.ImageColumns.BUCKET_DISPLAY_NAME))
                val path =
                    query.getString(query.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)) // Thumb image path
                val selection = MediaStore.Images.Media.BUCKET_ID + "='" + bucketId + "'"
                val countCursor = context.contentResolver.query(
                    collection,
                    arrayOf("count(" + MediaStore.Images.ImageColumns._ID + ")"),
                    selection,
                    null,
                    bucketOrderBy,
                )
                var count = 0
                if (countCursor != null) {
                    countCursor.moveToFirst()
                    count = countCursor.getInt(0)
                    countCursor.close()
                }
                phoneAlbums.add(PhoneAlbum(bucketId, name, path, count))
            }
        }
        query?.close()
        return "[${phoneAlbums.joinToString(", ")}]"
    }

    private fun getPhotosOfAlbum(context: Context, albumID: String, pageNumber: Int): String {
        val phonePhotos = mutableListOf<PhonePhoto>()
        val projection = arrayOf(
            MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
            MediaStore.Images.Media.DATA,
            MediaStore.Images.Media._ID
        )
        val images = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val cur = context.contentResolver.query(
            images,
            projection,
            "${MediaStore.Images.ImageColumns.BUCKET_ID} == ?",
            arrayOf(
                albumID
            ),
            MediaStore.Images.Media.DATE_MODIFIED + " DESC " + " LIMIT ${(pageNumber - 1) * 50}, 50 "
        )
        if (cur != null && cur.count > 0) {
            //Log.i("DeviceImageManager", " query count=" + cur.count)
            if (cur.moveToFirst()) {
                var bucketName: String
                var data: String
                var imageId: String
                val bucketNameColumn = cur.getColumnIndex(
                    MediaStore.Images.Media.BUCKET_DISPLAY_NAME
                )
                val imageUriColumn = cur.getColumnIndex(
                    MediaStore.Images.Media.DATA
                )
                val imageIdColumn = cur.getColumnIndex(
                    MediaStore.Images.Media._ID
                )
                do {
                    bucketName = cur.getString(bucketNameColumn)
                    data = cur.getString(imageUriColumn)
                    imageId = cur.getString(imageIdColumn)
                    phonePhotos.add(PhonePhoto(imageId, bucketName, data))
                } while (cur.moveToNext())
            }
            cur.close()
            var string = "[ "
            for (phonePhoto in phonePhotos) {
                string += phonePhoto.toJson()
                if (phonePhotos.indexOf(phonePhoto) != phonePhotos.size - 1)
                    string += ", "
            }
            string += "]"
            return string
        } else {
            return "[]"
        }
    }
}
