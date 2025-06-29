#include <metal_stdlib>
using namespace metal;
#include <SwiftUI/SwiftUI_Metal.h>

[[ stitchable ]] half4 glowShader(float2 position, SwiftUI::Layer layer, float2 size, float brightness, float fallOffScale, float bOffset) {
    return half4(1,1,1,1);
    
    half4 color = half4(1);
    
    float2 uv = 2.0 * position/size - 1.0;
    uv *= size.y / size.x ;
    
    // Define rectangle size (normalized)
    float2 rect_size = float2(0.1, 0.1);
    
    // Find closest point on rectangle
    float2 closest_rect_point = uv;
    closest_rect_point.x = clamp(uv.x, -rect_size.x, rect_size.x);
    closest_rect_point.y = clamp(uv.y, -rect_size.y, rect_size.y);
    
    // Calculate distance from UV to closest point on rectangle
    float2 cuv = uv - closest_rect_point;
    float d2c = length(cuv);
    
    // Calculate glow alpha using logarithmic falloff
    float alpha = -log(d2c * fallOffScale + bOffset) * brightness;
    alpha = clamp(alpha, 0.0, 1.0);
    
    // Return color with calculated alpha (additive blending effect)
    return half4(color.rgb * alpha, alpha);
}
