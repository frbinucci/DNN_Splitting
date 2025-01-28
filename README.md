# DNN_Splitting
DNN Splitting for Edge Assisted Inference with Convolutional Neural Networks

This repository contains the implementation of the resource allocation strategy presented in the paper [Enabling Edge Artificial Intelligence via Goal-oriented Deep Neural Network Splitting](https://arxiv.org/abs/2312.03555).

**Abstract**

Deep Neural Network (DNN) splitting is one of the key enablers of edge Artificial Intelligence (AI), as it allows end users to pre-process data and offload part of the computational burden to nearby Edge Cloud Servers (ECSs). This opens new opportunities and degrees of freedom in balancing energy consumption, delay, accuracy, privacy, and other trustworthiness metrics. In this work, we explore the opportunity of DNN splitting at the edge of 6G wireless networks to enable low energy cooperative inference with target delay and accuracy with a goal-oriented perspective. Going beyond the current literature, we explore new trade-offs that take into account the accuracy degradation as a function of the Splitting Point (SP) selection and wireless channel conditions. Then, we propose an algorithm that dynamically controls SP selection, local computing resources, uplink transmit power and bandwidth allocation, in a goal-oriented fashion, to meet a target goal-effectiveness. To the best of our knowledge, this is the first work proposing adaptive SP selection on the basis of all learning performance (i.e., energy, delay, accuracy), with the aim of guaranteeing the accomplishment of a goal (e.g., minimize the energy consumption under latency and accuracy constraints). Numerical results show the advantages of the proposed SP selection and resource allocation, to enable energy frugal and effective edge AI.

**Usage**

The implementation is composed of two main classes:

* ServerSimulator: to simulate the edge server inference according to the probabilistic model presented in the paper.
* DeviceSimulator: to simulate the User Equipment resource allocation strategy for Edge-Assisted DNN splitting.

The *Simulate.m* script allows to test the resource allocation strategy in a specific scenario. From here it is possible to change the main simulation parameters and the constraints.

**Plotting**

To reproduce Fig.3 of the referenced paper, launch the script *plotEnergyAccuracyTOForFixedSNRComparison.m* and select the option 5. To reproduce Fig.4 of the referenced paper, launch the script *plotEnergyAccuracyTOForFixedSPComparison.m* and select the option 7. 
