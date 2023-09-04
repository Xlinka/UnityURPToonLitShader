#pragma once

// Function to calculate global illumination
half3 CalculateGlobalIllumination(ToonSurfaceData surfaceData, ToonLightingData lightingData)
{
    // Sample spherical harmonics to approximate indirect lighting
    half3 averageSH = SampleSH(0);

    // Ensure a minimum indirect light color to prevent complete darkness
    averageSH = max(_IndirectLightMinColor, averageSH);

    // Apply occlusion, limiting it to a maximum of 50% darkness
    half indirectOcclusion = lerp(1, surfaceData.occlusion, 0.5);

    return averageSH * indirectOcclusion;
}

// Main lighting equation function (Edit this for custom lighting)
half3 CalculateLighting(ToonSurfaceData surfaceData, ToonLightingData lightingData, Light light, bool isAdditionalLight)
{
    half3 N = lightingData.normalWS;
    half3 L = light.direction;
    
    half NoL = dot(N, L);

    half lightAttenuation = 1;

    // Calculate distance attenuation for point and spot lights
    half distanceAttenuation = min(4, light.distanceAttenuation);

    // Apply simple cel shading based on the dot product of normal and light direction
    half litOrShadowArea = smoothstep(_CelShadeMidPoint - _CelShadeSoftness, _CelShadeMidPoint + _CelShadeSoftness, NoL);

    // Apply occlusion
    litOrShadowArea *= surfaceData.occlusion;

    // Handle facing direction to avoid cel shading artifacts
    litOrShadowArea = _IsFace ? lerp(0.5, 1, litOrShadowArea) : litOrShadowArea;

    // Apply shadow mapping from light source
    litOrShadowArea *= lerp(1, light.shadowAttenuation, _ReceiveShadowMappingAmount);

    half3 litOrShadowColor = lerp(_ShadowMapColor, 1, litOrShadowArea);

    half3 lightAttenuationRGB = litOrShadowColor * distanceAttenuation;

    // Saturate light color to prevent over-brightening
    // Reduce intensity for additional lights (additive lighting)
    return saturate(light.color) * lightAttenuationRGB * (isAdditionalLight ? 0.25 : 1);
}

// Function to handle emission
half3 HandleEmission(ToonSurfaceData surfaceData, ToonLightingData lightingData)
{
    // Calculate emission and optionally multiply by albedo
    half3 emissionResult = lerp(surfaceData.emission, surfaceData.emission * surfaceData.albedo, _EmissionMulByBaseColor);
    return emissionResult;
}

// Function to composite the final color
half3 CompositeFinalColor(half3 indirectResult, half3 mainLightResult, half3 additionalLightSumResult, half3 emissionResult, ToonSurfaceData surfaceData, ToonLightingData lightingData)
{
    // Perform final color composition with brightness control
    half3 rawLightSum = max(indirectResult, mainLightResult + additionalLightSumResult);
    return surfaceData.albedo * rawLightSum + emissionResult;
}
