#ifndef Include_NiloZOffset
#define Include_NiloZOffset

// Function to adjust the clip space position by pushing it toward or away from the camera in view space.
// This function overwrites the original positionCS.z value to control depth during rendering.
// Useful for:
// - Hiding outline artifacts on the face or eyes
// - Rendering eyebrows on top of hair
// - Solving Z-fighting issues without altering geometry
float4 ModifyClipPositionWithZOffset(float4 originalPositionCS, float viewSpaceZOffsetAmount)
{
    if (unity_OrthoParams.w == 0)
    {
        // Perspective camera case
        float2 projM_ZRow_ZW = UNITY_MATRIX_P[2].zw;
        float modifiedPositionVS_Z = -originalPositionCS.w + -viewSpaceZOffsetAmount; // Push an imaginary vertex
        float modifiedPositionCS_Z = modifiedPositionVS_Z * projM_ZRow_ZW[0] + projM_ZRow_ZW[1];
        originalPositionCS.z = modifiedPositionCS_Z * originalPositionCS.w / (-modifiedPositionVS_Z); // Overwrite positionCS.z
        return originalPositionCS;
    }
    else
    {
        // Orthographic camera case
        originalPositionCS.z += -viewSpaceZOffsetAmount / _ProjectionParams.z; // Push an imaginary vertex and overwrite positionCS.z
        return originalPositionCS;
    }
}

#endif
