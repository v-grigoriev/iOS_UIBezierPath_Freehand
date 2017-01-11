# iOS_UIBezierPath_Freehand
The extension, that adds to UIBezierPath freehand like line and rectangle.

#Usage

```swift
  override func draw(_ rect: CGRect) {
        UIColor(red: 35.0 / 255.0, green: 73.0 / 255.0, blue: 110.0 / 255.0, alpha: 0.8).set()
        
        let borderInstets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        let actualRect = UIEdgeInsetsInsetRect(rect, borderInstets)

        let bezierPath = UIBezierPath()
        bezierPath.lineJoinStyle = .round
        bezierPath.lineWidth = 2.0
        bezierPath.addFreehandRect(rect: actualRect)
        bezierPath.stroke()
  }
```

#Screenshots

![Screenshot](https://raw.githubusercontent.com/v-grigoriev/iOS_UIBezierPath_Freehand/master/Images/Screenshot.png)
