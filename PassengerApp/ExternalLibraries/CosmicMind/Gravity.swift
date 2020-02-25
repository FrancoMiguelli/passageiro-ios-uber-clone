/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

@objc(Gravity)
public enum Gravity: Int {
	case center
	case top
	case bottom
	case left
	case right
	case topLeft
	case topRight
	case bottomLeft
	case bottomRight
	case resize
	case resizeAspect
	case resizeAspectFill
}

/// Converts the Gravity enum to a String value.
public func GravityToValue(gravity: Gravity) -> String {
	switch gravity {
	case .center:
        return CALayerContentsGravity.center.rawValue
	case .top:
        return CALayerContentsGravity.top.rawValue
	case .bottom:
        return CALayerContentsGravity.bottom.rawValue
	case .left:
        return CALayerContentsGravity.left.rawValue
	case .right:
        return CALayerContentsGravity.right.rawValue
	case .topLeft:
        return CALayerContentsGravity.bottomLeft.rawValue
	case .topRight:
        return CALayerContentsGravity.bottomRight.rawValue
	case .bottomLeft:
        return CALayerContentsGravity.topLeft.rawValue
	case .bottomRight:
        return CALayerContentsGravity.topRight.rawValue
	case .resize:
        return CALayerContentsGravity.resize.rawValue
	case .resizeAspect:
        return CALayerContentsGravity.resizeAspect.rawValue
	case .resizeAspectFill:
        return CALayerContentsGravity.resizeAspectFill.rawValue
	}
}
