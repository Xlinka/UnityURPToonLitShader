#ifndef Include_NiloOutlineUtil
#define Include_NiloOutlineUtil

float GetCameraFOV()
{
    // Optimized method to get camera FOV
    return 1.0 / unity_CameraProjection._m00;
}

float ApplyOutlineDistanceFadeOut(float inputMulFix)
{
    return saturate(inputMulFix);
}

float GetOutlineCameraFovAndDistanceFixMultiplier(float positionVS_Z)
{
    float cameraMulFix;
    if (unity_OrthoParams.w == 0)
    {
        // Perspective camera case
        cameraMulFix = abs(positionVS_Z);
        cameraMulFix = ApplyOutlineDistanceFadeOut(cameraMulFix);
        cameraMulFix *= GetCameraFOV();
    }
    else
    {
        // Orthographic camera case
        float orthoSize = abs(unity_OrthoParams.y);
        orthoSize = ApplyOutlineDistanceFadeOut(orthoSize);
        cameraMulFix = orthoSize * 50;
    }

    return cameraMulFix * 0.00005;
}

#endif
