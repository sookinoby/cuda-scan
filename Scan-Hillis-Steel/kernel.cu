#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <iostream>
using namespace std;

void check(cudaError_t e)
{
	if (e != cudaSuccess)
	{
		printf(cudaGetErrorString(e));
	}
}



// Kernel function to add the elements of two arrays
__global__
void runningSum(int n, float *x)
{
	int id = threadIdx.x;
	
	for (int i = 1; i < n; i = i * 2)
	{
		if(id+i < n)
		x[id+i] += x[id] ;
		//__syncthreads();
	}
	
}

int main(void)
{
	int N = 8;
	float *x, *y;

	// Allocate Unified Memory – accessible from CPU or GPU
	cudaMallocManaged(&x, N * sizeof(float));
	cudaMallocManaged(&y, N * sizeof(float));

	// initialize x and y arrays on the host
	for (int i = 0; i < N; i++) {
		x[i] = i+1;
		cout<<x[i] <<"\t";
	}
	cout<<"\n";
	// Run kernel on 1M elements on the GPU
	runningSum<<<1, N>>>(N, x);

	// Wait for GPU to finish before accessing on host
	cudaDeviceSynchronize();
	cudaError_t error = cudaGetLastError();
	if (error != cudaSuccess)
	{
		// print the CUDA error message and exit
		printf("CUDA error: %s\n", cudaGetErrorString(error));
		exit(-1);
	}

	for (int i = 0; i < N; i++)
		cout << x[i] <<"\t";

	// Free memory
	cudaFree(x);
	cudaFree(y);
	getchar();
	return 0;
}