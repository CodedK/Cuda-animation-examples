#include "includes/general.h"
#include "includes/gpu_anim.h"
#define DIM 1024
__global__ void kernel( uchar4 *ptr, int ticks ) {
	int x = threadIdx.x + blockIdx.x * blockDim.x;
	int y = threadIdx.y + blockIdx.y * blockDim.y;
	int offset = x + y * blockDim.x * gridDim.x;
	// now calculate the value at that position
	float fx = x - DIM/2;
	float fy = y - DIM/2;
	// Moving cloth
	float d = sqrtf(sqrtf( fx * fx + fy * fy));
	unsigned char grey = (unsigned char) (128.0f+127.0f*cos(d/20.0f - ticks/7.0f) / (d/20.0f + 1.0f));
	ptr[offset].x = grey - x%ticks;
	ptr[offset].y = grey - y%ticks;
	ptr[offset].z = grey % ticks;
	ptr[offset].w = 50%ticks;
}
void generate_frame( uchar4 *pixels, void*, int ticks ) {
	dim3    grids(DIM/32,DIM/32);
	dim3    threads(32,32);
	kernel<<<grids,threads>>>( pixels, ticks );
}
int main( void ) {
	GPUAnimBitmap  bitmap( DIM, DIM, NULL );
	bitmap.anim_and_exit( (void (*)(uchar4*,void*,int))generate_frame, NULL );
}
