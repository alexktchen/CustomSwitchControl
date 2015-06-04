
import UIKit
import QuartzCore

@IBDesignable @objc public class CustomSwitchControl: UIControl {
    
    // public
    
    /*
    *   Set (without animation) whether the switch is on or off
    */
    @IBInspectable public var on: Bool {
        get {
            return switchValue
        }
        set {
            switchValue = newValue
            self.setOn(newValue, animated: false)
        }
    }
    
    /*
    *	Sets the background color that shows when the switch off and actively being touched.
    *   Defaults to light gray.
    */
    @IBInspectable public var activeColor: UIColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1) {
        willSet {
            if self.on && !self.tracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }
    
    /*
    *	Sets the background color when the switch is off.
    *   Defaults to clear color.
    */
    @IBInspectable public var inactiveColor: UIColor = UIColor.clearColor() {
        willSet {
            if !self.on && !self.tracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }
    
    /*
    *   Sets the background color that shows when the switch is on.
    *   Defaults to green.
    */
    @IBInspectable public var onTintColor: UIColor = UIColor(red: 0.3, green: 0.85, blue: 0.39, alpha: 1) {
        willSet {
            if self.on && !self.tracking {
                backgroundView.backgroundColor = newValue
                backgroundView.layer.borderColor = newValue.CGColor
            }
        }
    }
    
    /*
    *   Sets the border color that shows when the switch is off. Defaults to light gray.
    */
    @IBInspectable public var borderColor: UIColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1) {
        willSet {
            if !self.on {
                backgroundView.layer.borderColor = newValue.CGColor
            }
        }
    }
    
    /*
    *	Sets the knob color. Defaults to white.
    */
    @IBInspectable public var thumbTintColor: UIColor = UIColor.whiteColor() {
        willSet {
            if !userDidSpecifyOnThumbTintColor {
                onThumbTintColor = newValue
            }
            if (!userDidSpecifyOnThumbTintColor || !self.on) && !self.tracking {
                thumbView.backgroundColor = newValue
            }
        }
    }
    
    /*
    *	Sets the knob color that shows when the switch is on. Defaults to white.
    */
    @IBInspectable public var onThumbTintColor: UIColor = UIColor.whiteColor() {
        willSet {
            userDidSpecifyOnThumbTintColor = true
            if self.on && !self.tracking {
                thumbView.backgroundColor = newValue
            }
        }
    }
    
    /*
    *	Sets the shadow color of the knob. Defaults to gray.
    */
    @IBInspectable public var shadowColor: UIColor = UIColor.grayColor() {
        willSet {
            thumbView.layer.shadowColor = newValue.CGColor
        }
    }
    
    /*
    *	Sets whether or not the switch edges are rounded.
    *   Set to NO to get a stylish square switch.
    *   Defaults to YES.
    */
    @IBInspectable public var isRounded: Bool = true {
        willSet {
            if newValue {
                backgroundView.layer.cornerRadius = self.frame.size.height * 0.5
                thumbView.layer.cornerRadius = (self.frame.size.height * 0.5) - 1
            }
            else {
                backgroundView.layer.cornerRadius = 2
                thumbView.layer.cornerRadius = 2
            }
            
            thumbView.layer.shadowPath = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).CGPath
        }
    }
    
    /*
    *   Sets the image that shows on the switch thumb.
    */
    @IBInspectable public var thumbImage: UIImage! {
        willSet {
            thumbImageView.image = newValue
        }
    }
    
    /*
    *   Sets the image that shows when the switch is on.
    *   The image is centered in the area not covered by the knob.
    *   Make sure to size your images appropriately.
    */
    @IBInspectable public var onImage: UIImage! {
        willSet {
            onImageView.image = newValue
        }
    }
    
    /*
    *	Sets the image that shows when the switch is off.
    *   The image is centered in the area not covered by the knob.
    *   Make sure to size your images appropriately.
    */
    @IBInspectable public var offImage: UIImage! {
        willSet {
            offImageView.image = newValue
        }
    }
    
    /*
    *	Sets the text that shows when the switch is on.
    *   The text is centered in the area not covered by the knob.
    */
    public var onLabel: UILabel!
    
    /*
    *	Sets the text that shows when the switch is off.
    *   The text is centered in the area not covered by the knob.
    */
    public var offLabel: UILabel!
    
    // internal
    internal var backgroundView: UIView!
    internal var thumbView: UIView!
    internal var onImageView: UIImageView!
    internal var offImageView: UIImageView!
    internal var thumbImageView: UIImageView!
    // private
    private var currentVisualValue: Bool = false
    private var startTrackingValue: Bool = false
    private var didChangeWhileTracking: Bool = false
    private var isAnimating: Bool = false
    private var userDidSpecifyOnThumbTintColor: Bool = false
    private var switchValue: Bool = false
    
    
    public convenience init() {
        self.init(frame: CGRectMake(0, 0, 50, 30))
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override public init(frame: CGRect) {
        let initialFrame = CGRectIsEmpty(frame) ? CGRectMake(0, 0, 50, 30) : frame
        super.init(frame: initialFrame)
        self.setup()
    }
    
    
    private func setup() {
        
        // background
        self.backgroundView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        backgroundView.backgroundColor = self.inactiveColor
        backgroundView.layer.cornerRadius = self.frame.size.height * 0.5
        backgroundView.layer.borderColor = self.borderColor.CGColor
        backgroundView.layer.borderWidth = 1.0
        backgroundView.userInteractionEnabled = false
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
        
        // on/off images
        self.onImageView = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        onImageView.alpha = 1.0
        onImageView.contentMode = UIViewContentMode.Center
        backgroundView.addSubview(onImageView)
        
        self.offImageView = UIImageView(frame: CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        offImageView.alpha = 1.0
        offImageView.contentMode = UIViewContentMode.Center
        backgroundView.addSubview(offImageView)
        
        // labels
        self.onLabel = UILabel(frame: CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        onLabel.textAlignment = NSTextAlignment.Center
        onLabel.textColor = UIColor.lightGrayColor()
        onLabel.font = UIFont.systemFontOfSize(12)
        backgroundView.addSubview(onLabel)
        
        self.offLabel = UILabel(frame: CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        offLabel.textAlignment = NSTextAlignment.Center
        offLabel.textColor = UIColor.lightGrayColor()
        offLabel.font = UIFont.systemFontOfSize(12)
        backgroundView.addSubview(offLabel)
        
        self.thumbView = UIView(frame: CGRectMake(5, 5, 0, 0))
        thumbView.layer.cornerRadius = (self.frame.size.height * 0.5) - 1
        thumbView.layer.shadowColor = self.shadowColor.CGColor
        thumbView.layer.shadowRadius = 2.0
        thumbView.layer.shadowOpacity = 0.5
        thumbView.layer.shadowOffset = CGSizeMake(0, 3)
        
        println(thumbView.bounds)
        println(thumbView.layer.cornerRadius)
        
        
        thumbView.layer.shadowPath = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).CGPath
        thumbView.layer.masksToBounds = false
        thumbView.userInteractionEnabled = false
        self.addSubview(thumbView)
        
        // thumb image
        self.thumbImageView = UIImageView(frame: CGRectMake(0, 0, thumbView.frame.size.width, thumbView.frame.size.height))
        thumbImageView.contentMode = UIViewContentMode.Center
        thumbImageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        thumbView.addSubview(thumbImageView)
        
        self.on = false
    }
    
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        startTrackingValue = self.on
        didChangeWhileTracking = false
        
        let activeKnobWidth = self.bounds.size.height - 2 + 5
        isAnimating = true
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.BeginFromCurrentState, animations: {
            if self.on {
                self.thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1) - 3, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height)
                
            }
            else {
                self.thumbView.frame = CGRectMake(self.thumbView.frame.origin.x, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height)
                self.thumbView.backgroundColor = self.thumbTintColor
            }
            }, completion: { finished in
                self.isAnimating = false
        })
        
        return true
    }
    
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        let lastPoint = touch.locationInView(self)
        
        if lastPoint.x > self.bounds.size.width * 0.5 {
            self.showOn(true)
            if !startTrackingValue {
                didChangeWhileTracking = true
            }
        }
        else {
            self.showOff(true)
            if startTrackingValue {
                didChangeWhileTracking = true
            }
        }
        
        return true
    }
    
    override public func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        super.endTrackingWithTouch(touch, withEvent: event)
        
        let previousValue = self.on
        
        if didChangeWhileTracking {
            self.setOn(currentVisualValue, animated: true)
        }
        else {
            self.setOn(!self.on, animated: true)
        }
        
        if previousValue != self.on {
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override public func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
        
        if self.on {
            self.showOn(true)
        }
        else {
            self.showOff(true)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if !isAnimating {
            let frame = self.frame
            
            self.onLabel.frame = CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height)
            self.offLabel.frame = CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height)
            
            let normalKnobWidth = frame.size.height - 2 - 4
            let thumbX = frame.size.width - (normalKnobWidth + 4)
            
            if self.on {
                
                //self.thumbView.backgroundColor = self.thumbTintColor
                self.onImageView.alpha = 0
                self.offImageView.alpha = 1.0
                self.onLabel.alpha = 0
                self.offLabel.alpha = 1.0
                
                thumbView.frame = CGRectMake(thumbX, 3, normalKnobWidth, normalKnobWidth)
                thumbView.layer.borderWidth = 1
                self.thumbView.backgroundColor = self.thumbTintColor
                
            }
            else {
                
                
                
                self.thumbView.backgroundColor = UIColor.clearColor()
                
                self.thumbView.layer.borderWidth = 1
                self.thumbView.layer.borderColor = UIColor.whiteColor().CGColor
                
                
                //let normalKnobWidth = frame.size.height - 2 - 4
                
                // self.thumbView.frame = CGRectMake(4, 3, normalKnobWidth, self.thumbView.frame.size.height);
                
                let normalKnobWidth = frame.size.height - 2 - 4
                self.backgroundView.backgroundColor = UIColor.clearColor()
                self.thumbView.frame = CGRectMake(1, 1, normalKnobWidth, normalKnobWidth)
                self.thumbView.frame = CGRectMake(4, 3, normalKnobWidth, self.thumbView.frame.size.height);
                
                
                self.thumbView.backgroundColor = UIColor.clearColor()
                self.thumbView.layer.borderWidth = 1
                self.thumbView.layer.borderColor = UIColor.whiteColor().CGColor
                
            }
            
            let radius = self.isRounded ? (frame.size.height * 0.5) - 1 : 2
            
            println(radius)
            thumbView.layer.cornerRadius = radius - 2
        }
    }
    
    
    public func setOn(isOn: Bool, animated: Bool) {
        switchValue = isOn
        
        if on {
            self.showOn(animated)
        }
        else {
            self.showOff(animated)
        }
    }
    
    
    public func isOn() -> Bool {
        return self.on
    }
    
    
    private func showOn(animated: Bool) {
        let normalKnobWidth = frame.size.height - 2 - 4
        let activeKnobWidth = normalKnobWidth + 5
        
        if animated {
            isAnimating = true
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.BeginFromCurrentState, animations: {
                
                if self.tracking {
                    self.thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height)
                }
                else {
                    self.thumbView.frame = CGRectMake(self.bounds.size.width - (normalKnobWidth + 1), self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height)
                }
                
                let thumbX = self.frame.size.width - (self.frame.size.height - 2 - 4 + 4)
                
                self.thumbView.frame = CGRectMake(thumbX, 3, normalKnobWidth, normalKnobWidth)
                
                self.thumbView.backgroundColor = self.thumbTintColor
                self.onImageView.alpha = 0
                self.offImageView.alpha = 1.0
                self.onLabel.alpha = 0
                self.offLabel.alpha = 1.0
                
                self.onImageView.alpha = 1.0
                self.offImageView.alpha = 0
                self.onLabel.alpha = 1.0
                self.offLabel.alpha = 0
                }, completion: { finished in
                    self.isAnimating = false
            })
        }
        else {
            if self.tracking {
                thumbView.frame = CGRectMake(self.bounds.size.width - activeKnobWidth, thumbView.frame.origin.y, activeKnobWidth, thumbView.frame.size.height)
            }
            else {
                thumbView.frame = CGRectMake(self.bounds.size.width - normalKnobWidth, thumbView.frame.origin.y, normalKnobWidth, thumbView.frame.size.height)
            }
            
            onImageView.alpha = 1.0
            offImageView.alpha = 0
            onLabel.alpha = 1.0
            offLabel.alpha = 0
        }
        
        currentVisualValue = true
    }
    
    
    private func showOff(animated: Bool) {
        let normalKnobWidth = frame.size.height - 2 - 4
        let activeKnobWidth = normalKnobWidth + 5
        
        if animated {
            isAnimating = true
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.BeginFromCurrentState, animations: {
                if self.tracking {
                    self.thumbView.frame = CGRectMake(1, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height);
                }
                else {
                    self.thumbView.frame = CGRectMake(4, self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height);
                }
                
                
                
                self.thumbView.backgroundColor = UIColor.clearColor()
                self.thumbView.layer.borderWidth = 1
                self.thumbView.layer.borderColor = UIColor.whiteColor().CGColor
                
                
                
                }, completion: { finished in
                    self.isAnimating = false
            })
        }
        else {
            if (self.tracking) {
                thumbView.frame = CGRectMake(1, thumbView.frame.origin.y, activeKnobWidth, thumbView.frame.size.height)
                //backgroundView.backgroundColor = self.activeColor
            }
            else {
                self.thumbView.frame = CGRectMake(4, self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height);
                //backgroundView.backgroundColor = self.inactiveColor
            }
            
            self.thumbView.frame = CGRectMake(4, self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height);
            onImageView.alpha = 0
            offImageView.alpha = 1.0
            onLabel.alpha = 0
            offLabel.alpha = 1.0
        }
        
        currentVisualValue = false
    }
    
    
}
