/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

import Foundation

class FieldNameLabel : UILabel {
	
	private let insets : UIEdgeInsets!
	
	override init(frame: CGRect) {
		insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
		super.init(frame: frame)
	}
	
	init() {
		insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
		super.init(frame: .zero)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func drawText(in rect: CGRect) {
        let newRect = rect.inset(by: insets)
		super.drawText(in: newRect)
	}
	
}
