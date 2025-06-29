#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

[[stitchable]] half4 premium_shimmer(float2 position, SwiftUI::Layer layer, float time, float2 size, float duration) {
    // Sample the original layer
    half4 originalColor = layer.sample(position);
    
    // Stop animation after duration seconds
    if (time > duration) {
        return originalColor;
    }
    
    // Normalize position to 0-1 range
    float2 uv = position / size;
    
    // Create animated shimmer band that moves diagonally
    float shimmerAngle = M_PI_F / 4.0;
    float shimmerPos = (uv.x * cos(shimmerAngle) + uv.y * sin(shimmerAngle));
    float shimmerSpeed = 1.0 / duration; // Complete one pass in 'duration' seconds
    float shimmerWidth = 0.1;
    
    // Animated shimmer position - normalized to complete exactly once
    float normalizedTime = time / duration; // 0 to 1 over duration
    float animatedShimmer = shimmerPos - normalizedTime * 2.0 + 1.0;
    
    // Create sharp shimmer band with smooth edges
    float shimmerMask = 1.0 - smoothstep(0.0, shimmerWidth, abs(animatedShimmer));
    shimmerMask = pow(shimmerMask, 2.0); // Make it more focused
    
    // Optional: Fade out the shimmer towards the end
    float fadeOut = 1.0 - smoothstep(0.8, 1.0, normalizedTime);
    shimmerMask *= fadeOut;
    
    // Combine effects
    half3 shimmerColor = half3(1.0, 0.84, 0.0);   // Rich gold shimmer
    
    // Apply shimmer
    float shimmerIntensity = 0.4;
    half3 finalColor = originalColor.rgb;
    finalColor = mix(finalColor, shimmerColor, shimmerMask * shimmerIntensity);
    
    return half4(finalColor, originalColor.a);
}
