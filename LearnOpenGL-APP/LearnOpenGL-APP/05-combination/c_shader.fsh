precision highp float;
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

uniform float opacityPercent;

void main()
{
    // black white screen
    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
    vec4 baseColor = texture2D(inputImageTexture, uv).rgba;
    if (uv.y <= 1.0/3.0 || uv.y >= 2.0/3.0) {
        // blurry cal
        vec3 W = vec3(0.2125, 0.7154, 0.0721);
        float luminance = dot(baseColor.rgb, W);
        
        // mix gary
        vec4 whiteMask = vec4(0.5, 0.5, 0.5, 0.9);
        baseColor = vec4(vec3(luminance), baseColor.a);
        baseColor = mix(whiteMask, baseColor, 0.5);
    }
    gl_FragColor = baseColor;
    
    // blurry screen
//    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
//    vec4 baseColor = texture2D(inputImageTexture, uv).rgba;
//    if (uv.y <= 1.0/3.0 || uv.y >= 2.0/3.0) {
//        // blurry cal
//        vec2 center = vec2(0.5, 0.5);
//        uv -= center;
//        uv = uv / 1.5;
//        uv += center;
//
//        vec4 whiteMask = vec4(0.5, 0.5, 0.5, 0.9);
//        baseColor = mix(whiteMask, texture2D(inputImageTexture, uv)*0.5, 0.2);
//    }
//    gl_FragColor = baseColor;
    
    // 9 screen V3 H3
//    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
//    if (uv.x <= 1.0/3.0) {
//        uv.x = uv.x + 1.0/3.0;
//    } else if (uv.x >= 2.0/3.0) {
//        uv.x = uv.x - 1.0/3.0;
//    }
//    if (uv.y <= 1.0/3.0) {
//        uv.y = uv.y + 1.0/3.0;
//    } else if (uv.y >= 2.0/3.0) {
//        uv.y = uv.y - 1.0/3.0;
//    }
//    vec3 baseColor = texture2D(inputImageTexture, uv).rgb;
//    gl_FragColor = vec4(baseColor, 1.0);
    
//    // 6 screen V2 H3
//    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
//    if (uv.x <= 1.0/3.0) {
//        uv.x = uv.x + 1.0/3.0;
//    } else if (uv.x >= 2.0/3.0) {
//        uv.x = uv.x - 1.0/3.0;
//    }
//    if (uv.y <= 0.5) {
//        uv.y = uv.y + 0.25;
//    } else {
//        uv.y = uv.y - 0.25;
//    }
//    vec3 baseColor = texture2D(inputImageTexture, uv).rgb;
//    gl_FragColor = vec4(baseColor, 1.0);
    
    // 6 screen V3 H2
//    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
//    if (uv.x <= 0.5) {
//        uv.x = uv.x + 0.25;
//    } else {
//        uv.x = uv.x - 0.25;
//    }
//    if (uv.y <= 1.0/3.0) {
//        uv.y = uv.y + 1.0/3.0;
//    } else if (uv.y >= 2.0/3.0) {
//        uv.y = uv.y - 1.0/3.0;
//    }
//    vec3 baseColor = texture2D(inputImageTexture, uv).rgb;
//    gl_FragColor = vec4(baseColor, 1.0);
    
    // 4 screen
//    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
//    if (uv.x <= 0.5) {
//        uv.x = uv.x + 0.25;
//    } else {
//        uv.x = uv.x - 0.25;
//    }
//
//    if (uv.y <= 0.5) {
//        uv.y = uv.y + 0.25;
//    } else {
//        uv.y = uv.y - 0.25;
//    }
//    vec3 baseColor = texture2D(inputImageTexture, uv).rgb;
//    gl_FragColor = vec4(baseColor, 1.0);
    
    // three screen --- H
//    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
//    if (uv.x <= 1.0/3.0) {
//        uv.x = uv.x + 1.0/3.0;
//    } else if (uv.x >= 2.0/3.0) {
//        uv.x = uv.x - 1.0/3.0;
//    }
//    vec3 baseColor = texture2D(inputImageTexture, uv).rgb;
//    gl_FragColor = vec4(baseColor, 1.0);
    
    // three screen --- V
//    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
//    if (uv.y <= 1.0/3.0) {
//        uv.y = uv.y + 1.0/3.0;
//    } else if (uv.y >= 2.0/3.0) {
//        uv.y = uv.y - 1.0/3.0;
//    }
//    vec3 baseColor = texture2D(inputImageTexture, uv).rgb;
//    gl_FragColor = vec4(baseColor, 1.0);

    
    // two screen --- H
//    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
//    if (uv.x <= 0.5) {
//        uv.x = uv.x + 0.25;
//    } else {
//        uv.x = uv.x - 0.25;
//    }
//    vec3 baseColor = texture2D(inputImageTexture, uv).rgb;
//    gl_FragColor = vec4(baseColor, 1.0);
    
    // two screen --- V
//    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
//    if (uv.y <= 0.5) {
//        uv.y = uv.y + 0.25;
//    } else {
//        uv.y = uv.y - 0.25;
//    }
//    vec3 baseColor = texture2D(inputImageTexture, uv).rgb;
//    gl_FragColor = vec4(baseColor, 1.0);
}
