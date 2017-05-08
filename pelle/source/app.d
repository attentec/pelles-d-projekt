import std.stdio;
import std.datetime;
import std.complex;
import std.typecons;
import std.conv;
import std.algorithm;
import std.array;
import std.parallelism;

import imageformats.png;

auto flat_map(alias f, T)(T t) {
    return map!f(t).joiner();
}

ubyte to_ubyte(float f) {
    return to!ubyte(min(max(0, f * 255), 255));
}

struct Color {
    ubyte r, g, b;
}

ubyte[] image_to_bytes(Color[] image) {
    return cast(ubyte[]) image;
}

void main() {
    StopWatch sw;
    sw.start();

    int w = 2^^11;
    int h = 2^^11;
    Color[] image = new Color[](w*h);

    auto d = 0.1/2048;

    auto y0 = 0.1/16+0.1/64;
    auto y1 = y0 + d;

    auto x0 = -0.8+0.045+0.1/32+0.1/64+0.1/512;
    auto x1 = x0 + d;

    int max_iter = 2^^12;

    foreach (i, ref pixel; parallel(image, w*h/4)) {
        auto y = i / w;
        auto x = i % w;

        auto iter = iters(complex(x0+(x1-x0)*x/w, y0+(y1-y0)*y/h), max_iter);
        if (iter >= max_iter) continue;
        auto c = to!double(iter) / max_iter;
        image[i] = Color(
                to_ubyte(3*c-2),
                to_ubyte(3*c-1),
                to_ubyte(3*c));
    }

    writeln(sw.peek().msecs);
    write_png("out2.png", w, h, image.image_to_bytes());
    writeln(sw.peek().msecs);
}

auto iters(Complex!double c, int max_iter) {
    auto z = c;
    foreach (iter; 0 .. max_iter/1) {
        z = z*z + c;
        if (z.sqAbs > 4) return iter*1;
    }
    return max_iter;
};






