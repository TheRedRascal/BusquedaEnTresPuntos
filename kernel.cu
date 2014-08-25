#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <cuda.h>
#include <iostream>
#include <conio.h>

const int arraysize = 3;
cudaError_t metodoBusquedaHost(float *valoresintervalo ,float *valoresSplits,unsigned int arraysize);

__device__ float d_valorInicial = 0;
__device__ float d_valorfinal = 20;

float h_valorInicial = 0;
float h_valorfinal = 20;

__global__ void metodoBusqueda(float *vect , float *valorSplits)
{
	int i;
	i = blockIdx.x * blockDim.x + threadIdx.x;
	vect[i] = valorSplits[i] * 2;
}

int main()
{
	float valoresIntervalo [arraysize] = {0};
	float valoresSplits [arraysize] = {0};
	cudaError_t cudaStatus = metodoBusquedaHost(valoresIntervalo,valoresSplits,arraysize);

	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "metodoBusquedaHost fallo!");
		_getch();
		return 1;
	}

	cudaStatus = cudaDeviceReset();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaDeviceReset fallo!");
		_getch();
		return 1;
	}

	for (int i = 0; i < 3; i++)
	{
		float number = valoresIntervalo[i];
		printf("%g\n", number); 
	}

	_getch(); 
	return 0;
}

cudaError_t metodoBusquedaHost(float *valoresintervalo,float * valoresSplits,unsigned int size)
{
	float *dev_valorinicial = 0;
	float *dev_valorfinal = 0;
	float *dev_valoresintervalos = 0;
	float *dev_valorSplits = 0;

	cudaError_t cudaStatus;

	cudaStatus = cudaMalloc((void**)&dev_valorinicial,size * sizeof(float));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc fallo!");
		return cudaStatus;
	}

	cudaStatus = cudaMalloc((void**)&dev_valorSplits,size * sizeof(float));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc fallo!");
		return cudaStatus;
	}

	cudaStatus = cudaMalloc((void**)&dev_valorfinal,size * sizeof(float));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc fallo!");
		return cudaStatus;
	}

	cudaStatus = cudaMalloc((void**)&dev_valoresintervalos,size * sizeof(float));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc fallo!");
		return cudaStatus;
	}

	cudaStatus = cudaMemcpy(dev_valoresintervalos, valoresintervalo, size * sizeof(float), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc fallo!");
		return cudaStatus;
	}

	int firstsplitValue = (h_valorfinal - h_valorInicial)/4;
	int secondSplit = (h_valorfinal - h_valorInicial) /2;
	int thirdSplit = firstsplitValue + secondSplit;

	valoresSplits[0] = firstsplitValue;
	valoresSplits[1] = secondSplit;
	valoresSplits[2] =thirdSplit;

	cudaStatus = cudaMemcpy(dev_valorSplits, valoresSplits, size * sizeof(float), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc fallo!");
		return cudaStatus;
	}

	metodoBusqueda<<<3,1>>>(dev_valoresintervalos,dev_valorSplits);

	cudaStatus = cudaMemcpy(valoresintervalo, dev_valoresintervalos,size * sizeof(float), cudaMemcpyDeviceToHost);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc fallo!");
		return cudaStatus;
	}

	return cudaStatus;
}

