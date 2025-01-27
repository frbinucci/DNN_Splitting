# DNN_Splitting
DNN Splitting for Edge Assisted Inference with Convolutional Neural Networks

This repository contains the implementation of the resource allocation strategy presented in the paper [Enabling Edge Artificial Intelligence via Goal-oriented Deep Neural Network Splitting](https://arxiv.org/abs/2312.03555).

**Usage**

The implementation is composed of two main classes:

* ServerSimulator: to simulate the edge server inference according to the probabilistic model presented in the paper.
* DeviceSimulator: to simulate the User Equipment resource allocation strategy for Edge-Assisted DNN splitting.

The *Simulate.m* script allows to test the resource allocation strategy in a specific scenario. From here it is possible to change the main simulation parameters and the constraints.

**Plotting**

To reproduce Fig.3 of the referenced paper, launch the script *plotEnergyAccuracyTOForFixedSNRComparison.m* and select the option 5. To reproduce Fig.4 of the referenced paper, launch the script *plotEnergyAccuracyTOForFixedSPComparison.m* and select the option 7. 
