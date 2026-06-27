shader_type canvas_item;
uniform float progress : hint_range(0, 1) = 0.0; // 进度值 (0.0=冷却开始, 1.0=冷却结束)
uniform float start_angle = 0.75; // 起始角度 (0.75=12点钟方向)
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // 计算中心坐标
    vec2 center = vec2(0.5);
    vec2 coord = UV - center;

    // 计算当前像素的角度 (0-1范围)
    float angle = atan(coord.y, coord.x) / (2.0 * PI) + 0.5;
    angle = fract(angle); // 确保在 [0,1) 范围内

    // 调整起始点 (默认从12点钟方向开始)
    angle = fract(angle + start_angle);
    // 判断是否在灰化区域内
    if (angle > progress) {
        // 透明度设置为0
        color.a = 0.0;
    }

    COLOR = color;
}