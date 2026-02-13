package com.poolandchill.app

import android.app.Application
import me.didit.sdk.DiditSdk

class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        DiditSdk.initialize(this)
    }
}
