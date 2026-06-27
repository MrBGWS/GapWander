shader_type canvas_item;
// 透明度
uniform float alpha_ = 1;
// 是否置为灰色
uniform float gray_scale = 0.0;

//受击闪光
uniform bool is_damaging = false;
uniform vec4 blink_color: source_color;
uniform float blink_intensity = 0;

//是否开启描边
uniform bool outline_on = false;
// 描边颜色 (RGBA)
uniform vec4 outline_color : source_color = vec4(0.2, 1.0, 0.2, 0.15);
// 描边厚度 (像素)
uniform float outline_thickness : hint_range(0, 20) = 1.0;

////导入的替换颜色
//uniform vec3 replacement_color:source_color;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    //取编辑器中设置的a
    color.a = COLOR.a;
    vec3 originalRGB = color.rgb;
    //灰色变色逻辑
    if (gray_scale > 0.0) {
        // 使用加权公式计算灰度值
        float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        color.rgb = (gray_scale * vec3(gray) + (1.0 - gray_scale) * originalRGB) * 1.0; // 替换为灰度值 保留一些原来的颜色 设置权重
        //color.rgb = vec3(gray);
    }
    //受击闪光逻辑
    if(is_damaging)
    {
        color = mix(color, blink_color, blink_intensity * color.a);
    }

    //描边
    // 如果当前像素不透明，直接使用原始颜色
    if (outline_on && color.a <= 0.0) {
        // 计算描边厚度（转换为UV空间）
        vec2 thickness_uv = outline_thickness * TEXTURE_PIXEL_SIZE;

        // 检查周围像素的透明度
        float max_alpha = 0.0;

        // 检查8个方向的像素（确保描边均匀）
        max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(thickness_uv.x, 0.0)).a);
        max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-thickness_uv.x, 0.0)).a);
        max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0, thickness_uv.y)).a);
        max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0, -thickness_uv.y)).a);
        max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(thickness_uv.x, thickness_uv.y)).a);
        max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-thickness_uv.x, thickness_uv.y)).a);
        max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(thickness_uv.x, -thickness_uv.y)).a);
        max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-thickness_uv.x, -thickness_uv.y)).a);
        // 如果周围有一定程度上非透明像素，应用描边
        if (max_alpha > 0.5) {
            color = outline_color;
        }
    }



    COLOR = color;

    //换色逻辑 https://www.youtube.com/watch?v=nyFzPaWAzeQ

    //vec3 color_without_green = COLOR.rgb * vec3(1, 0, 0);
    //float amount_of_red_and_blue = length(color_without_green);
    //float red_and_blue_mask = step(0.01, amount_of_red_and_blue);
    //vec3 retained_color = COLOR.rgb * red_and_blue_mask;
    //float green_mask = (1.0 - red_and_blue_mask) * COLOR.g;
    //
    //vec3 masked_replacement_color = replacement_color * green_mask;
    //vec3 final_color = retained_color + masked_replacement_color;
    //
    //COLOR.rgb = vec3(final_color);
}
