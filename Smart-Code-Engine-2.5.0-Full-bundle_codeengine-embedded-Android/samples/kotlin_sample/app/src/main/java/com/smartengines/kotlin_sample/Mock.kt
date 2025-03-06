/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import com.smartengines.core.engine.Engine
import com.smartengines.core.engine.Session
import com.smartengines.core.engine.SessionTarget
import com.smartengines.core.engine.SessionType
import com.smartengines.kotlin_sample.targets.AppTarget

data class MockEngine(override val isVideoModeAllowed: Boolean):Engine{
    override fun createEngine(bundle: ByteArray?) {
        TODO("Not yet implemented")
    }

    override fun createSession(target: SessionTarget, sessionType: SessionType): Session {
        TODO("Not yet implemented")
    }

}

data class MockTarget(
    override val name: String="mock.target",
    override val description: String?=null,
    override val cropImage: Boolean = false
): AppTarget {
    override fun fillSessionSettings(sessionSettings: Any) {
        TODO("Not yet implemented")
    }
}
