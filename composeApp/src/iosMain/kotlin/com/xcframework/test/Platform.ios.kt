package com.xcframework.test

import platform.UIKit.UIDevice

class IOSPlatform: Platform {
    override val name: String = UIDevice.currentDevice.systemName() + "/iOS/" + UIDevice.currentDevice.systemVersion
}

actual fun getPlatform(): Platform = IOSPlatform()