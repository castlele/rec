package com.castlelecs.rec

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform