package com.xcframework.test

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform