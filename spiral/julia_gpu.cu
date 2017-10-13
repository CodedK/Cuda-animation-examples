#include "includes/general.h"
#include "includes/cpu_bitmap.h"
#include "includes/gpu_anim.h"
#define DIM 1000




// modify like this in cuComplex structure
// cuComplex( float a, float b ) : r(a), i(b)  {}  -->  __device__ cuComplex( float a, float b ) : r(a), i(b)  {}
struct cuComplex {
	float   r;
	float   i;
	__device__ cuComplex( float a, float b ) : r(a), i(b)  {}
	__device__ float magnitude2( void ) {
		return r * r + i * i;
		// return sqrt(r * r + i * i);
	}
	__device__ cuComplex operator*(const cuComplex& a) {
		return cuComplex(r*a.r - i*a.i, i*a.r + r*a.i);
	}
	__device__ cuComplex operator+(const cuComplex& a) {
		return cuComplex(r+a.r, i+a.i);
	}
	__device__ cuComplex operator-(const cuComplex& a) {
		return cuComplex(r-a.r, i-a.i);
	}
};
__device__ int julia( int x, int y, int ticks ) {
	// float euler = 2.718281;
	float scale =  1.5;
	// float scale =  0.5 + 1/(ticks*0.05);

	float jx = scale * (float)(DIM/2 - x)/(DIM/2);
	float jy = scale * (float)(DIM/2 - y)/(DIM/2);

	// float step =0;
	// float relu =0;
	// step = ticks % 12;
	// relu = logf(1+powf(euler, (step - 13) ));

	// c = 1j # dentrite fractal
	// c = -0.87 + 0.156 # Julia set
	// c = -0.123 + 0.745j # douady's rabbit fractal
	// c = -0.750 + 0j # san marco fractal
	// c = -0.391 - 0.587j # siegel disk fractal
	// c = -0.7 - 0.3j # NEAT cauliflower thingy
	// c = -0.75 - 0.2j # galaxies
	// c = -0.75 + 0.15j # groovy
	// c = -0.7 + 0.35j # frost

	// # JULIA
	// float julia = cosf(ticks*0.01)*0.23; // (ticks*slow_time) * fluctuation between -0.23 and 0.23
	// cuComplex c(-0.87, julia); // for x -0.87, max y:0.23

	// # DOUADY
	// float douady = cosf(ticks*0.01)*0.977; // (ticks*slow_time) * fluctuation between -0.977 and 0.977
	// cuComplex c(-0.123, douady); // for x -0.123, max y:0.977

	// # SIEGEL
	float siegel = cosf(ticks*0.1)*0.709; // (ticks*slow_time) * fluctuation between -0.709 and 0.709
	cuComplex c(-0.391, siegel); // for x -0.391, max y:0.709



	cuComplex a(jx, jy);
	int i = 0;
	for (i=0; i<500; i++) {
		a = a * a * c;
		if (a.magnitude2() > 1000)
			return 0;
	}
	return 1;
}

__global__ void kernel( unsigned char *ptr, int ticks ) {
	// map from blockIdx to pixel position
	int x = blockIdx.x;
	int y = blockIdx.y;
	int offset = x + y * gridDim.x;

	// unsigned char grey = (unsigned char)(128.0f + 127.0f * cos(x/10.0f - ticks/7.0f) / (y/10.0f + 1.0f));
	// now calculate the value at that position
	int juliaValue = julia( x, y, ticks );
	ptr[offset*4 + 0] = 255 * juliaValue;
	ptr[offset*4 + 1] = 0;
	ptr[offset*4 + 2] = 0;
	ptr[offset*4 + 3] = 255;
}
// globals needed by the update routine
struct DataBlock {
	unsigned char   *dev_bitmap;
};


void generate_frame( unsigned char *pixels, void*, int ticks ) {
    dim3    grid(DIM,DIM);
    // dim3    threads(16,16);
    kernel<<<grid,1>>>( pixels, ticks );
    // printf("%f\n", ticks);
}

int main( void ) {
    GPUAnimBitmap  bitmap( DIM, DIM, NULL );
    bitmap.anim_and_exit(
        (void (*)(uchar4*,void*,int)) generate_frame, NULL
    );
}



// int main( void ) {
// 	int ticks;
// 	DataBlock   data;
// 	CPUBitmap bitmap( DIM, DIM, &data );
// 	unsigned char    *dev_bitmap;
// 	HANDLE_ERROR( cudaMalloc( (void**)&dev_bitmap, bitmap.image_size() ) );
// 	data.dev_bitmap = dev_bitmap;
// 	dim3    grid(DIM,DIM);
// 	// dim3    grid(DIM/16,DIM/16);
// 	// dim3    threads(16,16);
// 	ticks=0;
// 	kernel<<<grid,1>>>( dev_bitmap, ticks );
// 	// kernel<<<grid,1>>>( dev_bitmap );
// 	HANDLE_ERROR( cudaMemcpy( bitmap.get_ptr(), dev_bitmap,
// 							  bitmap.image_size(),
// 							  cudaMemcpyDeviceToHost ) );
// 	HANDLE_ERROR( cudaFree( dev_bitmap ) );
// 	bitmap.display_and_exit();
// }
