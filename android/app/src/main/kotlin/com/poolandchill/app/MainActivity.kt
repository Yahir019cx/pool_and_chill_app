package com.poolandchill.app

import android.os.Bundle
import androidx.activity.EdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        EdgeToEdge.enable(this)
        super.onCreate(savedInstanceState)
    }
}
