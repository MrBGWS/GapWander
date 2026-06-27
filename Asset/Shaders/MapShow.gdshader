shader_type canvas_item;

// 圆形半径（UV 坐标，0~1）
uniform float roundR : hint_range(0.0, 1.0) = 0.3;

// 圆外渐变距离（从半径边缘向外，超过此距离完全透明）
uniform float fade_out_length : hint_range(0.0, 1.0) = 0.2;

// 圆内渐变距离（从半径边缘向内，此距离内逐渐变黑）
uniform float fade_in_length : hint_range(0.0, 1.0) = 0.1;

// 圆心坐标（UV 空间，默认中心）
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    // 原始纹理颜色
    vec4 tex_color = texture(TEXTURE, UV);

    // 当前像素到圆心的距离
    float dist = distance(UV, center);

    if (dist <= roundR) {
        // 圆内区域
        float inner_boundary = roundR - fade_in_length; // 渐变起始距离

        if (dist <= inner_boundary) {
            // 完全在圆内且远离边界：保持原样
            COLOR = tex_color;
        } else {
            // 在圆内渐变带中：根据距离线性混合黑色
            float t = (dist - inner_boundary) / fade_in_length; // 0~1，越靠近边界越大
            vec4 black = vec4(0.0, 0.0, 0.0, tex_color.a); // 黑色，保留原透明度
            COLOR = mix(tex_color, black, t);
        }
    } else {
        // 圆外区域：黑色 + 透明度渐变
        float excess = dist - roundR;                 // 超出半径的距离
        float alpha = 1.0 - clamp(excess / fade_out_length, 0.0, 1.0);
        COLOR = vec4(0.0, 0.0, 0.0, alpha);
    }
}