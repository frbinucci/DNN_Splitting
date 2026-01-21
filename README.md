# DNN_Splitting

**Goal-oriented DNN splitting for edge-assisted CNN inference.**

This repository contains the reference implementation of the resource allocation strategy presented in:

- F. Binucci, M. Merluzzi, P. Banelli, E. C. Strinati, and P. Di Lorenzo,
  **“Enabling Edge Artificial Intelligence via Goal-oriented Deep Neural Network Splitting,”**  
  *Proc. 19th International Symposium on Wireless Communication Systems (ISWCS)*, Rio de Janeiro, Brazil, 2024, pp. 1–6.  
  DOI: https://doi.org/10.1109/ISWCS61526.2024.10639178  
- Preprint: https://arxiv.org/abs/2312.03555

## Overview

Deep Neural Network (DNN) splitting is a key enabler of edge AI: it allows the end device to execute an initial portion of the model and offload intermediate features to a nearby Edge Cloud Server (ECS) to complete inference. This creates additional degrees of freedom to balance energy consumption, latency, and task accuracy, while also supporting privacy- and trust-aware deployments.

In this work, we study DNN splitting for edge inference in 6G scenarios from a **goal-oriented** perspective. In particular, we account for accuracy degradation due to the **splitting point (SP)** selection and **wireless channel conditions**, and we propose a dynamic algorithm that jointly controls:
- SP selection,
- local computing resources,
- uplink transmit power, and
- bandwidth allocation,

to achieve a target goal-effectiveness (e.g., minimize energy under latency and accuracy constraints).

## Usage

The implementation is organized around two main classes:

- **`ServerSimulator`**: simulates ECS-side inference according to the probabilistic model described in the paper.
- **`DeviceSimulator`**: simulates the user equipment (UE) resource allocation strategy for edge-assisted DNN splitting.

To run a simulation in a specific scenario, use:

- **`Simulate.m`** — update this script to modify the scenario parameters and constraints.

## Plotting

To reproduce the figures from the paper:

- **Fig. 3**: run `plotEnergyAccuracyTOForFixedSNRComparison.m` and select option **5**.
- **Fig. 4**: run `plotEnergyAccuracyTOForFixedSPComparison.m` and select option **7**.

## Citation

If you use this code in your work, please cite:

```bibtex
@inproceedings{binucci2024goalorientedDNNSplitting,
  author    = {Binucci, Francesco and Merluzzi, Mattia and Banelli, Paolo and Strinati, Emilio Calvanese and Di Lorenzo, Paolo},
  title     = {Enabling Edge Artificial Intelligence via Goal-oriented Deep Neural Network Splitting},
  booktitle = {2024 19th International Symposium on Wireless Communication Systems (ISWCS)},
  year      = {2024},
  pages     = {1--6},
  doi       = {10.1109/ISWCS61526.2024.10639178}
}

## Contributing

Contributions are welcome.

- Open an issue for bugs/feature requests
- Submit a PR with a clear description and minimal reproducible example
- Add tests for new functionality where possible

---

## License

Licensed under the MIT License. See LICENSE.

---

## Contact

- Maintainer: **Francesco Binucci**
- Email: **francesco.binucci@cnit.it**
