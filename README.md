# DNN_Splitting

DNN splitting for edge-assisted inference with convolutional neural networks.

This repository provides the reference implementation of the resource allocation strategy proposed in:  
**Enabling Edge Artificial Intelligence via Goal-oriented Deep Neural Network Splitting** (arXiv) — https://arxiv.org/abs/2312.03555

## Overview

Deep Neural Network (DNN) splitting is a key enabler of edge AI: it allows end users to pre-process data locally and offload part of the computation to nearby Edge Cloud Servers (ECSs). This introduces additional flexibility to balance multiple objectives such as energy consumption, latency, accuracy, privacy, and other trustworthiness metrics.

In this work, we investigate DNN splitting at the edge of 6G wireless networks to support energy-efficient cooperative inference while meeting target delay and accuracy requirements from a goal-oriented perspective. Beyond prior approaches, we model and study trade-offs that account for accuracy degradation as a function of the splitting point (SP) and wireless channel conditions.

We then propose an algorithm that dynamically controls:
- splitting point (SP) selection,
- local computing resources,
- uplink transmit power, and
- bandwidth allocation,

in a goal-oriented manner to satisfy a desired level of goal effectiveness (e.g., minimizing energy consumption under latency and accuracy constraints). Numerical results in the paper highlight the benefits of the proposed adaptive SP selection and resource allocation for energy-frugal and effective edge AI.

## Usage

The implementation is organized around two main classes:

- **`ServerSimulator`**: simulates edge-server inference using the probabilistic model described in the paper.
- **`DeviceSimulator`**: simulates the user equipment (UE) resource allocation strategy for edge-assisted DNN splitting.

To run a simulation in a specific scenario, use:
- **`Simulate.m`** — edit this script to modify the scenario settings, main parameters, and constraints.

## Plotting

To reproduce the paper figures:

- **Figure 3**: run `plotEnergyAccuracyTOForFixedSNRComparison.m` and select option **5**.
- **Figure 4**: run `plotEnergyAccuracyTOForFixedSPComparison.m` and select option **7**.

