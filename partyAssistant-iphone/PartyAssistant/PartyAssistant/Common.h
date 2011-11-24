//
//  Common.h



#import <Foundation/Foundation.h>

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor);
CGRect rectFor1PxStroke(CGRect rect);
void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);
void drawGlossAndGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);
static inline double radians (double degrees) { return degrees * M_PI/180; }
CGMutablePathRef createArcPathFromBottomOfRect(CGRect rect, CGFloat arcHeight);
CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius);