shader_type sky;

// property of larpreii (spacereii), feel free 
// to use this in your own projects and get rid 
// of this comment if you're mean

uniform vec3 sun_color : source_color = vec3(10.0, 10.0, 10.0); // the color of the sun, and it's intensity
uniform float sun_size : hint_range(0.01, 1.0) = 0.05; // self-explanatory
uniform float sun_blur : hint_range(0.01, 20.0) = 0.01; // the sun's edge softness (recommended to be about 0.05 or 0.2)

uniform float star_density : hint_range(0.01, 1.0) = 0.5; // scale for the stars grid
uniform float star_brightness : hint_range(0.1, 5.0) = 1.2; // Multiplier for the light's intensity

float hash(vec3 p) {
    p  = fract(p * 0.1031);
    p += dot(p, p.zyx + 31.32);
    return fract((p.x + p.y) * p.z);
}

void sky() {
    vec3 dir = EYEDIR; // direction of the camera
    
    float cos_theta = dot(dir, LIGHT0_DIRECTION); // alignment between view and direction of sun
    float sun_disc = smoothstep(1.0 - sun_size, 1.0 - sun_size + (sun_blur * 0.001), cos_theta);
    vec3 final_sun = sun_disc * sun_color;

    vec3 star_grid = floor(dir * 200.0 * star_density); // the grid for star placement
    float star_noise = hash(star_grid); // random value per cell ^^^
    vec3 stars = vec3(0.0);
    
    if (star_noise > 0.995) {
        float star_intensity = pow(hash(star_grid + 0.5), 10.0) * star_brightness;
        stars = vec3(star_intensity);
    }
    
    stars *= (1.0 - sun_disc); // stops stars from rendering inside the sun
    COLOR = final_sun + stars;
}