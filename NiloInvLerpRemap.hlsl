#ifndef Include_NiloInvLerpRemap
#define Include_NiloInvLerpRemap

// Just like smoothstep(), but linear, not clamped
half invLerp(half from, half to, half value) 
{
    return (value - from) / (to - from);
}

half invLerpClamp(half from, half to, half value)
{
    return saturate(invLerp(from, to, value));
}

// Full control remap, but slower
half remap(half origFrom, half origTo, half targetFrom, half targetTo, half value)
{
    half rel = invLerp(origFrom, origTo, value);
    return lerp(targetFrom, targetTo, rel);
}

#endif
