# A Systolic Array-Based General Convolutional Neural Network Accelerator
This repository stores the Verilog HDL source codes for an SA-based general CNN accelerator and the corresponding verification codes written in Python.The accelerator is implemented on the Xilinx XC7Z020,
operating at a frequency of 90 MHz. We deploy the LeNet model on this accelerator to recognize handwritten images of the MINST dataset to validate its function. It is also able to adapt to different CNN models according to the configuration
information.  

## Repository structure and description
The repository consists of three folders, namely *Python*, *SA* and *coretex-a9*.
The *Python* folder maninly contains the codes to train the LeNet model and the codes to validate the calculation results of the FPGA.
The SA *folder* contains the codes of our CNN accelerator written in Verilog HDL.
The *coretex-a9* folder contains the source codes of the CNN accelerator which is implemented in the embedded processor Coretex-A9.

### 1. Python
#### 1.1 cnn_parameter
This folder mainly contains 4 different types of files. We will illustrate them with four examples.
###### 1.1.1 conv1.bias.txt
This file stores the parameters of the CNN model, with each line representing one piece of data. The file will be further processed to obtain a *.coe* file, which is used to initialize the FPGA's ROM.
###### 1.1.2 conv1.bias_n.txt
This file stores the parameters of the CNN model which will be used in Coretex-A9. And the parameters are converted into *int* by multiplying  2^15 and each line represents one piece of data. 
###### 1.1.3conv1.bias_n1.txt
This file stores the parameters of the CNN model which will be used in Coretex-A9. And the parameters are converted into *float* and each line representes one piece of data. 
###### 1.1.4 infamp_binary_mul.txt or infamp_original_mul.txt
This file stores multiple INFMAPs with the binarization process. (original) 
#### 1.2 lenet_train_and_predict.ipynb
The code is mainly used for training the LeNet model, extracting model parameters, and measuring the inference accuracy of the model after data quantization.
#### 1.3 fpga_predict.ipynb
This code replicates the calculation process in the FPGA within Python and can be used to verify the results of each layer of the calculation in the FPGA.
#### 1.4 data_load_in_embedded_processor.ipynb
This code is used to convert the original file *conv1.bias.txt* into the parameter file *conv1.bias_n.txt* required by Coretex-A9.
#### 1.5 lenet.pth
This file is the trained LeNet model.  

  
### 2. cortex-a9/src
#### 2.1 float
The *float* folder consists of the CNN accelerator implemented by *float* data type in Coretex-A9.
##### 2.1.1 mian.c
The main function is used to connect different layers in the CNN, initialize the INFMAP,  and obtain the final calculation results.
##### 2.1.2 claculate.h and calcualte.c
The codes define the functions used to implement the calculations of various layers in the CNN, such as convolution layers, pooling layers, and fully-connected layers.
##### 2.1.3 parameter.h and parameter.c
The codes define the parameters in the CNN , as well as the parameters that may be used in the embedded processor, and also define the functions for initializing the CNN parameters in Coretex-A9.
#### 2.2 short
The *short* folder consists of the CNN accelerator implemented by *int16* data type in Coretex-A9.

### 3. SA
#### 3.1 simulation
This folder stores the codes of our CNN accelerator. We can directly open them in Modelsim and do simulation. During the simulation process, we use the data generated according to a certain rule as the parameters of the CNN and the input matrix. The codes in this folder are more comprehensive in functionality compared to those in *Project* folder, because the latter one has removed some unused functions for the LeNet model to reduce the consumption of hardware resources.
##### 3.1.1 SA_FINAL_VER.mpf
Project File.
##### 3.1.2 src
This folder consits of the source codes.
##### 3.1.3 Usage method
Use Modelsim to open the project file *SA_FINAL_VER.mpf*. There are 21 *.v* files used in this project file, among which *test_top.v* is the top-level module. After opening the project file, then execute the complie and simulation processes in sequence (the simulation process takes about 450 μs). The final calculation results are stored in 
*{sim:/test_top/u_fc_ram1/gen_ram_fc[3:0]/u_ram_new/mem}* .

It is worth noting that compilation errors may occur due to changes in the file paths. In this case, it is necessary to manually delete all the *.v* files in the project file and add them again.

#### 3.2 Project 
This folder contains the engineering codes for deploying the accelerator on the FPGA. In this project, we have used the parameters of the actual LeNet model. We can use the simulation function in Vivado to observe the simulation results and the project can also be directly downloaded onto the FPGA for verification. The verification process is relatively simple. We have prestored 12 pictures (the first 12 pictures in the LeNet test dataset) into the input memory. The prestored pictures can be selected by using the switches on the FPGA. Meanwhile, the inference results of the accelerator can be displayed in binary through 4 LEDs.
##### 3.2.3 Usage method
Open *project_1.xpr* and download the bitstream file directly to the FPGA.

