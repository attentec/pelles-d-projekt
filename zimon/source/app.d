import std.stdio;
import std.complex;
import std.conv;
import imageformats;
import std.algorithm;
import std.array;
import std.range;
import std.parallelism;
import std.datetime;
import std.math;

struct MandelStruct {
	int iter;
	Complex!double c;
}
auto mandelbrot(Complex!double c, int max_iterations) {
	auto z = c;
	foreach(iter; 0 .. max_iterations) {
		 z = z^^2 + c;

		if(abs(z) > 2) return MandelStruct(iter, z);

	}
	return MandelStruct(max_iterations, z);
}
struct Pixel {
	ubyte r;
	ubyte g;
	ubyte b;
}
ubyte[] make_array(Pixel[][] image) {
	return image.map!(row=>row.map!(p => [p.r, p.g, p.b]).joiner()).joiner().array();
}
void main()
{
	StopWatch time;
	time.start();
	double x0 = -1.0 / 8 + 1.0/16 + 1.0/32 + 1.0/128 + 1.0/256;
	double y0 = -0.75 + 1.0/256;

	double delta = 1.0 / 16 - 1.0/32 - 1.0/64;

	int width = 1920;
	int height = 1080;

	int max_iter = 512;
	Pixel[][] image = new Pixel[][](height, width);

	foreach(y; parallel(iota(height), 60)) {
		foreach(x; 0 .. width) {
			auto c = complex(x0 + delta * x / width, y0 + delta * y /height);
			auto mandel = mandelbrot(c, max_iter);
			auto iter = mandel.iter;

			if (iter == max_iter) {
				image[y][x] = Pixel(0, 0, 0);

			} else if (abs(mandel.c) > 50) {
				float color = iter*1.0/255;
				image[y][x] = Pixel(0, 0, to!ubyte(iter*255/max_iter));
			} else {
				float color = iter*1.0/255;
				image[y][x] = Pixel(to!ubyte(iter*255/max_iter), to!ubyte(color), to!ubyte(iter*255/max_iter));
			}
		}
	}
	write_png("yolo.png", width, height, make_array(image));
	writeln(time.peek().msecs);
}
