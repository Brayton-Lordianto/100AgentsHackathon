#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

[[stitchable]] half4 premium_shimmer(float2 position, SwiftUI::Layer layer, float time, float2 size) {
    // Sample the original layer
    half4 originalColor = layer.sample(position);
    
    // Normalize position to 0-1 range
    float2 uv = position / size;
    
    // Create animated shimmer band that moves diagonally
    float shimmerAngle = 0.5; // 45-degree angle
    float shimmerPos = (uv.x * cos(shimmerAngle) + uv.y * sin(shimmerAngle));
    float shimmerSpeed = 0.8;
    float shimmerWidth = 0.15;
    
    // Animated shimmer position
    float animatedShimmer = fmod(shimmerPos - time * shimmerSpeed + 1.5, 2.0);
    
    // Create sharp shimmer band with smooth edges
    float shimmerMask = 1.0 - smoothstep(0.0, shimmerWidth, abs(animatedShimmer - 1.0));
    shimmerMask = pow(shimmerMask, 2.0); // Make it more focused
    
    // Pulsing background glow
    float pulseSpeed = 1.2;
    float pulseIntensity = 0.5 + 0.3 * sin(time * pulseSpeed);
    float edgeGlow = 1.0 - smoothstep(0.0, 0.4, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
    edgeGlow = pow(edgeGlow, 2.0) * pulseIntensity;
    
    // Combine effects
    half3 shimmerColor = half3(1.0, 1.0, 1.0); // Pure white shimmer
    half3 glowColor = half3(0.9, 0.95, 1.0);   // Slightly cool glow
    
    // Apply shimmer
    half3 finalColor = originalColor.rgb;
    finalColor = mix(finalColor, shimmerColor, shimmerMask * 0.8);
    
    // Apply glows
    finalColor += glowColor * edgeGlow * 0.05 + half3(0,0.1,0);
    
    // Enhance saturation and brightness for premium feel
    finalColor = mix(finalColor, finalColor * 1.2, 0.3);
    
    return half4(finalColor, originalColor.a);
}
